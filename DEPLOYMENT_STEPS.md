# Trepidus Tech - Deployment Steps

Follow these steps to deploy your website to AWS Elastic Beanstalk.

## Prerequisites Check

Before you start, make sure you have:

- [ ] AWS account with admin access
- [ ] AWS CLI installed and configured
- [ ] Terraform installed (version 1.0+)
- [ ] Elastic Beanstalk CLI installed
- [ ] Node.js 20+ installed
- [ ] SendGrid account (free tier is fine)

---

## Step 1: Install Required Tools

### 1.1 Install AWS CLI

```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Download from: https://aws.amazon.com/cli/
```

### 1.2 Install Terraform

```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Windows
# Download from: https://www.terraform.io/downloads
```

### 1.3 Install Elastic Beanstalk CLI

```bash
pip install awsebcli --upgrade --user
```

### 1.4 Verify Installations

```bash
aws --version
terraform --version
eb --version
node --version
```

---

## Step 2: Configure AWS CLI

```bash
# Run AWS configuration
aws configure

# Enter your credentials:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region: us-east-1
# Default output format: json
```

**Verify it works:**
```bash
aws sts get-caller-identity
```

---

## Step 3: Verify Route53 Hosted Zone

```bash
# Check if your domain's hosted zone exists
aws route53 list-hosted-zones | grep trepidustech.com
```

**If it doesn't exist:**
1. Go to AWS Console → Route53
2. Create hosted zone for `trepidustech.com`
3. Update your domain registrar's nameservers to Route53's NS records

---

## Step 4: Create/Verify ACM Certificate

```bash
# Check for existing certificate
aws acm list-certificates --region us-east-1 | grep trepidustech.com
```

**If you don't have one, create it:**

```bash
# Request certificate
aws acm request-certificate \
  --domain-name trepidustech.com \
  --subject-alternative-names www.trepidustech.com \
  --validation-method DNS \
  --region us-east-1
```

**Then validate it:**
1. Go to AWS Console → Certificate Manager (us-east-1)
2. Click on your certificate
3. Copy the CNAME record details
4. Go to Route53 → Your hosted zone
5. Create the CNAME record
6. Wait 5-30 minutes for validation
7. Refresh until status shows "Issued"

---

## Step 5: Get SendGrid API Key

### 5.1 Create SendGrid Account

1. Go to https://signup.sendgrid.com/
2. Sign up (free tier: 100 emails/day)
3. Verify your email

### 5.2 Create API Key

1. Log in to SendGrid
2. Go to **Settings** → **API Keys**
3. Click **Create API Key**
4. Name: `trepidus-tech-production`
5. Permissions: **Restricted Access**
   - Mail Send: **Full Access**
   - All others: **No Access**
6. Click **Create & View**
7. **Copy the key immediately** (starts with `SG.`)

### 5.3 (Optional) Verify Domain

For better email deliverability:

1. Go to **Settings** → **Sender Authentication**
2. Click **Authenticate Your Domain**
3. Enter: `trepidustech.com`
4. Add the 3 CNAME records to Route53
5. Wait and click **Verify**

---

## Step 6: Configure Terraform

```bash
# Navigate to infrastructure directory
cd infra

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit the file
nano terraform.tfvars
```

**Update these values:**

```hcl
aws_region           = "us-east-1"
environment          = "production"
app_name             = "trepidus-tech"
domain_name          = "trepidustech.com"
create_www_redirect  = true
instance_type        = "t3.small"
min_instances        = 1
max_instances        = 4
vpc_id               = ""  # Leave empty for default VPC
sendgrid_api_key     = "SG.paste-your-actual-key-here"
```

**Save and secure the file:**
```bash
# Save file (Ctrl+X, then Y, then Enter if using nano)
chmod 600 terraform.tfvars
```

---

## Step 7: Initialize Terraform

```bash
# Still in infra/ directory
terraform init
```

You should see:
```
Terraform has been successfully initialized!
```

---

## Step 8: Review Terraform Plan

```bash
terraform plan
```

**Review the output:**
- Should show ~15 resources to create
- Check domain name is correct
- Verify certificate will be used
- Confirm instance types and counts

---

## Step 9: Deploy Infrastructure

```bash
terraform apply
```

**Follow the prompts:**
1. Review the resources to be created
2. Type `yes` when asked to confirm
3. Wait 10-15 minutes for deployment

**Expected output:**
```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:
domain_url = "https://trepidustech.com"
elastic_beanstalk_environment_name = "trepidus-tech-production"
...
```

**Save the outputs** - you'll need them later.

---

## Step 10: Build the Application

```bash
# Go back to project root
cd ..

# Install dependencies (if not already done)
npm install

# Build the application
npm run build
```

**Verify build succeeded:**
```bash
ls -la dist/
```

You should see:
- `index.js` (server)
- `public/` directory (frontend)

---

## Step 11: Initialize Elastic Beanstalk

```bash
# Initialize EB CLI
eb init -p "Node.js 20" trepidus-tech --region us-east-1
```

**Follow the prompts:**
1. Select your region (should already be set)
2. Use existing application: Yes
3. Do you want to set up SSH: No (or Yes if you want SSH access)

---

## Step 12: Deploy Application Code

```bash
# Deploy to the environment created by Terraform
eb deploy trepidus-tech-production
```

**This will:**
1. Package your application
2. Upload to S3
3. Deploy to Elastic Beanstalk
4. Run health checks

**Wait 5-10 minutes** for deployment to complete.

---

## Step 13: Check Deployment Status

```bash
# Check environment status
eb status

# View recent events
eb events

# Check environment health
eb health
```

**Expected status:**
```
Environment details for: trepidus-tech-production
  Status: Ready
  Health: Green
```

---

## Step 14: Verify DNS Resolution

```bash
# Check DNS is resolving
dig trepidustech.com

# Or use nslookup
nslookup trepidustech.com
```

**Note:** DNS may take 5-10 minutes to propagate.

---

## Step 15: Test Your Website

### 15.1 Test Health Endpoint

```bash
curl https://trepidustech.com/health
```

**Expected response:**
```json
{"status":"healthy"}
```

### 15.2 Visit Website in Browser

1. Open browser
2. Go to: https://trepidustech.com
3. Verify all sections load:
   - Hero
   - About
   - Services
   - **Products** (CloudCostGuardian)
   - **In-House Apps**
   - Team
   - Testimonials
   - Contact

### 15.3 Test Contact Form

1. Scroll to Contact section
2. Fill out the form:
   - Name: Test User
   - Email: your-email@example.com
   - Message: This is a test message
3. Click Submit
4. Check for success message
5. **Check your email** (including spam folder)

---

## Step 16: Monitor the Application

### View Logs

```bash
# Stream live logs
eb logs --stream

# Or download all logs
eb logs
```

### Check SendGrid Activity

1. Log in to SendGrid
2. Go to **Activity**
3. Verify emails are being sent

### CloudWatch Metrics

1. Go to AWS Console → CloudWatch
2. View metrics for your environment
3. Set up alarms if needed

---

## Troubleshooting

### Issue: Certificate not found

```bash
# Verify certificate exists and is ISSUED
aws acm describe-certificate \
  --certificate-arn $(aws acm list-certificates --region us-east-1 --query 'CertificateSummaryList[?DomainName==`trepidustech.com`].CertificateArn' --output text) \
  --region us-east-1
```

### Issue: DNS not resolving

```bash
# Check Route53 record
aws route53 list-resource-record-sets \
  --hosted-zone-id $(aws route53 list-hosted-zones --query 'HostedZones[?Name==`trepidustech.com.`].Id' --output text | cut -d'/' -f3)
```

### Issue: Health checks failing

```bash
# Check environment logs
eb logs

# Test health endpoint directly on EB URL
curl https://$(eb status | grep CNAME | awk '{print $2}')/health
```

### Issue: Emails not sending

1. Check SendGrid API key is correct
2. Verify environment variable:
   ```bash
   eb printenv
   ```
3. Check SendGrid Activity dashboard
4. Review application logs for errors

---

## Post-Deployment Tasks

### 1. Remove WordPress Site

Once you've verified everything works:

1. **Backup WordPress data** (if needed)
2. **Update DNS** if WordPress was on same domain
3. **Decommission old infrastructure**
4. **Cancel WordPress hosting** (if applicable)

### 2. Set Up Monitoring

```bash
# Create CloudWatch alarm for errors
aws cloudwatch put-metric-alarm \
  --alarm-name trepidus-tech-high-error-rate \
  --alarm-description "Alert on high error rate" \
  --metric-name 5XXError \
  --namespace AWS/ApplicationELB \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

### 3. Enable HTTPS Redirect (if not automatic)

The infrastructure already enforces HTTPS. Test:

```bash
# This should redirect to HTTPS
curl -I http://trepidustech.com
```

### 4. Set Up Backups

```bash
# Save EB configuration
eb config save trepidus-tech-production --cfg production-backup
```

---

## Updating the Application

When you make changes:

```bash
# 1. Make your changes
# 2. Build
npm run build

# 3. Deploy
eb deploy trepidus-tech-production

# 4. Verify
curl https://trepidustech.com/health
```

---

## Destroying Infrastructure (When Needed)

⚠️ **Warning:** This deletes everything!

```bash
# First, terminate EB environment via console or:
eb terminate trepidus-tech-production --force

# Then destroy Terraform resources
cd infra
terraform destroy
```

---

## Quick Reference Commands

```bash
# Check status
eb status

# View logs
eb logs --stream

# Redeploy
eb deploy trepidus-tech-production

# SSH into instance (if enabled)
eb ssh

# Check environment variables
eb printenv

# Scale up/down
eb scale 3  # Set to 3 instances
```

---

## Cost Monitoring

Check your AWS bill regularly:

```bash
# Get current month's costs
aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics UnblendedCost
```

**Expected monthly cost:** ~$50

---

## Support

If you run into issues:

1. Check application logs: `eb logs`
2. Check SendGrid activity dashboard
3. Review CloudWatch metrics
4. Check this guide's troubleshooting section
5. Review `infra/README.md` for detailed troubleshooting

---

## Success Checklist

- [ ] Terraform applied successfully
- [ ] EB environment is "Ready" and "Green"
- [ ] DNS resolves to your site
- [ ] HTTPS works (no certificate errors)
- [ ] All website sections load correctly
- [ ] Contact form sends emails successfully
- [ ] CloudWatch shows healthy metrics
- [ ] www subdomain works (if enabled)

**Congratulations! Your site is live!** 🎉

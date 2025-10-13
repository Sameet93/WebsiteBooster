# Trepidus Tech - Infrastructure Deployment Guide

Complete guide for deploying the Trepidus Tech website to AWS Elastic Beanstalk using Terraform.

## Prerequisites

Before you begin, ensure you have:

- [x] AWS Account with appropriate permissions
- [x] AWS CLI configured (`aws configure`)
- [x] Terraform installed (version 1.0+)
- [x] Elastic Beanstalk CLI installed (`pip install awsebcli`)
- [x] Node.js 20+ installed
- [x] Route53 hosted zone for `trepidustech.com`
- [x] ACM SSL certificate for `trepidustech.com` (in us-east-1 or your deployment region)
- [x] SendGrid account and API key

## Architecture Overview

This infrastructure deploys:

- **Elastic Beanstalk**: Node.js 20 application environment
- **Application Load Balancer**: HTTPS (443) with SSL certificate
- **Auto Scaling**: 1-4 t3.small instances
- **Route53**: DNS A record pointing to ALB
- **IAM Roles**: EC2 and service roles with proper permissions
- **CloudWatch**: Enhanced health monitoring and logging

## Quick Start

### 1. Verify Prerequisites

```bash
# Check AWS CLI
aws sts get-caller-identity

# Check Terraform
terraform version

# Check EB CLI
eb --version

# Verify Route53 hosted zone
aws route53 list-hosted-zones | grep trepidustech.com

# Verify ACM certificate
aws acm list-certificates --region us-east-1 | grep trepidustech.com
```

### 2. Configure Terraform Variables

```bash
cd infra

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Update `terraform.tfvars`:
```hcl
aws_region           = "us-east-1"
environment          = "production"
app_name             = "trepidus-tech"
domain_name          = "trepidustech.com"
create_www_redirect  = true
instance_type        = "t3.small"
min_instances        = 1
max_instances        = 4
sendgrid_api_key     = "SG.your-sendgrid-api-key-here"
```

### 3. Initialize Terraform

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Expected output:
# Plan: 15 to add, 0 to change, 0 to destroy
```

### 4. Deploy Infrastructure

```bash
# Apply Terraform configuration
terraform apply

# Type 'yes' to confirm
```

**Deployment time**: ~10-15 minutes

### 5. Build and Deploy Application

```bash
# Go back to project root
cd ..

# Build the application
npm run build

# Initialize EB (if not already done)
eb init -p "Node.js 20" trepidus-tech --region us-east-1

# Deploy application code
eb deploy trepidus-tech-production
```

### 6. Verify Deployment

```bash
# Check environment status
eb status

# View application URL
eb open

# Test health endpoint
curl -k https://trepidustech.com/health
```

## Detailed Setup Steps

### Step 1: AWS Certificate Manager (ACM)

If you don't have a certificate yet:

```bash
# Request a certificate (must be in us-east-1 for ALB)
aws acm request-certificate \
  --domain-name trepidustech.com \
  --subject-alternative-names www.trepidustech.com \
  --validation-method DNS \
  --region us-east-1
```

**Validate the certificate**:
1. Get validation CNAME record from ACM console
2. Add CNAME to Route53
3. Wait for validation (~5-30 minutes)

### Step 2: Route53 Hosted Zone

Verify your hosted zone exists:

```bash
aws route53 list-hosted-zones
```

If you need to create one:
1. Go to Route53 console
2. Create hosted zone for `trepidustech.com`
3. Update your domain registrar's nameservers to Route53's NS records

### Step 3: SendGrid Configuration

Follow the complete guide in [SENDGRID_SETUP.md](./SENDGRID_SETUP.md)

Quick steps:
1. Create SendGrid account
2. Generate API key with Mail Send permissions
3. (Optional) Verify your domain for better deliverability
4. Add API key to `terraform.tfvars`

### Step 4: Build Application

```bash
# Install dependencies
npm install

# Build for production
npm run build

# Verify build output
ls -la dist/
```

Expected output:
```
dist/
├── index.js           # Server bundle
└── public/           # Frontend assets
    ├── index.html
    └── assets/
```

### Step 5: Configure Elastic Beanstalk

The `.ebextensions` and `.elasticbeanstalk` directories are already configured.

Verify configuration files:
```bash
ls -la .ebextensions/
ls -la .elasticbeanstalk/
```

## Configuration Files

### Terraform Files

| File | Purpose |
|------|---------|
| `main.tf` | Main infrastructure (EB, Route53, ALB) |
| `iam.tf` | IAM roles and policies |
| `variables.tf` | Input variables |
| `outputs.tf` | Output values |
| `terraform.tfvars` | Your configuration (not in git) |

### Application Files

| File | Purpose |
|------|---------|
| `.ebextensions/01_nodecommand.config` | Node.js configuration |
| `.ebextensions/02_environment.config` | Environment variables |
| `.ebextensions/03_nginx.config` | Nginx optimization |
| `.ebextensions/04_healthcheck.config` | Health check settings |
| `.elasticbeanstalk/config.yml` | EB CLI configuration |
| `Procfile` | Process definition |

## Environment Variables

Set in Terraform (`main.tf`):

```hcl
NODE_ENV          = "production"
PORT              = "5000"
SENDGRID_API_KEY  = var.sendgrid_api_key
```

## Monitoring and Logs

### View Logs

```bash
# Request logs via EB CLI
eb logs

# Or download all logs
eb logs --all

# Stream live logs
eb logs --stream
```

### CloudWatch Logs

```bash
# View via AWS CLI
aws logs tail /aws/elasticbeanstalk/trepidus-tech-production/var/log/eb-engine.log --follow
```

### Health Monitoring

```bash
# Check environment health
eb health

# View detailed health
eb health --view
```

## Scaling Configuration

Current auto-scaling settings:
- **Min instances**: 1
- **Max instances**: 4
- **Instance type**: t3.small
- **Scaling metric**: CPU utilization (default)

### Modify Scaling

Edit `terraform.tfvars`:
```hcl
min_instances = 2  # Increase minimum
max_instances = 6  # Increase maximum
instance_type = "t3.medium"  # Larger instances
```

Apply changes:
```bash
terraform apply
```

## Domain Configuration

### DNS Records Created

Terraform automatically creates:

1. **A Record** (trepidustech.com)
   - Type: A (Alias)
   - Target: Elastic Beanstalk ALB

2. **A Record** (www.trepidustech.com) - optional
   - Type: A (Alias)
   - Target: Elastic Beanstalk ALB

### Verify DNS

```bash
# Check DNS resolution
dig trepidustech.com
dig www.trepidustech.com

# Or use nslookup
nslookup trepidustech.com
```

## SSL/HTTPS Configuration

- **Certificate**: ACM certificate for trepidustech.com
- **Protocol**: HTTPS (443) with HTTP (80) redirect
- **TLS Version**: TLS 1.2+ (configured in ALB)

### Test HTTPS

```bash
# Test SSL certificate
curl -vI https://trepidustech.com

# Verify HTTP redirect
curl -I http://trepidustech.com
```

## Updating the Application

### Method 1: EB CLI (Recommended)

```bash
# Make your code changes
# Build the application
npm run build

# Deploy
eb deploy trepidus-tech-production

# Monitor deployment
eb status
```

### Method 2: GitHub Actions

The repository includes GitHub Actions workflows for CI/CD.

1. Configure repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `SENDGRID_API_KEY`

2. Push to main branch:
   ```bash
   git push origin main
   ```

3. GitHub Actions will automatically deploy

## Troubleshooting

### Issue: Environment creation fails

```bash
# Check CloudFormation stack
aws cloudformation describe-stacks \
  --stack-name awseb-trepidus-tech-production \
  --region us-east-1

# Check EB events
eb events
```

### Issue: Health checks failing

```bash
# Verify health endpoint
curl https://your-eb-url.elasticbeanstalk.com/health

# Should return: {"status":"healthy"}

# Check application logs
eb logs
```

### Issue: SSL certificate not found

```bash
# List certificates
aws acm list-certificates --region us-east-1

# Verify certificate status
aws acm describe-certificate \
  --certificate-arn arn:aws:acm:... \
  --region us-east-1
```

### Issue: DNS not resolving

```bash
# Check Route53 record
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890ABC

# Verify nameservers at registrar match Route53
```

### Issue: Emails not sending

See [SENDGRID_SETUP.md](./SENDGRID_SETUP.md) troubleshooting section.

## Cost Estimation

### Monthly Costs (approximate)

| Resource | Cost |
|----------|------|
| EB Environment (t3.small) | ~$15/month |
| Application Load Balancer | ~$20/month |
| Data Transfer (100GB) | ~$9/month |
| Route53 Hosted Zone | $0.50/month |
| CloudWatch Logs (10GB) | ~$5/month |
| **Total** | **~$50/month** |

SendGrid: Free tier (100 emails/day)

### Cost Optimization

1. **Use t3.micro for low traffic**: $8/month vs $15/month
2. **Single instance during off-hours**: Reduce min instances
3. **Enable cost allocation tags**: Track spending
4. **Review CloudWatch retention**: Reduce log retention period

## Maintenance

### Regular Tasks

**Weekly**:
- [ ] Check application health
- [ ] Review CloudWatch metrics
- [ ] Check SendGrid email deliverability

**Monthly**:
- [ ] Review AWS costs
- [ ] Update dependencies
- [ ] Rotate SendGrid API keys (quarterly)
- [ ] Check SSL certificate expiry

**Quarterly**:
- [ ] Review and update security groups
- [ ] Update platform version
- [ ] Test disaster recovery

### Platform Updates

Elastic Beanstalk automatically updates:
- **Schedule**: Sundays at 10:00 UTC
- **Update level**: Minor updates
- **Method**: Rolling updates (zero downtime)

Disable auto-updates:
```hcl
# In main.tf
setting {
  namespace = "aws:elasticbeanstalk:managedactions"
  name      = "ManagedActionsEnabled"
  value     = "false"
}
```

## Backup and Disaster Recovery

### Application Code

- Stored in Git repository
- GitHub provides automatic backups

### Elastic Beanstalk Configuration

```bash
# Save EB configuration
eb config save trepidus-tech-production --cfg production-backup
```

### Database Backups

Currently not applicable (no database). If you add a database:
- Enable automated RDS backups
- Configure backup retention (7-30 days)

### Disaster Recovery Plan

1. **Full outage**: Deploy to new region using Terraform
2. **Partial outage**: Auto-scaling handles instance failures
3. **Data loss**: Restore from Git + EB configuration

## Security Best Practices

### Current Security Measures

- [x] HTTPS enforced with valid SSL certificate
- [x] IAM roles with least privilege
- [x] Enhanced health monitoring
- [x] Secrets in environment variables (not in code)
- [x] Regular security updates via managed platform updates

### Additional Recommendations

1. **Enable WAF**: Add AWS WAF for DDoS protection
2. **Set up CloudTrail**: Audit all API calls
3. **Enable GuardDuty**: Threat detection
4. **Implement rate limiting**: Protect contact form from abuse
5. **Regular security scans**: Use AWS Inspector

## Destroying Infrastructure

⚠️ **Warning**: This will delete all resources!

```bash
cd infra

# Destroy infrastructure
terraform destroy

# Type 'yes' to confirm
```

**Before destroying**:
1. Backup any important data
2. Download application logs
3. Export environment configuration
4. Update DNS to maintenance page

## Support and Resources

### Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Elastic Beanstalk Docs](https://docs.aws.amazon.com/elasticbeanstalk/)
- [SendGrid Documentation](https://docs.sendgrid.com/)

### AWS Support
- [AWS Support Center](https://console.aws.amazon.com/support/)
- [AWS Forums](https://forums.aws.amazon.com/)

### Internal Resources
- Project Repository: [GitHub]
- Team Contact: contact@trepidustech.com

## Next Steps

After successful deployment:

1. **Test the application thoroughly**
   - [ ] Visit https://trepidustech.com
   - [ ] Test contact form
   - [ ] Verify all sections load correctly
   - [ ] Check mobile responsiveness

2. **Set up monitoring alerts**
   - [ ] CloudWatch alarms for high CPU
   - [ ] SNS notifications for errors
   - [ ] SendGrid delivery monitoring

3. **Configure backups**
   - [ ] Save EB configuration
   - [ ] Document environment variables

4. **Remove WordPress site**
   - [ ] Backup WordPress data
   - [ ] Update DNS records
   - [ ] Decommission old infrastructure

5. **Optimize performance**
   - [ ] Enable CloudFront CDN
   - [ ] Configure caching headers
   - [ ] Minimize bundle sizes

---

**Questions or Issues?**

Contact: contact@trepidustech.com

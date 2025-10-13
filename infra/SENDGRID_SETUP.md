# SendGrid Email Setup Guide

This guide will help you configure SendGrid to send emails from your Trepidus Tech contact form.

## Prerequisites

- A SendGrid account (free tier available)
- Access to your domain's DNS settings (for authentication)

## Step 1: Create a SendGrid Account

1. Go to [SendGrid](https://signup.sendgrid.com/)
2. Sign up for a free account (100 emails/day free forever)
3. Complete email verification

## Step 2: Verify Your Domain (Recommended for Production)

Domain verification improves email deliverability and removes SendGrid branding.

1. **Navigate to Domain Authentication**
   - Log in to SendGrid
   - Go to **Settings** → **Sender Authentication**
   - Click **Authenticate Your Domain**

2. **Enter Your Domain**
   - Domain: `trepidustech.com`
   - Select DNS host: Choose your provider (Route53, GoDaddy, etc.)
   - Click **Next**

3. **Add DNS Records**
   - SendGrid will provide 3 CNAME records
   - Add these to your DNS (Route53 for trepidustech.com):
   
   ```
   Record 1: s1._domainkey.trepidustech.com → s1.domainkey.u12345.wl123.sendgrid.net
   Record 2: s2._domainkey.trepidustech.com → s2.domainkey.u12345.wl123.sendgrid.net
   Record 3: em1234.trepidustech.com → u12345.wl123.sendgrid.net
   ```

4. **Verify Records**
   - Wait 24-48 hours for DNS propagation (usually faster)
   - Click **Verify** in SendGrid dashboard
   - Status should change to **Verified**

## Step 3: Create a Sender Identity (Quick Start Alternative)

If you don't want to verify your domain immediately:

1. Go to **Settings** → **Sender Authentication**
2. Click **Create New Sender**
3. Fill in details:
   - **From Name**: Trepidus Tech
   - **From Email**: noreply@trepidustech.com (or your email)
   - **Reply To**: contact@trepidustech.com
   - **Company Address**: Your business address

4. Verify the email address sent to the From Email

## Step 4: Create an API Key

1. **Navigate to API Keys**
   - Go to **Settings** → **API Keys**
   - Click **Create API Key**

2. **Configure API Key**
   - **Name**: `trepidus-tech-production`
   - **Permissions**: Choose **Restricted Access**
     - Enable: **Mail Send** → **Full Access**
     - All others: **No Access**
   - Click **Create & View**

3. **Copy the API Key**
   - ⚠️ **IMPORTANT**: Copy the key immediately (it won't be shown again)
   - Format: `SG.xxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - Store securely - you'll need this for Terraform

## Step 5: Update Terraform Configuration

1. **Edit `terraform.tfvars`**
   ```bash
   cd infra
   cp terraform.tfvars.example terraform.tfvars
   nano terraform.tfvars
   ```

2. **Add your SendGrid API Key**
   ```hcl
   sendgrid_api_key = "SG.your-actual-api-key-here"
   ```

3. **Save and secure the file**
   ```bash
   # Ensure terraform.tfvars is in .gitignore
   chmod 600 terraform.tfvars
   ```

## Step 6: Test Email Configuration

After deployment, test the contact form:

1. Visit https://trepidustech.com
2. Navigate to the **Contact** section
3. Fill out the form with test data
4. Submit the form

### Troubleshooting

**Emails not sending?**

1. **Check SendGrid Activity**
   - Go to **Activity** in SendGrid dashboard
   - Look for recent send attempts
   - Check delivery status

2. **Check Application Logs**
   ```bash
   # View Elastic Beanstalk logs
   eb logs
   
   # Or use AWS Console
   # Elastic Beanstalk → Your Environment → Logs → Request Logs
   ```

3. **Common Issues**
   - **401 Unauthorized**: API key is incorrect
   - **403 Forbidden**: API key lacks Mail Send permissions
   - **Sender address rejected**: From address not verified

4. **Verify Environment Variable**
   ```bash
   # Check if SENDGRID_API_KEY is set in EB environment
   eb printenv
   ```

## Email Best Practices

### 1. From Address
- Use a verified domain email: `noreply@trepidustech.com`
- Avoid generic addresses like `admin@` or `webmaster@`

### 2. Reply-To Address
- Set a monitored email for replies: `contact@trepidustech.com`

### 3. Email Content
- Include unsubscribe link for marketing emails
- Add physical business address in footer
- Keep subject lines clear and relevant

### 4. Monitor Deliverability
- Check **Email Activity** dashboard weekly
- Monitor bounce and spam rates
- Keep bounce rate below 5%

## DNS Records for trepidustech.com (Route53)

After domain verification, your Route53 should have these records:

```
Type: CNAME
Name: s1._domainkey.trepidustech.com
Value: [SendGrid CNAME from dashboard]

Type: CNAME
Name: s2._domainkey.trepidustech.com
Value: [SendGrid CNAME from dashboard]

Type: CNAME
Name: em[####].trepidustech.com
Value: [SendGrid CNAME from dashboard]
```

## Cost Considerations

### SendGrid Free Tier
- **100 emails/day** forever free
- 2,000 contacts
- Email API access
- Basic email validation

### Paid Plans (if needed)
- **Essentials**: $19.95/month (50,000 emails/month)
- **Pro**: $89.95/month (1.5M emails/month)
- Only upgrade if you exceed free tier

## Security Best Practices

1. **Never commit API keys to Git**
   - Keep `terraform.tfvars` in `.gitignore`
   - Use environment variables for CI/CD

2. **Use Restricted API Keys**
   - Only grant necessary permissions (Mail Send only)
   - Create separate keys for dev/staging/production

3. **Rotate Keys Regularly**
   - Rotate API keys every 90 days
   - Delete unused keys immediately

4. **Monitor Usage**
   - Set up alerts for unusual activity
   - Review API key usage monthly

## Support Resources

- [SendGrid Documentation](https://docs.sendgrid.com/)
- [SendGrid Status](https://status.sendgrid.com/)
- [API Reference](https://docs.sendgrid.com/api-reference)
- [SendGrid Support](https://support.sendgrid.com/)

## Quick Reference

### Environment Variables
```bash
SENDGRID_API_KEY=SG.xxxxxx...  # Required for email sending
```

### Test Email Command (after deployment)
```bash
curl -X POST https://trepidustech.com/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "message": "This is a test message"
  }'
```

### Check SendGrid Stats
```bash
# Using SendGrid API (requires API key with stats permission)
curl -X GET "https://api.sendgrid.com/v3/stats" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

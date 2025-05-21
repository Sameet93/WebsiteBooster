# AWS Elastic Beanstalk Deployment Guide

This guide provides detailed instructions for deploying the Trepidus Tech website to AWS Elastic Beanstalk.

## What is AWS Elastic Beanstalk?

AWS Elastic Beanstalk is an easy-to-use service for deploying and scaling web applications. It handles the infrastructure details like capacity provisioning, load balancing, auto-scaling, and application health monitoring, allowing you to focus on your code.

## Prerequisites

Before you begin, ensure you have the following:

1. AWS account with appropriate permissions
2. AWS CLI installed and configured with your credentials
3. Elastic Beanstalk CLI installed (`pip install awsebcli`)
4. SendGrid account and API key (for contact form functionality)

## Quick Deployment

For a quick deployment, simply use the provided script:

```bash
./deploy-to-eb.sh [region] [environment] [sendgrid-api-key]
```

Example:
```bash
./deploy-to-eb.sh us-east-1 production your-sendgrid-api-key
```

This script will:
1. Build your application
2. Initialize Elastic Beanstalk (if needed)
3. Create an environment (if it doesn't exist)
4. Set necessary environment variables
5. Deploy your application

## Manual Deployment Steps

If you prefer manual deployment, follow these steps:

### 1. Install the Elastic Beanstalk CLI

```bash
pip install awsebcli
```

### 2. Initialize Your EB Environment

```bash
eb init --region us-east-1 --platform "Node.js 20" trepidus-tech
```

### 3. Create an Environment

```bash
eb create production --instance-type t3.small --single
```

### 4. Set Environment Variables

```bash
eb setenv NODE_ENV=production SENDGRID_API_KEY=your-sendgrid-api-key
```

### 5. Deploy Your Application

```bash
eb deploy production
```

### 6. Open Your Application

```bash
eb open
```

## Configuration Details

The repository includes several important configuration files for Elastic Beanstalk:

- `.elasticbeanstalk/config.yml`: Core EB configuration
- `.ebextensions/01_nodecommand.config`: Node.js configuration
- `.ebextensions/02_environment.config`: Environment variables
- `.ebextensions/03_nginx.config`: Nginx configuration for performance
- `.ebextensions/04_healthcheck.config`: Health check settings
- `Procfile`: Defines how to start the application

## Common Operations

### Viewing Logs

```bash
eb logs
```

### SSH into the Instance

```bash
eb ssh
```

### Terminating an Environment

```bash
eb terminate environment-name
```

### Updating Environment Variables

```bash
eb setenv SENDGRID_API_KEY=new-api-key
```

## Monitoring and Scaling

### Monitoring

Access the AWS Elastic Beanstalk Console to monitor:
- CPU utilization
- Network I/O
- Application health
- Environment events

### Scaling

1. Navigate to your environment in the EB Console
2. Select "Configuration" from the left menu
3. Under "Capacity", click "Edit"
4. Configure auto-scaling settings as needed

## Troubleshooting

### Common Issues

1. **Deployment failures**: 
   - Check the deployment logs: `eb logs`
   - Ensure your application builds successfully locally

2. **Health check failures**:
   - Verify the `/health` endpoint is working
   - Check that your app is running on the correct port (5000)

3. **Email not working**:
   - Ensure the SendGrid API key is set correctly
   - Verify that your SendGrid account is active

## Multiple Environments

For a development/staging/production workflow:

1. Create separate environments:
   ```bash
   eb create development
   eb create staging
   ```

2. Deploy to a specific environment:
   ```bash
   eb deploy environment-name
   ```

## Security Best Practices

1. Always store sensitive information like API keys in environment variables, not in code
2. Use IAM roles with least privilege access
3. Enable HTTPS for production environments
4. Regularly update dependencies to patch security vulnerabilities
5. Configure security groups to restrict access as needed
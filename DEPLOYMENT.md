# Deployment Guide for Trepidus Tech Website

This guide provides detailed instructions for deploying the Trepidus Tech website to AWS using Docker containers.

## Prerequisites

Before you begin, ensure you have the following:

1. AWS account with appropriate permissions
2. AWS CLI installed and configured with your credentials
3. Docker installed on your local machine
4. SendGrid account and API key (for contact form functionality)

## Deployment Options

There are several options for deploying this application to AWS:

### Option 1: Manual Deployment with ECR and ECS

#### Step 1: Set Up Required Variables

Create a `.env` file based on the provided `.env.example` file:

```
NODE_ENV=production
SENDGRID_API_KEY=your_sendgrid_api_key
```

#### Step 2: Build and Push Docker Image

1. Build the Docker image:
   ```
   docker build -t trepidus-tech-website .
   ```

2. Tag and push to Amazon ECR:
   ```
   # Login to ECR
   aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com

   # Create a repository
   aws ecr create-repository --repository-name trepidus-tech-website --region <your-region>

   # Tag the image
   docker tag trepidus-tech-website:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/trepidus-tech-website:latest

   # Push the image
   docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/trepidus-tech-website:latest
   ```

#### Step 3: Deploy to ECS

1. Update the AWS ECS task definition file (`aws-ecs-task-definition.json`) with your AWS account ID and region
2. Store your SendGrid API key securely in AWS Systems Manager Parameter Store:
   ```
   aws ssm put-parameter --name /trepidus-tech/SENDGRID_API_KEY --value "your-sendgrid-api-key" --type SecureString --region <your-region>
   ```
3. Register the task definition:
   ```
   aws ecs register-task-definition --cli-input-json file://aws-ecs-task-definition.json --region <your-region>
   ```
4. Create an ECS cluster (if you don't have one):
   ```
   aws ecs create-cluster --cluster-name production --region <your-region>
   ```
5. Create a service in the cluster:
   ```
   aws ecs create-service \
     --cluster production \
     --service-name trepidus-tech-website \
     --task-definition trepidus-tech-website \
     --desired-count 1 \
     --launch-type FARGATE \
     --network-configuration "awsvpcConfiguration={subnets=[<subnet-id>],securityGroups=[<security-group-id>],assignPublicIp=ENABLED}" \
     --region <your-region>
   ```

### Option 2: Using the Automated Script

We've prepared a script to simplify deployment:

1. Make the script executable:
   ```
   chmod +x deploy-to-aws.sh
   ```

2. Run the script with your region and account ID:
   ```
   ./deploy-to-aws.sh <aws-region> <aws-account-id>
   ```

3. The script will build, tag, and push the Docker image to ECR, and register the task definition

4. After the script completes, follow the provided command to update your ECS service

### Option 3: Using GitHub Actions CI/CD Pipeline

1. Fork this repository to your GitHub account
2. Add the following secrets to your GitHub repository:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. Update the values in `.github/workflows/aws-deploy.yml` to match your AWS configuration:
   - `AWS_REGION`
   - `ECS_CLUSTER`
   - `ECS_SERVICE`
4. Store your SendGrid API key in AWS Systems Manager Parameter Store as in Option 1
5. Push to your main branch, and the GitHub Action will automatically deploy to AWS

## Post-Deployment Setup

### Setting Up a Domain Name

1. Register a domain in AWS Route 53 (or use an existing domain)
2. Create a hosted zone for your domain
3. Set up an Application Load Balancer (ALB) for your ECS service
4. Create an ALIAS record in Route 53 pointing to your ALB

### Setting Up SSL/TLS

1. Request a certificate in AWS Certificate Manager (ACM)
2. Configure your ALB to use the certificate
3. Ensure your ALB security group allows HTTPS traffic (port 443)

## Troubleshooting

### Common Issues

1. **Contact form not sending emails**: Check that the SendGrid API key is correctly set in Parameter Store and properly referenced in the task definition

2. **Container health check failing**: Check logs in CloudWatch Logs to identify the issue:
   ```
   aws logs get-log-events --log-group-name /ecs/trepidus-tech-website --log-stream-name <log-stream-name> --region <your-region>
   ```

3. **Website not accessible**: Check security groups, network configuration, and load balancer settings

## Monitoring and Maintenance

### Monitoring

- Set up CloudWatch Alarms to monitor the application and alert on issues
- Consider setting up a dashboard with key metrics

### Scaling

To scale the application:
```
aws ecs update-service --cluster production --service trepidus-tech-website --desired-count <number> --region <your-region>
```

### Updates

To deploy updates:
1. Make changes to the codebase
2. Build a new Docker image
3. Push to ECR with a new tag
4. Update the ECS service to use the new image

## Security Best Practices

1. Always store sensitive information like API keys in AWS Systems Manager Parameter Store or AWS Secrets Manager
2. Use IAM roles with least privilege access
3. Keep Docker images updated with security patches
4. Enable AWS CloudTrail to monitor API activity
5. Regularly review security groups and access permissions
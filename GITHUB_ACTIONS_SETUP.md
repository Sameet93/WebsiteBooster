# GitHub Actions Setup Guide

This guide provides step-by-step instructions for setting up GitHub Actions CI/CD for the Trepidus Tech website.

## Introduction

The project includes multiple GitHub Actions workflows for:
- Testing code changes
- Building and testing Docker images
- Deploying to AWS
- Setting up infrastructure
- Creating additional environments

## Initial Setup

### 1. Fork or Push the Repository to GitHub

Ensure your repository is on GitHub to use GitHub Actions:
```bash
git remote add origin https://github.com/yourusername/trepidus-tech-website.git
git push -u origin main
```

### 2. Configure Repository Secrets

In your GitHub repository:
1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Add the following repository secrets:

| Name | Description |
|------|-------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key with appropriate permissions |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret access key |

The IAM user associated with these credentials should have permissions for:
- Amazon ECR (Elastic Container Registry)
- Amazon ECS (Elastic Container Service)
- AWS Systems Manager Parameter Store
- Amazon EC2 (if using load balancers)
- Amazon VPC (if creating networking resources)

### 3. Create GitHub Environments (Optional)

For production deployment safeguards:
1. Go to **Settings** > **Environments**
2. Create a new environment named `production`
3. Configure required reviewers or other protection rules
4. Add environment-specific secrets if needed

## Using the Workflows

### Running Tests

Tests run automatically on every push and pull request:
1. Push code to any branch or create a pull request
2. GitHub Actions will run the `test.yml` workflow
3. Check the results in the **Actions** tab

### Deploying to AWS

#### One-Time Infrastructure Setup

Before your first deployment:
1. Go to the **Actions** tab in your repository
2. Select the **AWS Environment Setup** workflow
3. Click **Run workflow**
4. Fill in the parameters:
   - AWS Region (e.g., `us-east-1`)
   - ECS Cluster Name (e.g., `production`)
   - Service Name (e.g., `trepidus-tech-website`)
   - Choose whether to create a load balancer
5. Click **Run workflow**

#### Production Deployment

Deployment happens automatically when you push to the `main` branch, or:
1. Go to the **Actions** tab
2. Select the **Deploy to AWS** workflow
3. Click **Run workflow**
4. Click **Run workflow** again to confirm

#### Creating Additional Environments

To create a staging or development environment:
1. Go to the **Actions** tab
2. Select the **Create Custom Environment** workflow
3. Click **Run workflow**
4. Fill in the parameters:
   - Environment name (e.g., `staging`, `dev`)
   - AWS Region
   - Cluster Name
   - Whether to create new resources
5. Click **Run workflow**
6. Follow the instructions in the workflow output to complete setup

### Viewing Workflow Results

To check the status of any workflow:
1. Go to the **Actions** tab
2. Click on the workflow run you want to examine
3. Expand the job steps to see detailed logs
4. For deployment workflows, the final step will provide deployment URLs

## Workflow Files

| Filename | Purpose |
|----------|---------|
| `.github/workflows/test.yml` | Runs tests for all branches and PRs |
| `.github/workflows/aws-deploy.yml` | Deploys to production environment |
| `.github/workflows/aws-setup.yml` | One-time AWS infrastructure setup |
| `.github/workflows/create-environment.yml` | Creates additional environments |

## Troubleshooting

### Common Issues

1. **Workflow failing with AWS authentication errors**:
   - Verify your AWS credentials are correctly set as repository secrets
   - Ensure the IAM user has the necessary permissions

2. **ECS deployment failing**:
   - Check that the ECS cluster and service exist
   - Verify the task definition is valid
   - Check CloudWatch Logs for container errors

3. **Missing SendGrid API Key**:
   - Store your SendGrid API key in AWS Systems Manager Parameter Store:
     ```bash
     aws ssm put-parameter \
       --name /trepidus-tech/SENDGRID_API_KEY \
       --value "your-sendgrid-api-key" \
       --type SecureString \
       --region your-region
     ```

4. **Testing environment before production**:
   - Create a staging environment using the `create-environment.yml` workflow
   - Test changes there before merging to main for production deployment

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
- [Detailed Deployment Guide](./DEPLOYMENT.md)
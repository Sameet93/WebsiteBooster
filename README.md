# Trepidus Tech Website

This is the official website for Trepidus Tech, featuring their IT consulting services, team, and testimonials.

## Features

- Responsive design optimized for all devices
- Fast loading and performance
- Team member profiles with images
- Testimonials from satisfied clients
- Services overview
- Contact form with email functionality

## Technologies Used

- React with TypeScript
- Express.js backend
- SendGrid for email functionality
- Docker for containerization
- Tailwind CSS for styling
- React Query for data fetching
- GitHub Actions for CI/CD

## Development

### Prerequisites

- Node.js 20.x or higher
- npm or yarn
- Docker and Docker Compose (for containerization)

### Local Development

1. Clone the repository
2. Install dependencies:
   ```
   npm install
   ```
3. Create a `.env` file with the required environment variables:
   ```
   SENDGRID_API_KEY=your_sendgrid_api_key
   ```
4. Start the development server:
   ```
   npm run dev
   ```

## Deployment

### CI/CD with GitHub Actions

This project includes several GitHub Actions workflows for automated testing and deployment:

1. **Test Workflow** (`.github/workflows/test.yml`)
   - Runs on all pull requests and branch pushes (except main)
   - Performs linting, type checking, and API tests
   - Builds and tests Docker image

2. **AWS Deployment Workflow** (`.github/workflows/aws-deploy.yml`)
   - Runs on pushes to main branch and manual triggers
   - Performs testing, builds Docker image
   - Deploys to AWS ECS
   - Performs post-deployment verification

3. **AWS Infrastructure Setup** (`.github/workflows/aws-setup.yml`)
   - Sets up required AWS infrastructure (one-time setup)
   - Creates ECR repository, ECS cluster, and load balancer
   - Can be triggered manually with custom parameters

4. **Environment Creation** (`.github/workflows/create-environment.yml`)
   - Creates additional environments (staging, dev, etc.)
   - Sets up necessary AWS resources
   - Generates deployment workflow for the environment

### Required GitHub Secrets

To use the CI/CD workflows, add these secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### Manual Deployment with Docker

1. Build the Docker image:
   ```
   docker build -t trepidus-tech-website .
   ```

2. Test locally with Docker Compose:
   ```
   docker-compose up
   ```

3. Push to Amazon ECR (Elastic Container Registry):
   ```
   # Login to ECR
   aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com

   # Create a repository if you haven't already
   aws ecr create-repository --repository-name trepidus-tech-website --region <your-region>

   # Tag the image
   docker tag trepidus-tech-website:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/trepidus-tech-website:latest

   # Push the image
   docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/trepidus-tech-website:latest
   ```

### Using the Deployment Script

A helper script is included to simplify deployment:

```
./deploy-to-aws.sh <aws-region> <aws-account-id>
```

This script handles building, tagging, and pushing the Docker image, and updating the ECS task definition.

### Advanced Deployment Options

For more advanced deployment options and detailed instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md).

## Environment Variables

- `NODE_ENV`: Set to "production" for production environment
- `SENDGRID_API_KEY`: Your SendGrid API key for email functionality

## Testing

Run API tests using the included test script:

```
./tests/api.sh
```

This tests the health endpoint and contact form API.

## Multi-Environment Setup

The project supports multiple environments (development, staging, production):

1. Use the `create-environment.yml` workflow to create new environments
2. Each environment gets its own ECS service and ECR repository
3. Branch-based deployments can be set up for each environment

## Contact

For any questions or inquiries, please contact [info@trepidustech.com](mailto:info@trepidustech.com).
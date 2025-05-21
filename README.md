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

### AWS Elastic Beanstalk Deployment

This project is configured for easy deployment to AWS Elastic Beanstalk:

1. **Quick Deployment with Script**
   ```bash
   ./deploy-to-eb.sh [region] [environment] [sendgrid-api-key]
   ```
   
   Example:
   ```bash
   ./deploy-to-eb.sh us-east-1 production your-sendgrid-api-key
   ```

2. **Manual Deployment with EB CLI**
   ```bash
   # Install EB CLI if you haven't already
   pip install awsebcli
   
   # Initialize EB (first time only)
   eb init --region us-east-1 --platform "Node.js 20" trepidus-tech
   
   # Create environment (first time only)
   eb create production
   
   # Set environment variables
   eb setenv NODE_ENV=production SENDGRID_API_KEY=your-sendgrid-api-key
   
   # Deploy your application
   eb deploy
   
   # Open your application in a browser
   eb open
   ```

### EB Configuration Details

The repository includes several important configuration files for Elastic Beanstalk:

- `.elasticbeanstalk/config.yml`: Core EB configuration
- `.ebextensions/*.config`: Server configuration and environment settings
- `Procfile`: Defines how to start the application

### Using GitHub Actions with Elastic Beanstalk

If you prefer automated deployments, you can use GitHub Actions with Elastic Beanstalk:

1. **Test Workflow** (`.github/workflows/test.yml`)
   - Runs tests for all pull requests and branch pushes

2. You can add your own EB deployment workflow using the AWS Elastic Beanstalk GitHub Action

### Required AWS Permissions

To deploy to Elastic Beanstalk, ensure your AWS user has:

- `AWSElasticBeanstalkFullAccess` permissions
- Appropriate IAM, S3, and EC2 permissions

### Alternative Deployment Options

The project also includes Docker configuration for containerized deployment:

```bash
# Build and run locally with Docker
docker build -t trepidus-tech-website .
docker run -p 5000:5000 trepidus-tech-website
```

### Advanced Deployment Documentation

For more detailed instructions on EB deployment, see [EB_DEPLOYMENT.md](./EB_DEPLOYMENT.md).

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
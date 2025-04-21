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

## Deployment to AWS

### Using Docker

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

4. Deploy on AWS using one of these services:
   - **Amazon ECS (Elastic Container Service)**: For container orchestration
   - **AWS App Runner**: For a simpler deployment process
   - **Amazon EKS (Elastic Kubernetes Service)**: For Kubernetes-based deployment
   - **AWS Fargate**: For serverless container deployment

### Example ECS Deployment

1. Create an ECS cluster
2. Create a task definition using your ECR image
3. Configure environment variables in the task definition:
   ```
   SENDGRID_API_KEY=your_sendgrid_api_key
   NODE_ENV=production
   ```
4. Create a service in your cluster using the task definition
5. Set up load balancing and auto-scaling as needed

### Using AWS Elastic Beanstalk (Alternative)

1. Install the AWS EB CLI:
   ```
   pip install awsebcli
   ```

2. Initialize Elastic Beanstalk in your project:
   ```
   eb init
   ```

3. Create an environment:
   ```
   eb create
   ```

4. Set environment variables:
   ```
   eb setenv SENDGRID_API_KEY=your_sendgrid_api_key NODE_ENV=production
   ```

5. Deploy the application:
   ```
   eb deploy
   ```

## Environment Variables

- `NODE_ENV`: Set to "production" for production environment
- `SENDGRID_API_KEY`: Your SendGrid API key for email functionality

## Contact

For any questions or inquiries, please contact [info@trepidustech.com](mailto:info@trepidustech.com).
#!/bin/bash

# AWS Deployment Script for Trepidus Tech Website
# Usage: ./deploy-to-aws.sh <aws-region> <aws-account-id>

# Exit on any error
set -e

# Variables
AWS_REGION=$1
AWS_ACCOUNT_ID=$2
ECR_REPOSITORY="trepidus-tech-website"
IMAGE_TAG="latest"

# Check for required arguments
if [ -z "$AWS_REGION" ] || [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Usage: ./deploy-to-aws.sh <aws-region> <aws-account-id>"
  exit 1
fi

# Build the Docker image
echo "Building Docker image..."
docker build -t $ECR_REPOSITORY:$IMAGE_TAG .

# Log in to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Create ECR repository if it doesn't exist
echo "Checking for ECR repository..."
aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION || \
  aws ecr create-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION

# Tag and push the image
echo "Tagging and pushing image to ECR..."
docker tag $ECR_REPOSITORY:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG

# Update ECS task definition
echo "Updating the ECS task definition template..."
sed -i "s/<your-account-id>/$AWS_ACCOUNT_ID/g" aws-ecs-task-definition.json
sed -i "s/<your-region>/$AWS_REGION/g" aws-ecs-task-definition.json

# Register new task definition
echo "Registering new ECS task definition..."
aws ecs register-task-definition --cli-input-json file://aws-ecs-task-definition.json --region $AWS_REGION

# Get the latest task definition revision
TASK_REVISION=$(aws ecs describe-task-definition --task-definition $ECR_REPOSITORY --region $AWS_REGION | jq .taskDefinition.revision)

echo "Task definition registered with revision: $TASK_REVISION"
echo ""
echo "To update your ECS service, run:"
echo "aws ecs update-service --cluster <your-cluster-name> --service <your-service-name> --task-definition $ECR_REPOSITORY:$TASK_REVISION --region $AWS_REGION"
echo ""
echo "Deployment preparation complete!"
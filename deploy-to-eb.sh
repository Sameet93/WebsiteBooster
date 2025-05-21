#!/bin/bash

# Deployment script for AWS Elastic Beanstalk

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    echo "Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check if EB CLI is installed
if ! command -v eb &> /dev/null; then
    echo -e "${YELLOW}Elastic Beanstalk CLI is not installed. Installing...${NC}"
    pip install awsebcli
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install EB CLI. Please install it manually.${NC}"
        echo "Run: pip install awsebcli"
        exit 1
    fi
fi

# Get AWS region
if [ -z "$1" ]; then
    read -p "Enter AWS region (default: us-east-1): " AWS_REGION
    AWS_REGION=${AWS_REGION:-us-east-1}
else
    AWS_REGION=$1
fi

# Get environment name
if [ -z "$2" ]; then
    read -p "Enter environment name (default: production): " ENV_NAME
    ENV_NAME=${ENV_NAME:-production}
else
    ENV_NAME=$2
fi

# Get SendGrid API key if provided
SENDGRID_API_KEY=$3

echo -e "\n${YELLOW}=== Deploying Trepidus Tech Website to AWS Elastic Beanstalk ===${NC}"
echo -e "${YELLOW}Region: ${NC}$AWS_REGION"
echo -e "${YELLOW}Environment: ${NC}$ENV_NAME"

# Build the application
echo -e "\n${YELLOW}Building the application...${NC}"
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed. Please fix the errors and try again.${NC}"
    exit 1
fi

# Initialize Elastic Beanstalk if not already done
if [ ! -d .elasticbeanstalk ]; then
    echo -e "\n${YELLOW}Initializing Elastic Beanstalk...${NC}"
    eb init --region $AWS_REGION --platform "Node.js 20" trepidus-tech
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to initialize Elastic Beanstalk. Please check your AWS credentials.${NC}"
        exit 1
    fi
fi

# Create environment if it doesn't exist
EB_ENV_EXISTS=$(eb list | grep $ENV_NAME)
if [ -z "$EB_ENV_EXISTS" ]; then
    echo -e "\n${YELLOW}Creating Elastic Beanstalk environment $ENV_NAME...${NC}"
    eb create $ENV_NAME --region $AWS_REGION --instance-type t3.small --single
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create Elastic Beanstalk environment. Please check the logs.${NC}"
        exit 1
    fi
fi

# Set environment variables
echo -e "\n${YELLOW}Setting environment variables...${NC}"
eb setenv NODE_ENV=production

# Set SendGrid API key if provided
if [ ! -z "$SENDGRID_API_KEY" ]; then
    eb setenv SENDGRID_API_KEY=$SENDGRID_API_KEY
    echo -e "${GREEN}SendGrid API key has been set.${NC}"
else
    echo -e "${YELLOW}No SendGrid API key provided. Contact form will not send emails.${NC}"
    echo -e "${YELLOW}You can set it later using: eb setenv SENDGRID_API_KEY=your_key${NC}"
fi

# Deploy the application
echo -e "\n${YELLOW}Deploying to Elastic Beanstalk...${NC}"
eb deploy $ENV_NAME

if [ $? -ne 0 ]; then
    echo -e "${RED}Deployment failed. Please check the logs.${NC}"
    exit 1
fi

# Get the environment URL
ENV_URL=$(eb status $ENV_NAME | grep CNAME | awk '{print $2}')

echo -e "\n${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}Your application is available at: ${NC}http://$ENV_URL"
echo -e "\n${YELLOW}To view logs:${NC} eb logs $ENV_NAME"
echo -e "${YELLOW}To open the application:${NC} eb open $ENV_NAME"
echo -e "${YELLOW}To terminate the environment:${NC} eb terminate $ENV_NAME"
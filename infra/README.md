This Terraform module provisions resources to run the application on Elastic Beanstalk (containerized) in eu-west-1.

It creates:
- ECR repository for your container image
- S3 bucket to hold Elastic Beanstalk application versions
- ACM certificate (DNS validated via Route53) if `certificate_request` is true
- IAM roles required for EB
- Elastic Beanstalk application and environment
- Route53 records (apex and optional www) pointing to the EB environment

Usage:
1. Set `domain_name` and `hosted_zone_id` either via a `terraform.tfvars` file or environment variables.
2. Run `terraform init` and `terraform apply`.
3. Use `deploy.sh` to build and push your Docker image to ECR and create an application version for EB.

Note: `deploy.sh` requires AWS CLI v2 with credentials configured for the target account/region.

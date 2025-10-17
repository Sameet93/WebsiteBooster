variable "aws_region" {
  description = "AWS region for all resources (must be eu-west-1)"
  type        = string
  default     = "eu-west-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "websitebooster"
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Domain name for the application (must match Route53 hosted zone)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for the domain"
  type        = string
}

variable "create_www_redirect" {
  description = "Create www subdomain pointing to main domain"
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type for Elastic Beanstalk"
  type        = string
  default     = "t3.small"
}

variable "solution_stack_name" {
  description = "Elastic Beanstalk solution stack name (platform). Override if a specific platform is required."
  type        = string
  # Default to an Amazon Linux 2 Docker platform which is widely available. You can override in terraform.tfvars
  default = "64bit Amazon Linux 2023 v4.7.2 running Docker"
}

variable "min_instances" {
  description = "Minimum number of instances in Auto Scaling group"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances in Auto Scaling group"
  type        = number
  default     = 4
}

variable "vpc_id" {
  description = "VPC ID (leave empty to use default VPC)"
  type        = string
  default     = ""
}

variable "sendgrid_api_key" {
  description = "SendGrid API key for email sending"
  type        = string
  sensitive   = true
  default     = ""
}

variable "certificate_request" {
  description = "If true, create ACM certificate in eu-west-1 using DNS validation"
  type        = bool
  default     = true
}

variable "existing_acm_arn" {
  description = "If set, use this existing ACM certificate ARN instead of creating a new one"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}


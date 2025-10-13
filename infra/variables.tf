variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "trepidus-tech"
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Domain name for the application (must match Route53 hosted zone)"
  type        = string
  default     = "trepidustech.com"
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
}

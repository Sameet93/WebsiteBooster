terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge({
      Project     = var.app_name
      ManagedBy   = "Terraform"
      Environment = var.environment
    }, var.tags)
  }
}

# Data source for existing Route53 zone: allow lookup by hosted_zone_id or by domain name
data "aws_route53_zone" "by_id" {
  count   = var.hosted_zone_id != "" ? 1 : 0
  zone_id = var.hosted_zone_id
}

data "aws_route53_zone" "by_name" {
  count        = var.hosted_zone_id == "" ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

locals {
  route53_zone_id = var.hosted_zone_id != "" ? data.aws_route53_zone.by_id[0].zone_id : data.aws_route53_zone.by_name[0].zone_id
}

# Create an ECR repository for container images
resource "aws_ecr_repository" "app" {
  name                 = "${var.app_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "${var.app_name}-${var.environment}-ecr"
  }
}

# S3 bucket to store Elastic Beanstalk application versions
resource "aws_s3_bucket" "eb_app_versions" {
  bucket = "${replace(var.app_name, "_", "-")}-${var.environment}-eb-app-versions-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.app_name}-${var.environment}-eb-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "eb_app_versions" {
  bucket = aws_s3_bucket.eb_app_versions.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "eb_app_versions_policy" {
  bucket = aws_s3_bucket.eb_app_versions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyNonAccountPrincipals"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.eb_app_versions.arn}",
          "${aws_s3_bucket.eb_app_versions.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "eb_app_versions" {
  bucket = aws_s3_bucket.eb_app_versions.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 30
    }
  }
}

data "aws_caller_identity" "current" {}

# Try to discover an existing ISSUED ACM certificate for the domain in the region.
# This will succeed if at least one ISSUED certificate for the domain exists in the account/region.
data "aws_acm_certificate" "by_domain" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

## ACM certificate in the same region (eu-west-1) - DNS validated using Route53
locals {
  certificate_arn = var.existing_acm_arn != "" ? var.existing_acm_arn : (try(data.aws_acm_certificate.by_domain.arn, "") != "" ? data.aws_acm_certificate.by_domain.arn : try(aws_acm_certificate.cert[0].arn, ""))
}

resource "aws_acm_certificate" "cert" {
  # Create a certificate only when the user didn't provide an existing ARN
  # and when no ISSUED certificate for the domain was discovered.
  count = var.existing_acm_arn != "" ? 0 : (var.certificate_request && try(data.aws_acm_certificate.by_domain.arn, "") == "" ? 1 : 0)

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  # If a new ACM certificate was created, its domain_validation_options are used to create
  # DNS records. We use try(...) so this resource gracefully results in an empty set when
  # no cert was created.
  for_each = var.certificate_request ? { for d in try(aws_acm_certificate.cert[0].domain_validation_options, []) : d.domain_name => d } : {}

  zone_id = local.route53_zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cert_validation" {
  # Only create validation when a new certificate was created (its arn exists).
  count = var.certificate_request && try(aws_acm_certificate.cert[0].arn, "") != "" ? 1 : 0

  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for r in aws_route53_record.acm_validation : r.fqdn]
}

## IAM roles (minimal) for Elastic Beanstalk
resource "aws_iam_role" "eb_service_role" {
  name               = "${var.app_name}-${var.environment}-eb-service-role"
  assume_role_policy = data.aws_iam_policy_document.eb_service_assume.json
}

data "aws_iam_policy_document" "eb_service_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eb_service_attach" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

# Attach SSM managed instance policy so EC2 instances can be managed via Systems Manager
# This was attached manually during troubleshooting; persist it in Terraform so state
# remains consistent and future updates won't remove the permission.
resource "aws_iam_role_policy_attachment" "eb_ssm_attach" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile for EC2 instances in EB
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.app_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.eb_instance_role.name
}

# Separate IAM role for EC2 instances (must be assumable by EC2 service)
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eb_instance_role" {
  name               = "${var.app_name}-${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# Attach SSM managed instance policy to the EC2 role so the agent can register
resource "aws_iam_role_policy_attachment" "eb_instance_ssm_attach" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Allow EC2 instances to pull images from private ECR repositories
resource "aws_iam_role_policy_attachment" "eb_instance_ecr_attach" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Inline policy to allow EC2 instances to read EB application versions from the S3 bucket
resource "aws_iam_role_policy" "eb_s3_access_instance" {
  name = "${var.app_name}-${var.environment}-eb-s3-access-instance"
  role = aws_iam_role.eb_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowListBucket",
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.eb_app_versions.arn]
      },
      {
        Sid    = "AllowGetObjects",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = ["${aws_s3_bucket.eb_app_versions.arn}/*"]
      }
    ]
  })
}

# Inline policy to allow EB role to read EB application versions from the S3 bucket
resource "aws_iam_role_policy" "eb_s3_access" {
  name = "${var.app_name}-${var.environment}-eb-s3-access"
  role = aws_iam_role.eb_service_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowListBucket",
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.eb_app_versions.arn]
      },
      {
        Sid    = "AllowGetObjects",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = ["${aws_s3_bucket.eb_app_versions.arn}/*"]
      }
    ]
  })
}

## Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "app" {
  name        = var.app_name
  description = "${var.app_name} application managed by Terraform"

  appversion_lifecycle {
    service_role          = aws_iam_role.eb_service_role.arn
    max_count             = 10
    delete_source_from_s3 = true
  }
}

## Elastic Beanstalk environment (Docker platform - single container Docker)
resource "aws_elastic_beanstalk_environment" "env" {
  name                = "${var.app_name}-${var.environment}"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name
  tier                = "WebServer"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id != "" ? var.vpc_id : ""
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = tostring(var.min_instances)
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = tostring(var.max_instances)
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  # Configure HTTPS listener if certificate was requested/found
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = local.certificate_arn != "" ? "HTTPS" : ""
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = local.certificate_arn
  }

  # HTTP listener
  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "Protocol"
    value     = "HTTP"
  }

  # Health check and process
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "5000"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "production"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORT"
    value     = "5000"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SENDGRID_API_KEY"
    value     = var.sendgrid_api_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  tags = {
    Name = "${var.app_name}-${var.environment}"
  }
}

# EB CNAME -> create Route53 alias A record pointing to EB environment
resource "aws_route53_record" "apex" {
  zone_id         = local.route53_zone_id
  name            = var.domain_name
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_elastic_beanstalk_environment.env.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  count           = var.create_www_redirect ? 1 : 0
  zone_id         = local.route53_zone_id
  name            = "www.${var.domain_name}"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_elastic_beanstalk_environment.env.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}

data "aws_elastic_beanstalk_hosted_zone" "current" {
  region = var.aws_region
}

/* NOTES: This terraform sets up resources but it does NOT upload application versions to S3 or create
   Dockerrun.aws.json automatically. Use the provided `deploy.sh` to build/push image to ECR and
   create an application version in S3 to trigger EB deployment. */

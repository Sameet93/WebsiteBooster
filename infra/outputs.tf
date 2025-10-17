output "elastic_beanstalk_environment_name" {
  description = "Name of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.env.name
}

output "elastic_beanstalk_environment_url" {
  description = "URL of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.env.endpoint_url
}

output "elastic_beanstalk_cname" {
  description = "CNAME of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.env.cname
}

output "domain_url" {
  description = "Custom domain URL"
  value       = "https://${var.domain_name}"
}

output "route53_nameservers" {
  description = "Route53 hosted zone nameservers"
  value       = var.hosted_zone_id != "" ? data.aws_route53_zone.by_id[0].name_servers : data.aws_route53_zone.by_name[0].name_servers
}

output "elastic_beanstalk_hosted_zone_id" {
  description = "Elastic Beanstalk hosted zone ID for the region"
  value       = data.aws_elastic_beanstalk_hosted_zone.current.id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "eb_s3_bucket" {
  description = "S3 bucket used to store EB application versions"
  value       = aws_s3_bucket.eb_app_versions.bucket
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN (if created or used)"
  value       = local.certificate_arn
}

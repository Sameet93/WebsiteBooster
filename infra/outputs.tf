output "elastic_beanstalk_environment_name" {
  description = "Name of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.trepidus_tech_env.name
}

output "elastic_beanstalk_environment_url" {
  description = "URL of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.trepidus_tech_env.endpoint_url
}

output "elastic_beanstalk_cname" {
  description = "CNAME of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.trepidus_tech_env.cname
}

output "domain_url" {
  description = "Custom domain URL"
  value       = "https://${var.domain_name}"
}

output "route53_nameservers" {
  description = "Route53 hosted zone nameservers"
  value       = data.aws_route53_zone.main.name_servers
}

output "elastic_beanstalk_hosted_zone_id" {
  description = "Elastic Beanstalk hosted zone ID for the region"
  value       = data.aws_elastic_beanstalk_hosted_zone.current.id
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = data.aws_acm_certificate.main.arn
}

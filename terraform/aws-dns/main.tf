provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
  version = "~> 1.60"
}

terraform {
  required_version = "< 0.12.0"
}

provider "random" {
  version = "~> 2.0"
}

data "aws_route53_zone" "hosted_domain" {
  name         = var.hosted_domain
}

resource "aws_route53_record" "child_ns_record" {
  allow_overwrite = true
  name            = var.forwarding_domain
  ttl             = 300
  type            = "NS"
  zone_id         = data.aws_route53_zone.hosted_domain.zone_id

  records = var.name_servers
}

output "zone" {
  value = data.aws_route53_zone.hosted_domain.name
}

output "domain" {
  value = aws_route53_record.child_ns_record.name
}
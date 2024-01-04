module "load_balancer" {
  source     = "ptonini/ec2-loadbalancer/aws"
  version    = "~> 4.1.2"
  name       = var.name
  subnet_ids = var.subnet_ids
  security_group = {
    vpc = var.vpc
    ingress_rules = {
      self  = { ip_protocol = -1, referenced_security_group_id = "self" }
      http  = { from_port = var.http_port, cidr_ipv4 = "0.0.0.0/0" }
      https = { from_port = var.https_port, cidr_ipv4 = "0.0.0.0/0" }
    }
  }
  log_bucket = var.log_bucket
  listeners = {
    1 = {
      port            = var.https_port
      protocol        = "HTTPS"
      certificate     = module.certificate.this
      default_actions = { 1 = { type = "redirect", redirect = { host = var.target_hostname } } }
    }
    http_to_https = {
      port            = var.http_port
      protocol        = "HTTP"
      default_actions = { 1 = { type = "redirect", redirect = { port = var.https_port, protocol = "HTTPS" } } }
    }
  }
}

module "certificate" {
  source                    = "ptonini/acm-certificate/aws"
  version                   = "~> 2.0.0"
  domain_name               = one(var.hostnames)
  subject_alternative_names = [for d in var.hostnames : d if index(var.hostnames, d) != 0]
  route53_zone              = var.route53_zone
}

module "dns_record" {
  source       = "ptonini/route53-record/aws"
  version      = "~> 1.0.0"
  for_each     = toset(var.hostnames)
  name         = each.value
  route53_zone = var.route53_zone
  alias = {
    name    = module.load_balancer.this.dns_name
    zone_id = module.load_balancer.this.zone_id
  }
}
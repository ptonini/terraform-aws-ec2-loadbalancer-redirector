variable "name" {}

variable "hostnames" {
  type = list(string)
}

variable "target_hostname" {}

variable "http_port" {
  default = 80
}

variable "https_port" {
  default = 443
}

variable "log_bucket" {
  type = object({
    name          = string
    region        = string
    force_destroy = optional(bool, true)
  })
  default = null
}

variable "route53_zone" {
  type = object({
    name = string
    id   = string
  })
}

variable "vpc" {
  type = object({
    id = string
  })
}

variable "subnet_ids" {
  type = set(string)
}

variable "actions" {
  default = {}
}

variable "rules" {
  default = {}
}

variable "dns_type" {
  default = "record"
}
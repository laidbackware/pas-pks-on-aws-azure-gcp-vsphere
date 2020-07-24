variable "hosted_domain" {
  default = ""
  type        = string
}

variable "forwarding_domain" {
  default = ""
  type        = string
}

variable "aws_access_key" {
  default = ""
  type        = string
}

variable "aws_secret_key" {
  default = ""
  type        = string
}

variable "region" {
  default = "eu-west-2"
  type        = string
}

variable "name_servers" {
    type = list
}
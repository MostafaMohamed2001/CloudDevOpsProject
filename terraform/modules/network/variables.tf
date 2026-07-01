variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}


variable "acl_ingress" {
  type = map(object({
    rule_number = number
    protocol    = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
}

variable "acl_egress" {
  type = map(object({
    rule_number = number
    protocol    = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
}

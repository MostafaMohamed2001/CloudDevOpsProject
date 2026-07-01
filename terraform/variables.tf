variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
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


##### Server variables #####

variable "security_group_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ingress_rules" {
  type = map(object({
    port        = number
    protocol    = string
    cidr_blocks = string
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
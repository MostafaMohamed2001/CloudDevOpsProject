variable "security_group_name" {
  type = string
  description = "Name of security group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where SG will be created"
}

variable "ingress_rules" {
  type = map(object({
    port        = number
    protocol    = string
    cidr_blocks = string
  }))
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

variable "subnet_id" {
  type = string
}

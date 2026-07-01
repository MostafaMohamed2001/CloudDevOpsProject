

resource "aws_security_group" "main" {
  name   = var.security_group_name
  vpc_id = var.vpc_id

  tags = {
    Name = var.security_group_name
  }
}


resource "aws_vpc_security_group_ingress_rule" "rules" {
  for_each = var.ingress_rules

  security_group_id = aws_security_group.main.id

  from_port   = each.value.port
  to_port     = each.value.port
  ip_protocol = each.value.protocol
  cidr_ipv4   = each.value.cidr_blocks
}
# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.main.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


############ AMI 


data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = file(var.public_key_path) 
}
resource "aws_instance" "main" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [
  aws_security_group.main.id
]
  key_name               = aws_key_pair.main.key_name

  tags = {
    Name = "jenkins-server"
  }
}


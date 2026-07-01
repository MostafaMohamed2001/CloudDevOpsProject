
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}
resource "aws_subnet" "public" {
  for_each =var.public_subnets

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr

  availability_zone = each.value.az

  map_public_ip_on_launch = true

  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["public_1"].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "main-nat"
  }
}

##################Private Subnets###########################


resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr

  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}



## nacl##


resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-nacl"
  }
}

resource "aws_network_acl_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.public.id
}
resource "aws_network_acl_rule" "public_ingress_rules" {
  for_each = var.acl_ingress

  network_acl_id = aws_network_acl.public.id

  rule_number = each.value.rule_number
  egress      = false

  protocol    = each.value.protocol
  rule_action = "allow"

  cidr_block = each.value.cidr_block

  from_port = each.value.from_port
  to_port   = each.value.to_port
}

resource "aws_network_acl_rule" "public_egress" {
  for_each = var.acl_egress

  network_acl_id = aws_network_acl.public.id

  rule_number = each.value.rule_number
  egress      = true

  protocol    = each.value.protocol
  rule_action = "allow"

  cidr_block = each.value.cidr_block

  from_port = each.value.from_port
  to_port   = each.value.to_port
}
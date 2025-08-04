

resource "aws_vpc" "testvpc" {
  cidr_block           = var.vcp_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    "Name" = "${var.project_name}-${var.project_env}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.testvpc.id

  tags = {
    "Name" = "${var.project_name}-${var.project_env}-igw"

  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.testvpc.id
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.testvpc.cidr_block, 6, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "${var.project_name}-${var.project_env}-publicsubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id                  = aws_vpc.testvpc.id
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.testvpc.cidr_block, 6, "${count.index + 2}")
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "${var.project_name}-${var.project_env}-privatesubnet-${count.index + 1}"
  }
}

resource "aws_eip" "vpc_eip" {

  domain = "vpc"
  tags = {
    Name = "${var.project_name}-${var.project_env}-nat"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.vpc_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "${var.project_name}-${var.project_env}"
  }


  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.testvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}-public-route-table"
  }
}

resource "aws_route_table_association" "public-association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}



resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.testvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}-private-route-table"
  }
}

resource "aws_route_table_association" "private-association" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

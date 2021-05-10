# networking.tf | Network Configuration

resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name = "${var.app_name}-igw"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name = "${var.app_name}-private-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  vpc_id = aws_vpc.aws-vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}-public-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name = "${var.app_name}-routing-table-public"
    Environment = var.app_environment
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.aws-igw.id
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  count = length(var.public_subnets)
  subnet_id = element(aws_subnet.public.*.id, count.index)
}

resource "aws_route_table_association" "non-private" {
  route_table_id = aws_route_table.public.id
  count = length(var.private_subnets)
  subnet_id = element(aws_subnet.private.*.id, count.index)
}

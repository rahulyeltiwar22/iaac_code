#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "my" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-my-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_subnet" "my" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.my.id

  tags = tomap({
    "Name"                                      = "terraform-eks-my-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "my" {
  vpc_id = aws_vpc.my.id

  tags = {
    Name = "terraform-eks-my"
  }
}

resource "aws_route_table" "my" {
  vpc_id = aws_vpc.my.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my.id
  }
}

resource "aws_route_table_association" "my" {
  count = 2

  subnet_id      = aws_subnet.my.*.id[count.index]
  route_table_id = aws_route_table.my.id
}


# Output variables to expose VPC and Subnet IDs for use in other modules
output "dev_app_vpc_id" {
  value = aws_vpc.devops-app-vpc.id
}

output "dev_app_public_subnet" {
  value = aws_subnet.devops-app-public-subnet.id
}

# Create a Virtual Private Cloud (VPC) to define network boundaries
resource "aws_vpc" "devops-app-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name  # Tag to identify the VPC
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "devops-app-public-subnet" {
  vpc_id                  = aws_vpc.devops-app-vpc.id
  cidr_block              = var.cidr_public_subnet
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true  # Enable automatic public IP assignment

  tags = {
    Name = "devops-app-public-subnet"
  }
}

# Create an Internet Gateway to allow public internet access
resource "aws_internet_gateway" "devops-app-igw" {
  vpc_id = aws_vpc.devops-app-vpc.id

  tags = {
    Name = "devops-app-igw"
  }
}

# Create a public route table to manage routing for public subnets
resource "aws_route_table" "devops-app-public-route-table" {
  vpc_id = aws_vpc.devops-app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Default route to the internet
    gateway_id = aws_internet_gateway.devops-app-igw.id
  }

  tags = {
    Name = "devops-app-public-route-table"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "devops-app-public-route-table-association" {
  subnet_id      = aws_subnet.devops-app-public-subnet.id
  route_table_id = aws_route_table.devops-app-public-route-table.id
}

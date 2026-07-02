resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "iot-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "PlatformTeam"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "iot-${var.environment}-public-subnet"
    Tier = "Public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "iot-${var.environment}-private-subnet"
    Tier = "Private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "iot-${var.environment}-igw"
  }
}

# 1. Allocate a Static Public IP (Elastic IP) for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw] # Ensures correct graph ordering

  tags = {
    Name = "iot-${var.environment}-nat-eip"
  }
}

# 2. Deploy the NAT Gateway into the PUBLIC subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id # Must sit in public to talk to the internet

  tags = {
    Name = "iot-${var.environment}-nat-gateway"
  }
}

# 3. Create a Custom Route Table for the Private Subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  # Tell traffic destined for the internet (0.0.0.0/0) to go through the NAT Gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "iot-${var.environment}-private-rt"
  }
}

# 4. Bind the Private Subnet to this new secure Route Table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}


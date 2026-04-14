################################################################################
# Cloud-Bridge — Módulo: Networking
# Cria VPC, Subnets pública/privada, Internet Gateway e Security Groups
################################################################################

variable "project_name"    { type = string }
variable "environment"     { type = string }
variable "vpc_cidr"        { type = string }
variable "aws_region"      { type = string }
variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into instances. Restrict to your organization's IP in production (e.g. '203.0.113.0/24')."
  type        = string
  default     = "0.0.0.0/0"
}

################################################################################
# VPC
################################################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project_name}-vpc-${var.environment}" }
}

################################################################################
# Subnets
################################################################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-subnet-public-${var.environment}" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = "${var.aws_region}a"

  tags = { Name = "${var.project_name}-subnet-private-${var.environment}" }
}

################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-igw-${var.environment}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${var.project_name}-rt-public-${var.environment}" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

################################################################################
# Security Groups
################################################################################

# Security Group Web — HTTP, HTTPS e SSH restrito
resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg-web-${var.environment}"
  description = "Permite HTTP, HTTPS e SSH de IPs autorizados"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP público"
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS público"
  }

  # SSH — restrito ao CIDR configurado (padrão aberto; restrinja em produção)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
    description = "SSH — restrinja ao IP da organização em produção"
  }

  # Todo tráfego de saída permitido
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Todo tráfego de saída"
  }

  tags = { Name = "${var.project_name}-sg-web-${var.environment}" }
}

################################################################################
# Outputs do módulo
################################################################################
output "vpc_id"               { value = aws_vpc.main.id }
output "public_subnet_id"     { value = aws_subnet.public.id }
output "private_subnet_id"    { value = aws_subnet.private.id }
output "web_security_group_id"{ value = aws_security_group.web.id }

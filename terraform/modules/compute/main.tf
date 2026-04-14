################################################################################
# Cloud-Bridge — Módulo: Compute
# EC2 Free Tier (t2.micro) com hardening básico e backups automáticos
################################################################################

variable "project_name"      { type = string }
variable "environment"       { type = string }
variable "instance_type"     { type = string }
variable "ami_id"            { type = string }
variable "key_pair_name"     { type = string }
variable "subnet_id"         { type = string }
variable "security_group_id" { type = string }

################################################################################
# Dados do usuário — script de inicialização (hardening + Docker)
################################################################################
locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Atualização do sistema
    apt-get update -y
    apt-get upgrade -y

    # Ferramentas básicas
    apt-get install -y \
      curl wget git unzip \
      fail2ban ufw \
      ca-certificates gnupg

    # Configuração básica de firewall (UFW)
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow http
    ufw allow https
    ufw --force enable

    # Instalação do Docker
    curl -fsSL https://get.docker.com | bash
    systemctl enable docker
    systemctl start docker

    # Instalação do Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    echo "Cloud-Bridge: servidor inicializado. Execute o Ansible para concluir a configuração." \
      >> /var/log/cloud-bridge-init.log
  EOF
}

################################################################################
# Instância EC2
################################################################################
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_pair_name
  user_data              = base64encode(local.user_data)

  # Disco raiz: 8 GB dentro do Free Tier (máx 30 GB gp2)
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }

  # Proteção contra término acidental em produção
  disable_api_termination = var.environment == "prod"

  tags = { Name = "${var.project_name}-server-${var.environment}" }
}

################################################################################
# Elastic IP (IP fixo)
################################################################################
resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = { Name = "${var.project_name}-eip-${var.environment}" }
}

################################################################################
# Outputs do módulo
################################################################################
output "instance_id"        { value = aws_instance.main.id }
output "instance_public_ip" { value = aws_eip.main.public_ip }
output "instance_private_ip"{ value = aws_instance.main.private_ip }

################################################################################
# Cloud-Bridge — Variáveis Terraform
################################################################################

variable "aws_region" {
  description = "Região AWS. Para menor latência no Brasil, use sa-east-1 (São Paulo)."
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Nome do projeto. Usado como prefixo em todos os recursos."
  type        = string
  default     = "cloud-bridge"
}

variable "environment" {
  description = "Ambiente de implantação: dev, staging ou prod."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O ambiente deve ser dev, staging ou prod."
  }
}

variable "org_name" {
  description = "Nome da organização ou ONG. Usado para tags e identificação."
  type        = string
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "Tipo de instância EC2. t2.micro está no Free Tier."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID da AMI. Padrão: Ubuntu 22.04 LTS em sa-east-1."
  type        = string
  default     = "ami-0af6e9042ea5a4e3e" # Ubuntu 22.04 LTS — sa-east-1
}

variable "key_pair_name" {
  description = "Nome do Key Pair EC2 para acesso SSH."
  type        = string
}

variable "alert_email" {
  description = "E-mail para receber alertas de billing e incidentes de segurança."
  type        = string
}

variable "billing_alert_threshold_usd" {
  description = "Valor em USD que, ao ser atingido, dispara o alerta de custo."
  type        = number
  default     = 1.0 # Alerta imediato ao sair do Free Tier
}

variable "ssh_allowed_cidr" {
  description = "CIDR permitido para acesso SSH. Restrinja ao IP da organização em produção (ex: '203.0.113.0/32')."
  type        = string
  default     = "0.0.0.0/0"
}

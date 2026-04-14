################################################################################
# Cloud-Bridge — Terraform Root Module
# Provisionamento de infraestrutura AWS Free Tier para pequenas organizações
################################################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend remoto opcional — descomente para armazenar state no S3
  # Nota: a região deve ser um valor literal (não pode usar variáveis aqui)
  # backend "s3" {
  #   bucket = "cloud-bridge-terraform-state"
  #   key    = "terraform.tfstate"
  #   region = "sa-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Cloud-Bridge"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.org_name
    }
  }
}

################################################################################
# Módulo de Rede (VPC, Subnets, Security Groups)
################################################################################
module "networking" {
  source = "./modules/networking"

  project_name     = var.project_name
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  aws_region       = var.aws_region
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

################################################################################
# Módulo de Computação (EC2 Free Tier — t2.micro)
################################################################################
module "compute" {
  source = "./modules/compute"

  project_name      = var.project_name
  environment       = var.environment
  instance_type     = var.instance_type
  ami_id            = var.ami_id
  key_pair_name     = var.key_pair_name
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.networking.web_security_group_id
}

################################################################################
# Módulo de Armazenamento (S3 Free Tier)
################################################################################
module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
  org_name     = var.org_name
}

################################################################################
# Alertas de Billing (FinOps) — SNS + CloudWatch
################################################################################
resource "aws_sns_topic" "billing_alerts" {
  name = "${var.project_name}-billing-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "billing_email" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "${var.project_name}-billing-limit-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 86400 # 24 horas
  statistic           = "Maximum"
  threshold           = var.billing_alert_threshold_usd
  alarm_description   = "Alerta: gastos AWS superaram USD ${var.billing_alert_threshold_usd}"
  alarm_actions       = [aws_sns_topic.billing_alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}

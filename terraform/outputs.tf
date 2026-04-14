################################################################################
# Cloud-Bridge — Outputs Terraform
################################################################################

output "instance_public_ip" {
  description = "IP público da instância EC2."
  value       = module.compute.instance_public_ip
}

output "instance_id" {
  description = "ID da instância EC2."
  value       = module.compute.instance_id
}

output "s3_bucket_name" {
  description = "Nome do bucket S3 de armazenamento."
  value       = module.storage.bucket_name
}

output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.networking.vpc_id
}

output "billing_alarm_arn" {
  description = "ARN do alarme de billing no CloudWatch."
  value       = aws_cloudwatch_metric_alarm.billing_alarm.arn
}

output "sns_topic_arn" {
  description = "ARN do tópico SNS para alertas."
  value       = aws_sns_topic.billing_alerts.arn
}

output "ssh_command" {
  description = "Comando para acessar o servidor via SSH."
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${module.compute.instance_public_ip}"
}

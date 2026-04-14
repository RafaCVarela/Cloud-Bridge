################################################################################
# Cloud-Bridge — Módulo: Storage
# Bucket S3 com criptografia, versionamento e política de lifecycle
################################################################################

variable "project_name" { type = string }
variable "environment"  { type = string }
variable "org_name"     { type = string }

################################################################################
# Bucket S3 principal
################################################################################
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${replace(lower(var.org_name), " ", "-")}-${var.environment}"

  tags = { Name = "${var.project_name}-storage-${var.environment}" }
}

# Bloquear acesso público (segurança obrigatória)
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Criptografia em repouso com AES-256
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Versionamento — permite recuperar versões anteriores de arquivos
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle: mantém apenas as últimas 5 versões e expira objetos antigos
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      newer_noncurrent_versions = 5
      noncurrent_days           = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

################################################################################
# Bucket separado para backups (ciclo de vida diferente)
################################################################################
resource "aws_s3_bucket" "backups" {
  bucket = "${var.project_name}-${replace(lower(var.org_name), " ", "-")}-backups-${var.environment}"

  tags = { Name = "${var.project_name}-backups-${var.environment}" }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket                  = aws_s3_bucket.backups.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Backups: transição para Glacier após 30 dias (custo ~$0.004/GB/mês)
resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "archive-to-glacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

################################################################################
# Outputs do módulo
################################################################################
output "bucket_name"         { value = aws_s3_bucket.main.bucket }
output "bucket_arn"          { value = aws_s3_bucket.main.arn }
output "backups_bucket_name" { value = aws_s3_bucket.backups.bucket }
output "backups_bucket_arn"  { value = aws_s3_bucket.backups.arn }

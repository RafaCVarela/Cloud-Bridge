#!/usr/bin/env bash
################################################################################
# Cloud-Bridge — Script de Alertas de Billing AWS
#
# Configura alarmes do CloudWatch para notificar quando os gastos na AWS
# ultrapassarem os limites definidos, garantindo que o Free Tier não seja
# excedido sem aviso.
#
# Pré-requisitos:
#   - AWS CLI instalada e configurada (aws configure)
#   - Permissão: cloudwatch:PutMetricAlarm, sns:CreateTopic, sns:Subscribe
#
# Uso:
#   bash billing_alerts.sh
################################################################################

set -euo pipefail

################################################################################
# Configuração — edite conforme necessário
################################################################################
ALERT_EMAIL="${ALERT_EMAIL:-}"
BILLING_THRESHOLD_USD="${BILLING_THRESHOLD_USD:-1.0}"
AWS_REGION="${AWS_REGION:-us-east-1}"    # Billing metrics ficam sempre em us-east-1
PROJECT_NAME="${PROJECT_NAME:-cloud-bridge}"
SNS_TOPIC_NAME="${PROJECT_NAME}-billing-alerts"

################################################################################
# Funções auxiliares
################################################################################
log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]  $*"; }
warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN]  $*" >&2; }
err()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2; exit 1; }

check_dependencies() {
  command -v aws  &>/dev/null || err "AWS CLI não encontrada. Instale: https://aws.amazon.com/cli/"
  command -v jq   &>/dev/null || err "jq não encontrado. Instale: apt install jq"
}

validate_config() {
  [[ -z "$ALERT_EMAIL" ]] && \
    err "Configure o e-mail: export ALERT_EMAIL=seu@email.com"
  [[ ! "$BILLING_THRESHOLD_USD" =~ ^[0-9]+(\.[0-9]+)?$ ]] && \
    err "BILLING_THRESHOLD_USD deve ser um número (ex: 1.0)"
}

create_sns_topic() {
  log "Criando tópico SNS: $SNS_TOPIC_NAME..."
  SNS_TOPIC_ARN=$(aws sns create-topic \
    --name "$SNS_TOPIC_NAME" \
    --region "$AWS_REGION" \
    --output text \
    --query TopicArn)
  log "Tópico criado: $SNS_TOPIC_ARN"
}

subscribe_email() {
  log "Inscrevendo $ALERT_EMAIL no tópico SNS..."
  aws sns subscribe \
    --topic-arn "$SNS_TOPIC_ARN" \
    --protocol email \
    --notification-endpoint "$ALERT_EMAIL" \
    --region "$AWS_REGION" \
    --output text > /dev/null
  warn "⚠️  Confirme a inscrição no e-mail $ALERT_EMAIL para receber alertas!"
}

create_billing_alarm() {
  local threshold="$1"
  local alarm_name="${PROJECT_NAME}-billing-usd${threshold/./-}"

  log "Criando alarme de billing: USD $threshold..."
  aws cloudwatch put-metric-alarm \
    --alarm-name         "$alarm_name" \
    --alarm-description  "Cloud-Bridge: Gastos AWS atingiram USD $threshold" \
    --metric-name        "EstimatedCharges" \
    --namespace          "AWS/Billing" \
    --statistic          "Maximum" \
    --dimensions         "Name=Currency,Value=USD" \
    --period             86400 \
    --evaluation-periods 1 \
    --threshold          "$threshold" \
    --comparison-operator "GreaterThanOrEqualToThreshold" \
    --alarm-actions      "$SNS_TOPIC_ARN" \
    --ok-actions         "$SNS_TOPIC_ARN" \
    --region             "$AWS_REGION"
  log "✅ Alarme criado: $alarm_name (limite: USD $threshold)"
}

show_free_tier_status() {
  log "Verificando uso atual do Free Tier..."
  # Lista as métricas de billing disponíveis
  aws cloudwatch list-metrics \
    --namespace "AWS/Billing" \
    --region "$AWS_REGION" \
    --output table \
    --query 'Metrics[*].{MetricName:MetricName,Dimensions:Dimensions[*].Value}' \
    2>/dev/null || warn "Não foi possível listar métricas de billing."
}

################################################################################
# Execução principal
################################################################################
main() {
  log "=== Cloud-Bridge — Configuração de Alertas de Billing ==="
  check_dependencies
  validate_config

  create_sns_topic
  subscribe_email

  # Cria alarmes em múltiplos níveis para aviso progressivo (sem duplicatas)
  local -A _seen=()
  for _t in "1.0" "5.0" "${BILLING_THRESHOLD_USD}"; do
    if [[ -z "${_seen[$_t]+x}" ]]; then
      _seen[$_t]=1
      create_billing_alarm "$_t"
    else
      log "Ignorando threshold duplicado: USD $_t"
    fi
  done

  show_free_tier_status

  log "=== Configuração concluída! ==="
  log "📧 Verifique seu e-mail ($ALERT_EMAIL) e confirme a inscrição no SNS."
  log "📊 Acompanhe os custos em: https://console.aws.amazon.com/billing/home"
}

main "$@"

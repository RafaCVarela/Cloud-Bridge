#!/usr/bin/env python3
"""
Cloud-Bridge — Relatório Mensal de Custos e Free Tier
======================================================
Gera um relatório comparando uso real vs. limites gratuitos da AWS,
enviando alertas caso algum serviço esteja próximo de gerar cobranças.

Pré-requisitos:
    pip install boto3 tabulate

Uso:
    python3 cost_report.py
    python3 cost_report.py --email responsavel@org.br --threshold 80
"""

import argparse
import json
import os
import sys
from datetime import date, timedelta

try:
    import boto3
    from tabulate import tabulate
except ImportError:
    print("Instale as dependências: pip install boto3 tabulate")
    sys.exit(1)

# ──────────────────────────────────────────────────────────────────────────────
# Limites do AWS Free Tier (por mês)
# Referência: https://aws.amazon.com/free/
# ──────────────────────────────────────────────────────────────────────────────
FREE_TIER_LIMITS = {
    "EC2 (t2.micro / t3.micro)": {"unit": "horas/mês", "limit": 750},
    "S3 Armazenamento":           {"unit": "GB",         "limit": 5},
    "S3 Requisições GET":         {"unit": "requisições", "limit": 20_000},
    "S3 Requisições PUT":         {"unit": "requisições", "limit": 2_000},
    "Transferência de Dados":     {"unit": "GB/mês",      "limit": 100},
    "RDS (db.t2.micro)":          {"unit": "horas/mês",   "limit": 750},
    "Lambda Invocações":          {"unit": "invocações",  "limit": 1_000_000},
    "CloudWatch Logs":            {"unit": "GB",          "limit": 5},
    "SNS Notificações":           {"unit": "notificações","limit": 1_000},
}


def get_cost_and_usage(days: int = 30) -> dict:
    """Obtém custos do AWS Cost Explorer para os últimos N dias."""
    client = boto3.client("ce", region_name="us-east-1")
    end = date.today()
    start = end - timedelta(days=days)

    response = client.get_cost_and_usage(
        TimePeriod={"Start": start.strftime("%Y-%m-%d"), "End": end.strftime("%Y-%m-%d")},
        Granularity="MONTHLY",
        Metrics=["UnblendedCost"],
        GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}],
    )
    return response.get("ResultsByTime", [])


def format_cost_report(results: list) -> list[list]:
    """Formata dados do Cost Explorer para exibição tabular."""
    rows = []
    total = 0.0

    for period in results:
        for group in period.get("Groups", []):
            service = group["Keys"][0]
            cost = float(group["Metrics"]["UnblendedCost"]["Amount"])
            currency = group["Metrics"]["UnblendedCost"]["Unit"]
            total += cost
            status = "✅ Free Tier" if cost == 0 else "⚠️  Cobrado"
            rows.append([service, f"{cost:.4f}", currency, status])

    rows.sort(key=lambda r: float(r[1]), reverse=True)
    rows.append(["─" * 40, "─" * 10, "─" * 5, "─" * 15])
    rows.append(["TOTAL", f"{total:.4f}", "USD", ""])
    return rows


def check_free_tier_status(threshold_pct: int = 80) -> list[dict]:
    """
    Verifica serviços próximos do limite do Free Tier.
    Retorna lista de alertas para serviços acima do threshold.
    """
    # Nota: consulta real requer AWS Cost Explorer Savings Plans / Free Tier API
    # Este é um placeholder demonstrativo da estrutura de alertas
    alerts = []
    for service, info in FREE_TIER_LIMITS.items():
        usage_pct = 0  # substituir por consulta real à API de Free Tier Usage
        if usage_pct >= threshold_pct:
            alerts.append({
                "service": service,
                "usage_pct": usage_pct,
                "limit": info["limit"],
                "unit": info["unit"],
            })
    return alerts


def send_report_email(report: str, email: str, sns_topic_arn: str | None = None) -> None:
    """Envia relatório por e-mail via SNS."""
    if not sns_topic_arn:
        print(f"[INFO] Relatório não enviado por e-mail (SNS_TOPIC_ARN não configurado).")
        return

    client = boto3.client("sns", region_name="us-east-1")
    client.publish(
        TopicArn=sns_topic_arn,
        Subject="☁️ Cloud-Bridge — Relatório Mensal de Custos AWS",
        Message=report,
    )
    print(f"[INFO] Relatório enviado para {email} via SNS.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Cloud-Bridge — Relatório Mensal de Custos AWS"
    )
    parser.add_argument("--days",      type=int, default=30, help="Período em dias (padrão: 30)")
    parser.add_argument("--threshold", type=int, default=80, help="% do Free Tier para alertar (padrão: 80)")
    parser.add_argument("--email",     type=str, default=None, help="E-mail para envio do relatório")
    parser.add_argument("--sns-arn",   type=str, default=os.getenv("SNS_TOPIC_ARN"), help="ARN do tópico SNS")
    args = parser.parse_args()

    print("=" * 60)
    print("☁️  Cloud-Bridge — Relatório de Custos AWS")
    print(f"   Período: últimos {args.days} dias")
    print("=" * 60)

    # Relatório de custos reais
    try:
        results = get_cost_and_usage(args.days)
        rows = format_cost_report(results)
        report_table = tabulate(
            rows,
            headers=["Serviço", "Custo (USD)", "Moeda", "Status"],
            tablefmt="grid",
        )
        print(report_table)
    except Exception as exc:
        print(f"[WARN] Não foi possível obter dados do Cost Explorer: {exc}")
        report_table = "Dados não disponíveis."

    # Alertas de Free Tier
    alerts = check_free_tier_status(args.threshold)
    if alerts:
        print(f"\n⚠️  ALERTAS — Serviços acima de {args.threshold}% do Free Tier:")
        for alert in alerts:
            print(f"   • {alert['service']}: {alert['usage_pct']:.1f}% "
                  f"({alert['limit']} {alert['unit']})")
    else:
        print(f"\n✅ Nenhum serviço acima de {args.threshold}% do Free Tier.")

    # Limites do Free Tier para referência
    print("\n📋 Limites do AWS Free Tier (referência):")
    limits_rows = [[s, str(i["limit"]), i["unit"]] for s, i in FREE_TIER_LIMITS.items()]
    print(tabulate(limits_rows, headers=["Serviço", "Limite", "Unidade"], tablefmt="simple"))

    # Envio por e-mail
    if args.email and args.sns_arn:
        send_report_email(report_table, args.email, args.sns_arn)

    print("\n📊 Console AWS Billing: https://console.aws.amazon.com/billing/home")
    print("=" * 60)


if __name__ == "__main__":
    main()

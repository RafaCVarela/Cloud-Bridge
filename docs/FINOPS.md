# 💰 Guia de FinOps — Cloud-Bridge

**FinOps (Financial Operations)** é a prática de gestão financeira em nuvem que
garante que sua organização use a nuvem de forma eficiente, transparente e sem
surpresas na fatura.

---

## Por que FinOps é Essencial para Pequenas Organizações?

- A nuvem cobra por uso: **sem gerenciamento, os custos crescem sem controle**
- O Free Tier tem limites — ultrapassá-los gera cobrança imediata
- Recursos esquecidos (instâncias paradas, IPs não associados) geram custo
- A visibilidade de custos permite decisões mais inteligentes de infraestrutura

---

## Limites do AWS Free Tier — Resumo

### Primeiros 12 meses (a partir da criação da conta)

| Serviço | O que está incluído |
|---|---|
| EC2 | 750 horas/mês de t2.micro ou t3.micro |
| S3 | 5 GB de armazenamento padrão |
| S3 | 20.000 requisições GET + 2.000 PUT |
| RDS | 750 horas/mês de db.t2.micro |
| EBS | 30 GB de armazenamento em bloco |
| Transferência | 100 GB de saída de dados por mês |
| CloudFront | 1 TB de transferência + 10M de requisições |

### Always Free (sem limite de tempo)

| Serviço | Limite |
|---|---|
| Lambda | 1.000.000 invocações/mês |
| DynamoDB | 25 GB de armazenamento |
| CloudWatch | 10 métricas personalizadas, 10 alarmes |
| SNS | 1.000 notificações por e-mail/mês |
| SES | 3.000 mensagens/mês (apenas envio) |

---

## Configurando Alertas de Billing

### Método 1 — Script Automatizado (Recomendado)

```bash
export ALERT_EMAIL=responsavel@suaorg.org.br
export BILLING_THRESHOLD_USD=5.0
cd monitoring
bash billing_alerts.sh
```

O script cria **3 alarmes**:
- USD 1.00 — Primeiro centavo fora do Free Tier
- USD 5.00 — Gasto intermediário
- USD [seu limite] — Limite personalizado

### Método 2 — Console AWS

1. Console AWS → **Billing and Cost Management**
2. **Budgets** → **Create Budget**
3. Tipo: **Cost Budget**
4. Valor: USD 1.00 (ou seu limite)
5. Alertas: 80% e 100% do orçamento
6. Notificação por e-mail

---

## Relatório Mensal de Custos

```bash
# Instalar dependências
pip install boto3 tabulate

# Gerar relatório
cd monitoring
python3 cost_report.py

# Relatório com envio por e-mail
python3 cost_report.py --email responsavel@org.br --sns-arn arn:aws:sns:us-east-1:123456:cloud-bridge-billing-alerts
```

---

## Estratégias de Otimização de Custos

### 1. Use Apenas o Necessário

```bash
# Parar instância EC2 quando não estiver em uso (desenvolvimento)
aws ec2 stop-instances --instance-ids i-xxxxxxxxx

# Iniciar quando precisar
aws ec2 start-instances --instance-ids i-xxxxxxxxx
```

⚠️ Uma instância **parada** ainda gera custo por EBS e Elastic IP associado.

### 2. Elastic IP — Libere Quando Não Usar

```bash
# Liberar EIP não associado (gera cobrança se não associado!)
aws ec2 release-address --allocation-id eipalloc-xxxxxxxxx
```

### 3. S3 — Lifecycle Automático

O módulo de storage do Terraform já configura:
- Mover para Glacier após 30 dias (10x mais barato)
- Expirar versões antigas após 30 dias

### 4. Lambda vs EC2

Para cargas de trabalho intermitentes, prefira Lambda:
- 1.000.000 invocações gratuitas/mês (always free)
- Paga apenas pelo tempo de execução
- Sem custo em idle

### 5. Monitorar com Tags

Configure tags de custo em todos os recursos (já feito no Terraform):
```
Project=cloud-bridge, Environment=dev, Owner=suaorg
```

Acesse **AWS Cost Explorer** → **Tags** para ver o custo por projeto.

---

## Dashboard de Custos no Grafana

O Cloud-Bridge inclui um datasource AWS CloudWatch no Grafana.
Para visualizar custos:

1. Acesse Grafana (`http://SEU_IP:3000`)
2. **Connections** → **Add data source** → **CloudWatch**
3. Configure a região: `us-east-1` (billing metrics ficam aqui)
4. **Dashboards** → **Import** → ID: `139` (AWS Billing Dashboard)

---

## Checklist FinOps Mensal

- [ ] Revisar relatório do Cost Explorer
- [ ] Verificar instâncias paradas com EIP associado
- [ ] Verificar snapshots e AMIs antigas não utilizadas
- [ ] Verificar buckets S3 sem lifecycle configurado
- [ ] Verificar alarmes de billing funcionando
- [ ] Documentar variações de custo > 20%

---

## Recursos Adicionais

- [AWS Free Tier — Detalhes Completos](https://aws.amazon.com/free/)
- [AWS Cost Explorer](https://console.aws.amazon.com/cost-management/home)
- [Google for Nonprofits](https://www.google.com/nonprofits/) — créditos GCP para ONGs
- [AWS Activate for Nonprofits](https://aws.amazon.com/activate/nonprofits/) — até USD 1.000 em créditos

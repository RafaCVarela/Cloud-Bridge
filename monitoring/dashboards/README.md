# Cloud-Bridge — Dashboard de Monitoramento (Grafana)

Este diretório contém os dashboards pré-configurados do Grafana para
monitoramento de infraestrutura e custos.

## Dashboards Disponíveis

| Dashboard | Descrição | ID Grafana |
|---|---|---|
| Node Exporter Full | CPU, RAM, disco e rede do servidor | 1860 |
| Docker Container Metrics | Métricas de containers Docker | 11600 |
| AWS CloudWatch | Métricas de serviços AWS | 139 |

## Como Importar

1. Acesse o Grafana em `http://SEU_IP:3000`
2. Login: `admin / [senha definida via grafana_admin_password no Ansible]`
3. Menu → **Dashboards** → **Import**
4. Use o **ID** da tabela acima ou importe o arquivo JSON correspondente

## Configuração da Fonte de Dados (AWS CloudWatch)

Para o dashboard de custos AWS:

1. Menu → **Connections** → **Data Sources**
2. **Add data source** → **CloudWatch**
3. Configure com as credenciais IAM (use uma role com permissão mínima):
   - `cloudwatch:GetMetricData`
   - `cloudwatch:ListMetrics`
   - `ce:GetCostAndUsage` (para dados de billing)
4. Região: `sa-east-1` (ou `us-east-1` para billing)

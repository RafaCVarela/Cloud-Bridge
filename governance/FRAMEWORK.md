# 🔐 Framework de Governança de Nuvem para Pequenas Organizações

**Cloud-Bridge — Documento de Governança v1.0**

> Este framework foi desenvolvido especificamente para ONGs, associações comunitárias e
> pequenas empresas que adotam serviços de nuvem pela primeira vez, com foco em
> segurança, conformidade com a LGPD e controle de custos.

---

## 📋 Índice

1. [Princípios de Governança](#1-princípios-de-governança)
2. [Controle de Acesso (IAM)](#2-controle-de-acesso-iam)
3. [Proteção de Dados e LGPD](#3-proteção-de-dados-e-lgpd)
4. [Criptografia](#4-criptografia)
5. [Política de Backup](#5-política-de-backup)
6. [Monitoramento e Auditoria](#6-monitoramento-e-auditoria)
7. [Resposta a Incidentes](#7-resposta-a-incidentes)
8. [Gestão de Custos (FinOps)](#8-gestão-de-custos-finops)
9. [Checklist de Conformidade](#9-checklist-de-conformidade)

---

## 1. Princípios de Governança

O Cloud-Bridge adota os seguintes princípios fundamentais:

### 1.1 Menor Privilégio
Todo usuário, serviço ou processo deve ter **apenas as permissões necessárias**
para realizar sua função — nada mais.

### 1.2 Defesa em Profundidade
Múltiplas camadas de segurança devem ser implementadas, de modo que a falha
de um controle não comprometa toda a infraestrutura.

### 1.3 Responsabilidade Compartilhada
Entenda o modelo de responsabilidade da sua plataforma de nuvem:
- **Provedor** (AWS/GCP/Azure): infraestrutura física, hipervisor, rede
- **Você**: sistema operacional, aplicações, dados, acessos, configurações

### 1.4 Visibilidade Total
Todos os acessos, alterações e eventos críticos devem ser registrados
(logs) e monitorados.

---

## 2. Controle de Acesso (IAM)

### 2.1 Estrutura Mínima de Usuários

```
Conta Raiz (Root)
    └── Conta Administrador (somente para gestão de contas)
        ├── Grupo: Administradores
        │     └── Permissão: AdministratorAccess (apenas 1-2 pessoas)
        ├── Grupo: Desenvolvedores
        │     └── Permissão: PowerUserAccess (sem IAM)
        └── Grupo: Leitura
              └── Permissão: ReadOnlyAccess
```

### 2.2 Políticas Obrigatórias

- [ ] **MFA habilitado** para a conta raiz e todos os administradores
- [ ] **Conta raiz nunca usada** para operações do dia a dia
- [ ] **Chaves de acesso** (Access Keys) rotacionadas a cada 90 dias
- [ ] **Política de senha**: mínimo 12 caracteres, maiúsculas, números e símbolos
- [ ] **Sessões de console** com timeout de 1 hora

### 2.3 Política IAM — Permissão Mínima para Cloud-Bridge

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "cloudwatch:GetMetricData",
        "cloudwatch:ListMetrics",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:*:*:*:cloud-bridge-*"
    }
  ]
}
```

---

## 3. Proteção de Dados e LGPD

A **Lei Geral de Proteção de Dados (Lei 13.709/2018)** aplica-se a toda
organização que trata dados pessoais de pessoas físicas no Brasil.

### 3.1 Mapeamento de Dados (Inventário)

Identifique e documente:

| Dado | Finalidade | Base Legal | Retenção | Localização |
|---|---|---|---|---|
| Nome/CPF de beneficiários | Identificação | Execução de contrato | 5 anos | S3 (criptografado) |
| E-mail de contato | Comunicação | Consentimento | Enquanto ativo | Banco de dados |
| Dados de saúde (ONGs) | Prestação de serviço | Obrigação legal | 20 anos | S3 (criptografado) |

### 3.2 Direitos dos Titulares

Implemente procedimentos para atender em até **15 dias**:
- Acesso aos dados
- Correção de dados incorretos
- Portabilidade
- Eliminação de dados
- Revogação de consentimento

### 3.3 Transferência Internacional de Dados

- Dados pessoais **NÃO devem ser armazenados fora do Brasil** sem análise jurídica
- Use a região **sa-east-1 (São Paulo)** para garantir dados em território nacional
- Se usar GCP, use a região **southamerica-east1**

---

## 4. Criptografia

### 4.1 Dados em Repouso

| Serviço | Algoritmo | Configuração |
|---|---|---|
| S3 | AES-256 | SSE-S3 (habilitado por padrão no template) |
| EBS / Disco VM | AES-256 | Habilitado na criação (Terraform template) |
| Banco de Dados | AES-256 | Habilitado na criação |
| Backups | AES-256 | Herda da origem |

### 4.2 Dados em Trânsito

- Todo tráfego externo deve usar **TLS 1.2 ou superior**
- O Traefik (incluso no Docker Compose) gerencia certificados **Let's Encrypt** automaticamente
- Comunicação interna entre containers usa rede Docker isolada

### 4.3 Gerenciamento de Segredos

- **NUNCA** armazene senhas, tokens ou chaves em arquivos de configuração no Git
- Use variáveis de ambiente (`.env`) — incluído no `.gitignore`
- Em produção, use AWS Secrets Manager ou HashiCorp Vault
- Audite regularmente: `git log --all --full-history -- "*.env*"`

---

## 5. Política de Backup

### 5.1 Regra 3-2-1

> **3** cópias dos dados, em **2** mídias diferentes, **1** fora do local principal.

| Cópia | Localização | Frequência | Retenção |
|---|---|---|---|
| Primária | S3 principal (sa-east-1) | Contínuo | 7 dias |
| Secundária | S3 backups (sa-east-1) + Glacier | Diário | 30 dias → Glacier 1 ano |
| Terciária | Download local mensal | Mensal | 12 meses |

### 5.2 Testes de Restore

- **Obrigatório**: testar restore completo **mensalmente**
- Documentar o resultado no [`checklists/backup-restore-log.md`](checklists/backup-restore-log.md)
- Tempo de Objetivo de Recuperação (RTO): < 4 horas
- Ponto de Objetivo de Recuperação (RPO): < 24 horas

---

## 6. Monitoramento e Auditoria

### 6.1 Logs Obrigatórios

- [ ] **AWS CloudTrail**: todas as chamadas de API (90 dias gratuito)
- [ ] **VPC Flow Logs**: tráfego de rede (opcional, tem custo)
- [ ] **S3 Access Logs**: acesso aos buckets
- [ ] **Application Logs**: exportados para CloudWatch Logs

### 6.2 Alertas de Segurança

Configure alertas para:

| Evento | Prioridade | Ação |
|---|---|---|
| Login da conta raiz | 🔴 Crítico | Notificar imediatamente |
| Criação de usuário IAM | 🟡 Alto | Verificar em 24h |
| Alteração de Security Group | 🟡 Alto | Verificar em 24h |
| Acesso a bucket S3 fora do horário | 🟠 Médio | Verificar em 48h |
| Threshold de billing atingido | 🔴 Crítico | Notificar imediatamente |

---

## 7. Resposta a Incidentes

### 7.1 Classificação de Incidentes

| Nível | Descrição | Exemplo | SLA Resposta |
|---|---|---|---|
| P1 — Crítico | Sistema indisponível ou dados comprometidos | Ransomware, vazamento de dados | 1 hora |
| P2 — Alto | Degradação severa ou suspeita de comprometimento | Acesso suspeito, serviço lento | 4 horas |
| P3 — Médio | Problema isolado sem impacto em dados | Serviço secundário fora, alerta de custo | 24 horas |
| P4 — Baixo | Questão técnica menor | Log de erro não crítico | 72 horas |

### 7.2 Playbook de Vazamento de Dados

Em caso de suspeita de acesso não autorizado aos dados:

```
1. CONTER — Isolar o recurso comprometido imediatamente
   aws ec2 revoke-security-group-ingress --group-id sg-xxx --protocol all --cidr 0.0.0.0/0

2. AVALIAR — Determinar o escopo do incidente
   - Quais dados foram acessados?
   - Por quanto tempo?
   - De qual origem?

3. NOTIFICAR — Obrigação LGPD (Art. 48): comunicar à ANPD em até 72h
   - Formulário: https://www.gov.br/anpd/pt-br/assuntos/incidentes

4. REMEDIAR — Corrigir a vulnerabilidade
   - Rotacionar todas as credenciais
   - Aplicar patches de segurança
   - Reforçar controles de acesso

5. DOCUMENTAR — Registrar o incidente e as ações tomadas
```

---

## 8. Gestão de Custos (FinOps)

### 8.1 Limites do AWS Free Tier

| Serviço | Limite Gratuito (12 meses) | Limite Always Free |
|---|---|---|
| EC2 t2.micro | 750 horas/mês | — |
| S3 | 5 GB armazenamento | — |
| RDS db.t2.micro | 750 horas/mês | — |
| Lambda | — | 1M invocações/mês |
| CloudWatch | 10 métricas | 3 dashboards |
| SNS | — | 1.000 notificações/mês |

### 8.2 Tags de Custo Obrigatórias

Todos os recursos devem ter as tags:
```
Project     = cloud-bridge
Environment = dev | staging | prod
Owner       = nome-da-organizacao
CostCenter  = [departamento ou projeto]
```

### 8.3 Revisão Mensal de Custos

- [ ] Revisar relatório do Cost Explorer
- [ ] Verificar recursos ociosos (instâncias paradas, EIPs não associados)
- [ ] Conferir alertas de billing configurados
- [ ] Documentar variações > 20% em relação ao mês anterior

---

## 9. Checklist de Conformidade

Use esta lista para auditar mensalmente a conformidade do ambiente:

### Segurança de Acesso
- [ ] MFA habilitado na conta raiz
- [ ] MFA habilitado para todos os administradores
- [ ] Conta raiz sem chaves de acesso ativas
- [ ] Chaves de acesso rotacionadas nos últimos 90 dias
- [ ] Usuários inativos (>60 dias) desabilitados

### Configuração de Rede
- [ ] Security Groups sem regras `0.0.0.0/0` na porta 22 (SSH restrito ao IP da organização)
- [ ] VPC com subnets privadas para banco de dados
- [ ] Nenhum recurso sensível com IP público desnecessário

### Proteção de Dados
- [ ] Todos os buckets S3 com bloqueio de acesso público habilitado
- [ ] Criptografia em repouso habilitada em todos os recursos
- [ ] Backup executado e testado no último mês

### Monitoramento
- [ ] CloudTrail habilitado em todas as regiões utilizadas
- [ ] Alertas de billing configurados e funcionando
- [ ] Logs de aplicação sem dados pessoais em texto claro

### LGPD
- [ ] Inventário de dados atualizado
- [ ] Política de privacidade publicada (se aplicável)
- [ ] Procedimento de atendimento a titulares documentado

---

*Cloud-Bridge Framework de Governança — versão 1.0 — Salvador, Bahia*
*Mantido pela comunidade Cloud-Bridge. Contribuições bem-vindas via Pull Request.*

# ☁️ Cloud-Bridge

**Framework de Gestão e Implementação de Nuvem para Pequenas Organizações**

> Nascido da AV1 de Desafios da Engenharia de Computação — UNIRB Salvador

---

## 📋 Sumário

1. [Sobre o Projeto](#sobre-o-projeto)
2. [Problema](#problema)
3. [Solução](#solução)
4. [Arquitetura](#arquitetura)
5. [Pré-requisitos](#pré-requisitos)
6. [Como Usar](#como-usar)
7. [Módulos](#módulos)
8. [Governança e Segurança](#governança-e-segurança)
9. [Monitoramento de Custos (FinOps)](#monitoramento-de-custos-finops)
10. [Contribuindo](#contribuindo)
11. [Licença](#licença)

---

## 🎯 Sobre o Projeto

O **Cloud-Bridge** é um ecossistema de scripts automatizados, templates de Infrastructure as Code (IaC) e manuais de governança desenvolvido especificamente para **ONGs, associações comunitárias e pequenas empresas** que desejam adotar serviços de nuvem de forma segura, organizada e com **custo zero ou reduzido**.

O projeto atua como a **ponte de gestão** que falta entre as grandes plataformas de nuvem (AWS, GCP, Azure) e os pequenos usuários que não possuem equipe técnica dedicada.

### Impacto Esperado

| Indicador | Antes | Com Cloud-Bridge |
|---|---|---|
| Tempo de provisionamento | Horas/dias | < 15 minutos |
| Risco de cobrança inesperada | Alto | Baixo (alertas automáticos) |
| Configuração de segurança | Manual e inconsistente | Automatizada e padronizada |
| Curva de aprendizado | Muito íngreme | Guiada e documentada |

---

## 🔍 Problema

A **exclusão digital infraestrutural** afeta pequenas entidades que, por falta de gestão técnica e financeira, não conseguem:

- Escalar seus serviços digitais com segurança;
- Proteger dados sensíveis de beneficiários e clientes;
- Evitar cobranças inesperadas ao usar plataformas de nuvem;
- Migrar de soluções locais (on-premise) para a nuvem sem suporte técnico caro.

No contexto de **Salvador e Região Metropolitana**, esse problema é especialmente crítico para ONGs da área social, cooperativas e MEIs do setor criativo.

---

## 💡 Solução

O Cloud-Bridge propõe um **Hub de Nuvem Comunitária** com três pilares:

```
┌─────────────────────────────────────────────────────────────┐
│                       CLOUD-BRIDGE                          │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  AUTOMAÇÃO   │  │  GOVERNANÇA  │  │    FINOPS/CUSTO  │  │
│  │    (IaC)     │  │  SEGURANÇA   │  │   MONITORAMENTO  │  │
│  │              │  │              │  │                  │  │
│  │  Terraform   │  │  Framework   │  │  Alertas de      │  │
│  │  Ansible     │  │  de Políticas│  │  Billing         │  │
│  │  Docker      │  │  e Controles │  │  Dashboards      │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 1️⃣ Automação (IaC)
Scripts de Terraform e playbooks Ansible para que a infraestrutura básica seja provisionada com um único comando.

### 2️⃣ Segurança e Governança
Um "Framework de Governança para Pequenas Entidades" com políticas de controle de acesso, backup e conformidade com a LGPD.

### 3️⃣ FinOps — Controle de Gastos
Painel e alertas de custos para garantir que a "nuvem gratuita" nunca gere cobranças surpresa.

---

## 🏗️ Arquitetura

```
Cloud-Bridge/
├── terraform/               # Infrastructure as Code (IaC)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── compute/         # EC2 / instâncias de VM
│       ├── storage/         # S3 / armazenamento de objetos
│       └── networking/      # VPC, subnets, security groups
├── ansible/                 # Configuração e hardening de servidores
│   ├── inventory/
│   ├── playbook.yml
│   └── roles/
│       ├── common/
│       ├── docker/
│       └── monitoring/
├── docker/                  # Conteinerização de aplicações
│   ├── docker-compose.yml
│   └── services/
├── monitoring/              # Monitoramento de custos e alertas
│   ├── billing_alerts.sh
│   └── dashboards/
├── governance/              # Framework de governança e segurança
│   ├── FRAMEWORK.md
│   ├── policies/
│   └── checklists/
└── docs/                    # Documentação e guias
    ├── SETUP.md
    ├── FINOPS.md
    └── ONBOARDING.md
```

---

## ✅ Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.14
- [Docker](https://docs.docker.com/engine/install/) e [Docker Compose](https://docs.docker.com/compose/install/) >= 2.0
- Conta AWS (Free Tier) **ou** GCP (Always Free) **ou** Oracle Cloud (Always Free)
- [AWS CLI](https://aws.amazon.com/cli/) configurada (se usar AWS)
- Python >= 3.10 (para scripts de monitoramento)

---

## 🚀 Como Usar

### Início Rápido (Provisionamento Completo)

```bash
# 1. Clone o repositório
git clone https://github.com/RafaCVarela/Cloud-Bridge.git
cd Cloud-Bridge

# 2. Configure suas credenciais de nuvem
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edite terraform.tfvars com seus dados

# 3. Provisione a infraestrutura
cd terraform
terraform init
terraform plan
terraform apply

# 4. Configure os servidores com Ansible
cd ../ansible
ansible-playbook -i inventory/hosts playbook.yml

# 5. Inicie os serviços com Docker Compose
cd ../docker
docker compose up -d

# 6. Configure alertas de custo
cd ../monitoring
bash billing_alerts.sh
```

### Uso Modular

Você pode usar apenas os módulos que precisar. Consulte a documentação em [`docs/SETUP.md`](docs/SETUP.md).

---

## 📦 Módulos

| Módulo | Descrição | Provedor |
|---|---|---|
| `terraform/modules/compute` | VM de uso geral (t2.micro / e2-micro) | AWS / GCP |
| `terraform/modules/storage` | Bucket de objetos (S3 / GCS) | AWS / GCP |
| `terraform/modules/networking` | VPC, Subnets, Security Groups | AWS / GCP |
| `ansible/roles/common` | Hardening básico do SO (Ubuntu/Debian) | Qualquer |
| `ansible/roles/docker` | Instalação e configuração do Docker | Qualquer |
| `ansible/roles/monitoring` | Prometheus + Grafana (Open Source) | Qualquer |
| `docker/services` | Stack de aplicações conteinerizadas | Qualquer |

---

## 🔐 Governança e Segurança

O Framework de Governança aborda:

- **Controle de Acesso**: Princípio do menor privilégio (IAM/RBAC)
- **Criptografia**: Em trânsito (TLS) e em repouso (AES-256)
- **Backup**: Política automatizada de backup com retenção de 30 dias
- **Conformidade LGPD**: Checklist de adequação para entidades que tratam dados pessoais
- **Resposta a Incidentes**: Playbook de ação em caso de vazamento ou comprometimento

Consulte [`governance/FRAMEWORK.md`](governance/FRAMEWORK.md) para o guia completo.

---

## 💰 Monitoramento de Custos (FinOps)

O módulo de FinOps garante que você **nunca seja surpreendido** com cobranças:

- **Alertas de billing** por e-mail quando o gasto superar o limite configurado
- **Dashboard de custos** via Grafana com dados do AWS Cost Explorer / GCP Billing
- **Relatório mensal** automatizado comparando uso real vs. limites gratuitos
- **Dicas de otimização** baseadas no perfil de uso

Consulte [`docs/FINOPS.md`](docs/FINOPS.md) para configuração.

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Este é um projeto comunitário.

1. Faça um fork do repositório
2. Crie uma branch: `git checkout -b feature/minha-melhoria`
3. Commit suas mudanças: `git commit -m 'feat: adiciona suporte a GCP'`
4. Abra um Pull Request

Consulte [`CONTRIBUTING.md`](CONTRIBUTING.md) para diretrizes completas.

---

## 📄 Licença

Distribuído sob a Licença MIT. Consulte [`LICENSE`](LICENSE) para mais informações.

---

<p align="center">
  Feito com ❤️ em Salvador, Bahia — para democratizar a nuvem no Brasil.
</p>

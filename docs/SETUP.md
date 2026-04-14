# 🚀 Guia de Configuração — Cloud-Bridge

Este guia conduz você pelo processo completo de implantação do Cloud-Bridge,
desde a criação da conta até a primeira aplicação em execução.

---

## Parte 1 — Criando Sua Conta AWS (Free Tier)

### 1.1 Criar a Conta

1. Acesse [aws.amazon.com/free](https://aws.amazon.com/free/)
2. Clique em **"Create a Free Account"**
3. Preencha: e-mail, senha e nome da conta (ex: `minhaong-cloud`)
4. Insira um cartão de crédito (necessário, mas **não será cobrado** dentro dos limites gratuitos)
5. Escolha o plano **Free** (Basic Support)

### 1.2 Proteger a Conta Raiz

⚠️ **Importante**: A conta raiz tem acesso total. Proteja-a com MFA:

1. No Console AWS → clique no nome do usuário → **Security Credentials**
2. Em **Multi-factor authentication (MFA)** → **Assign MFA device**
3. Escolha **Authenticator App** e siga as instruções
4. Use **Google Authenticator** ou **Authy** no celular

### 1.3 Criar Usuário Administrador (não usar a conta raiz)

```bash
# Via AWS CLI (após configurar a conta raiz uma vez)
aws iam create-user --user-name admin-tecnico
aws iam attach-user-policy --user-name admin-tecnico \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-access-key --user-name admin-tecnico
```

---

## Parte 2 — Configurando as Ferramentas

### 2.1 AWS CLI

```bash
# Linux/macOS
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# Configurar com as credenciais do usuário admin-tecnico
aws configure
# AWS Access Key ID: [sua-access-key]
# AWS Secret Access Key: [sua-secret-key]
# Default region name: sa-east-1
# Default output format: json
```

### 2.2 Terraform

```bash
# Linux (Ubuntu/Debian)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verificar instalação
terraform version
```

### 2.3 Ansible

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y ansible

# Verificar instalação
ansible --version
```

---

## Parte 3 — Provisionando a Infraestrutura

### 3.1 Configurar Variáveis

```bash
cd Cloud-Bridge/terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edite com seus dados
```

### 3.2 Criar Key Pair para SSH

```bash
# Criar par de chaves
aws ec2 create-key-pair \
  --key-name cloud-bridge-key \
  --query "KeyMaterial" \
  --output text > ~/.ssh/cloud-bridge-key.pem

chmod 400 ~/.ssh/cloud-bridge-key.pem
```

Adicione `key_pair_name = "cloud-bridge-key"` ao `terraform.tfvars`.

### 3.3 Executar o Terraform

```bash
# Inicializar (baixa os providers)
terraform init

# Visualizar o que será criado (sem criar nada)
terraform plan

# Criar a infraestrutura
terraform apply
# Digite "yes" quando solicitado

# Anote os outputs, especialmente instance_public_ip e ssh_command
```

### 3.4 Verificar Criação

```bash
# Testar conexão SSH
ssh -i ~/.ssh/cloud-bridge-key.pem ubuntu@$(terraform output -raw instance_public_ip)

# Verificar se Docker foi instalado
docker --version
```

---

## Parte 4 — Configurando os Servidores com Ansible

### 4.1 Atualizar Inventory

```bash
cd ../ansible
nano inventory/hosts
# Substitua SEU_IP_AQUI pelo output instance_public_ip do Terraform
```

### 4.2 Executar o Playbook

```bash
# Verificar conectividade
ansible -i inventory/hosts cloud_bridge_servers -m ping

# Executar configuração completa
ansible-playbook -i inventory/hosts playbook.yml

# Executar apenas hardening de segurança
ansible-playbook -i inventory/hosts playbook.yml --tags hardening
```

---

## Parte 5 — Iniciando as Aplicações

### 5.1 Configurar Variáveis do Docker

```bash
cd ../docker
cp .env.example .env
nano .env  # Configure domínio, e-mail e senhas
```

### 5.2 Iniciar os Serviços

```bash
docker compose up -d

# Verificar status
docker compose ps

# Acompanhar logs
docker compose logs -f
```

### 5.3 Acessar os Painéis

| Serviço | URL | Credencial Padrão |
|---|---|---|
| Aplicação Principal | https://SEU_DOMINIO | — |
| Grafana (monitoramento) | http://SEU_IP:3000 | admin / [definida no Ansible] |
| Prometheus | http://SEU_IP:9090 | — |

⚠️ **Defina a senha do Grafana** via variável `grafana_admin_password` no Ansible antes de iniciar!

---

## Parte 6 — Configurando Alertas de Custo

```bash
cd ../monitoring
export ALERT_EMAIL=responsavel@suaorg.org.br
export BILLING_THRESHOLD_USD=5.0
bash billing_alerts.sh
```

Confirme a inscrição no e-mail que receberá do AWS SNS.

---

## Próximos Passos

- [ ] Leia o [Framework de Governança](../governance/FRAMEWORK.md)
- [ ] Execute o [Checklist Mensal de Segurança](../governance/checklists/monthly-security-review.md)
- [ ] Configure [FinOps](FINOPS.md)
- [ ] Faça o [Onboarding](ONBOARDING.md) da sua equipe

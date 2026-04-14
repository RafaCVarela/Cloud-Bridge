# 🤝 Guia de Contribuição — Cloud-Bridge

Obrigado pelo interesse em contribuir com o Cloud-Bridge!
Este é um projeto comunitário que visa democratizar o acesso à nuvem
para pequenas organizações no Brasil.

---

## Como Contribuir

### 1. Reportar Problemas (Issues)

Encontrou um bug ou tem uma sugestão?

1. Acesse a aba **Issues** no GitHub
2. Clique em **New Issue**
3. Escolha o template adequado:
   - 🐛 **Bug Report** — algo não está funcionando
   - 💡 **Feature Request** — sugestão de melhoria
   - 📚 **Documentation** — melhoria na documentação
   - 🔒 **Security** — vulnerabilidade (veja abaixo)

### 2. Enviar Pull Requests

```bash
# 1. Fork o repositório no GitHub

# 2. Clone o seu fork
git clone https://github.com/SEU_USUARIO/Cloud-Bridge.git
cd Cloud-Bridge

# 3. Crie uma branch descritiva
git checkout -b feature/suporte-a-gcp
# ou
git checkout -b fix/corrige-alarme-billing
# ou
git checkout -b docs/adiciona-guia-oracle-cloud

# 4. Faça suas alterações e commit
git add .
git commit -m "feat: adiciona suporte a Oracle Cloud Always Free"

# 5. Envie para o seu fork
git push origin feature/suporte-a-gcp

# 6. Abra um Pull Request no GitHub
```

---

## Convenções de Commit

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

| Prefixo | Uso |
|---|---|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `docs:` | Documentação |
| `refactor:` | Refatoração sem mudança de comportamento |
| `security:` | Correção de segurança |
| `chore:` | Tarefas de manutenção |

---

## O que Você Pode Contribuir

### Alta Prioridade 🔴

- Suporte ao Google Cloud Platform (GCP)
- Suporte ao Oracle Cloud (Always Free — muito generoso!)
- Script de monitoramento de Free Tier em tempo real
- Testes automatizados para os scripts bash/Python

### Média Prioridade 🟡

- Tradução da documentação para inglês
- Templates Terraform para Azure
- Dashboard Grafana pré-configurado para Cloud-Bridge
- Playbook Ansible para CentOS/Rocky Linux

### Boas Práticas para Contribuir

- Documente em **português brasileiro**
- Teste suas mudanças antes de enviar
- Siga o formato dos arquivos existentes
- Não inclua credenciais ou segredos em nenhum arquivo
- Prefira soluções simples e bem documentadas

---

## Reportando Vulnerabilidades de Segurança

**NÃO abra uma Issue pública para vulnerabilidades de segurança.**

Envie um e-mail privado para o mantenedor do projeto com:
- Descrição da vulnerabilidade
- Passos para reproduzir
- Impacto potencial

Responderemos em até 72 horas.

---

## Código de Conduta

- Seja respeitoso e inclusivo
- Foco no problema, não na pessoa
- Aceite críticas construtivas
- Ajude quem está começando

---

*Juntos, democratizamos a nuvem para o Brasil!* 🇧🇷☁️

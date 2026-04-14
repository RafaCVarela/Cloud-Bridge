# 👋 Guia de Onboarding — Cloud-Bridge

Bem-vindo(a) ao Cloud-Bridge! Este guia é para novos membros da equipe
que precisam entender como nossa infraestrutura de nuvem funciona.

---

## O que é o Cloud-Bridge?

O Cloud-Bridge é o sistema de infraestrutura em nuvem da nossa organização.
Ele gerencia nossos servidores, bancos de dados, armazenamento de arquivos
e sistemas de monitoramento de forma automatizada e segura.

**Pense nele como o "sistema nervoso digital" da organização.**

---

## Estrutura da Equipe

| Papel | Responsabilidade | Acesso |
|---|---|---|
| Responsável Técnico | Gerencia toda a infraestrutura | Administrador |
| Desenvolvedor | Desenvolve e implanta aplicações | Power User |
| Operacional | Usa as aplicações | Usuário padrão |
| Gestor | Aprova gastos e políticas | Leitura + relatórios |

---

## Solicitar Acesso

1. Envie e-mail para o **Responsável Técnico** com:
   - Nome completo
   - Cargo/função
   - Justificativa do acesso necessário
   - Prazo (se acesso temporário)

2. O acesso será criado em até **2 dias úteis**

3. Você receberá por e-mail:
   - Suas credenciais temporárias
   - Link para o guia de primeiro acesso
   - Contato do suporte técnico

---

## Primeiros Passos

### Instalar Autenticador MFA

Antes de qualquer coisa, instale um app de autenticação no celular:
- **Google Authenticator** (Android/iOS)
- **Authy** (Android/iOS — recomendado por ter backup)
- **Microsoft Authenticator** (Android/iOS)

### Primeiro Login no Console AWS

1. Acesse o link enviado pelo Responsável Técnico
2. Use a senha temporária
3. **Você será obrigado a trocar a senha** no primeiro acesso
4. Configure o MFA quando solicitado
5. **NUNCA compartilhe sua senha com ninguém**, nem com o Responsável Técnico

---

## O que Você Pode (e Não Pode) Fazer

### ✅ Permitido

- Visualizar logs e métricas no Grafana
- Fazer upload de arquivos no S3 (dentro do seu projeto)
- Acessar o banco de dados (somente leitura, se necessário)
- Criar recursos dentro do orçamento aprovado

### ❌ Proibido

- Criar recursos sem aprovação prévia (podem gerar custos inesperados!)
- Compartilhar credenciais ou chaves de acesso
- Deletar recursos sem aprovação
- Acessar dados de outros projetos
- Usar recursos pessoais da organização para projetos pessoais

---

## Em Caso de Problemas

### Esqueceu a Senha

Contate o **Responsável Técnico** — NÃO tente resetar por conta própria.

### Suspeita de Comprometimento

Se suspeitar que suas credenciais foram comprometidas:

1. **IMEDIATAMENTE** avise o Responsável Técnico
2. Não tente resolver sozinho
3. Documente o que aconteceu (hora, o que você estava fazendo)

### Suporte Técnico

- **Canal Slack/WhatsApp**: [definir pelo time]
- **E-mail**: [definir pelo time]
- **Horário**: [definir pelo time]

---

## Boas Práticas do Dia a Dia

1. **Sempre faça logout** do console AWS após o uso
2. **Use a VPN** (se disponível) ao acessar o servidor via SSH
3. **Não copie dados de produção** para ambientes de desenvolvimento
4. **Reporte qualquer comportamento estranho** — não tenha medo de parecer exagerado
5. **Leia os alertas** — eles existem por um motivo

---

## Recursos de Aprendizado

Se quiser aprender mais sobre a tecnologia que usamos:

| Recurso | Link | Nível |
|---|---|---|
| AWS Free Tier | [aws.amazon.com/free](https://aws.amazon.com/free) | Iniciante |
| Terraform em 30 min | [learn.hashicorp.com](https://learn.hashicorp.com/terraform) | Intermediário |
| Docker para Iniciantes | [docker.com/get-started](https://www.docker.com/get-started/) | Iniciante |
| Segurança em Nuvem | [AWS Well-Architected](https://aws.amazon.com/architecture/well-architected/) | Intermediário |

---

*Qualquer dúvida, não hesite em perguntar. Aqui não existe pergunta boba!* 🚀

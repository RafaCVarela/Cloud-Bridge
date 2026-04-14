# Política de Controle de Acesso — Cloud-Bridge

## Objetivo
Garantir que apenas pessoas autorizadas acessem os recursos de nuvem,
seguindo o princípio do menor privilégio.

## Escopo
Aplica-se a todos os membros da organização que utilizam a infraestrutura
Cloud-Bridge, incluindo colaboradores, voluntários e fornecedores terceiros.

## Regras

### Criação de Contas
1. Toda conta de acesso deve ser solicitada formalmente ao responsável técnico
2. O acesso deve ser revisado e aprovado antes de ser concedido
3. Contas de fornecedores externos devem ter validade definida (máximo 90 dias)

### Níveis de Acesso

| Nível | Quem | Permissões |
|---|---|---|
| Administrador | 1-2 responsáveis técnicos | Acesso total (com MFA obrigatório) |
| Desenvolvedor | Equipe técnica | Leitura/escrita nos projetos designados |
| Operacional | Usuários regulares | Somente leitura |
| Externo | Fornecedores/auditores | Acesso limitado por tempo |

### Desligamento/Saída
- Acesso revogado **imediatamente** após saída da organização
- Credenciais rotacionadas se houver suspeita de comprometimento
- Registrar revogação no log de controle de acesso

## Revisão
Esta política deve ser revisada **a cada 6 meses** pelo responsável técnico.

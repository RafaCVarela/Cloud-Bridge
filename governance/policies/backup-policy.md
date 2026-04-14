# Política de Backup e Recuperação — Cloud-Bridge

## Objetivo
Garantir a disponibilidade e integridade dos dados da organização em caso
de falha, desastre ou incidente de segurança.

## Frequência de Backup

| Tipo de Dado | Frequência | Retenção | Método |
|---|---|---|---|
| Banco de dados (produção) | Diário (02:00 BRT) | 7 dias locais + 30 dias S3 | pg_dump + S3 |
| Arquivos de usuários | Diário | 30 dias | S3 versioning |
| Configurações do sistema | Semanal | 90 dias | Git + S3 |
| Snapshots de VM | Semanal | 4 semanas | AMI Snapshot |

## Procedimento de Teste de Restore

Execute mensalmente e documente em `checklists/backup-restore-log.md`:

```bash
# 1. Listar backups disponíveis
aws s3 ls s3://cloud-bridge-backups/

# 2. Baixar backup mais recente
aws s3 cp s3://cloud-bridge-backups/YYYY-MM-DD/backup.sql.gz /tmp/

# 3. Restaurar em ambiente de teste
gunzip /tmp/backup.sql.gz
psql -U cbadmin -d cloudbridge_test < /tmp/backup.sql

# 4. Validar integridade dos dados
# (execute queries de verificação específicas da aplicação)
```

## Responsabilidades
- **Responsável Técnico**: Configurar e monitorar os backups
- **Gestor da Organização**: Aprovar testes mensais e assinar o log

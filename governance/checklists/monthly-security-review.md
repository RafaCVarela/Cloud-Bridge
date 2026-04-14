# Checklist Mensal de Segurança — Cloud-Bridge

**Mês/Ano:** ___________  
**Responsável:** ___________  
**Data de Revisão:** ___________

---

## 🔐 Controle de Acesso

- [ ] Conta raiz AWS/GCP sem uso nos últimos 30 dias
- [ ] MFA habilitado para todos os administradores
- [ ] Chaves de acesso revisadas (nenhuma com mais de 90 dias)
- [ ] Usuários inativos (>60 dias sem login) desabilitados
- [ ] Acessos de fornecedores externos revisados e válidos

## 🌐 Configuração de Rede

- [ ] Security Groups: nenhuma regra `0.0.0.0/0` na porta 22
- [ ] Portas desnecessárias fechadas nos Security Groups
- [ ] Todos os recursos sensíveis na subnet privada

## 💾 Backup e Dados

- [ ] Backup automatizado executou sem erros esta semana
- [ ] Teste de restore realizado este mês
- [ ] Buckets S3 com bloqueio de acesso público habilitado
- [ ] Criptografia em repouso verificada em todos os recursos

## 📊 Monitoramento

- [ ] CloudTrail ativo e sem erros
- [ ] Alertas de billing funcionando (envie um teste)
- [ ] Grafana/Prometheus acessível e com dados atualizados
- [ ] Nenhum alerta crítico não resolvido

## 💰 FinOps

- [ ] Relatório de custos revisado
- [ ] Recursos ociosos identificados e justificados ou removidos
- [ ] Gastos dentro do orçamento mensal aprovado

## 📝 Resultado

- [ ] ✅ Aprovado — nenhuma ação necessária
- [ ] ⚠️ Aprovado com ressalvas — ações registradas abaixo
- [ ] ❌ Reprovado — ações corretivas em andamento

**Ações Corretivas (se aplicável):**

| # | Ação | Responsável | Prazo |
|---|---|---|---|
| 1 | | | |
| 2 | | | |

**Assinatura:** ___________

# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Fluxos do Sistema

### 1. Cadastro de Cliente
1. Nutricionista faz login.
2. Navega à área de “Clientes”.
3. Clica em “Adicionar novo cliente”.
4. Preenche os campos obrigatórios:
   - Nome
   - Idade
   - Sexo
   - Objetivo (emagrecer, ganhar massa, manter)
   - Restrições/alergias
   - Preferências alimentares
5. Salva o cadastro.
6. Cliente aparece na lista.

### 2. Montagem e Ajuste da Dieta
1. Seleciona cliente na lista.
2. Clica em “Montar Dieta” ou “Editar Dieta”.
3. Visualiza estrutura das refeições (café, almoço, jantar, lanches).
4. Adiciona alimentos, porções, horários.
5. Ajusta ou salva dieta.

### 3. Exportação da Dieta em PDF
1. Clica em “Exportar PDF”.
2. Sistema gera PDF da dieta.
3. Nutricionista pode baixar, enviar por e-mail/WhatsApp.

### 4. Gestão de Clientes/Dietas
1. Acessa painel “Clientes”.
2. Visualiza lista de clientes.
3. Busca, filtra, visualiza detalhes.
4. Visualiza histórico de dietas.
5. Edita, duplica ou cria nova dieta.

### 5. Login
1. Acessa tela de login.
2. Informa e-mail/usuário e senha.
3. Acessa painel principal.

---

**Resumo Visual dos Fluxos**
- Login → Painel de Clientes → Cadastro/Seleção de Cliente → Montagem de Dieta → Exportação PDF
- Painel de Clientes → Histórico de Dietas → Visualizar/Duplicar/Editar Dieta
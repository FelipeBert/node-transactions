# Node Transactions API & Infrastructure

Uma aplicação backend RESTful simples para gerenciamento de transações financeiras, desenvolvida com foco em **boas práticas de infraestrutura, provisionamento automatizado e resiliência**.

Este projeto demonstra a integração de uma API Node.js/TypeScript moderna com um ambiente de infraestrutura como código (IaC) rodando em uma máquina virtual CentOS, gerenciado via Vagrant e scripts Shell.

---

## 🛠 Arquitetura e Stack Tecnológico

**Aplicação (Backend):**
* **Runtime:** Node.js v22 (utilizando módulos nativos ESM e `--env-file`).
* **Framework Web:** Fastify (Alta performance e baixo overhead).
* **Banco de Dados:** SQLite3 gerenciado pelo **Knex.js** (Query Builder & Migrations).
* **Validação:** Zod (Validação de schemas no *runtime* e tipagem estática).
* **Transpilação:** TSX (Execução de TypeScript com esbuild on-the-fly, substituindo o obsoleto `ts-node`).

**Infraestrutura e DevOps:**
* **Ambiente Virtual:** Vagrant + VirtualBox (Box: `eurolinux-vagrant/centos-stream-9`).
* **Provisionamento:** Shell Script (`apideploy.sh`) para configuração automatizada do zero.
* **Gerenciamento de Processos:** PM2 (Daemonização, auto-restart e monitoramento).

---

## ⚙️ Infraestrutura e Provisionamento (DevOps)

A infraestrutura deste projeto foi desenhada para ser imutável e reproduzível. Ao rodar a aplicação, um script de deploy (`apideploy.sh`) assume o controle da VM e executa as seguintes etapas críticas:

1. **Setup do Sistema:** Atualiza pacotes e instala dependências de compilação do CentOS (Git, Python3, Development Tools).
2. **Isolamento de Ambiente:** Instala o Node.js v22 de forma isolada utilizando o NVM, prevenindo conflitos no SO.
3. **Injeção de Variáveis:** Gera dinamicamente o arquivo `.env` para o ambiente de testes na VM.
4. **Data Preparation:** Executa o `knex migrate:latest` garantindo que o banco de dados (SQLite) seja construído estruturalmente antes do código fonte rodar.
5. **Daemonização (PM2):** A aplicação não fica atrelada a uma sessão de terminal (`nohup`). O PM2 assume o processo, executa a API via `npm run start` (usando o TSX sob o capô) e salva o estado (`pm2 save`) para garantir que o serviço sobreviva a reboots da máquina host.

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* [VirtualBox](https://www.virtualbox.org/) instalado na máquina host.
* [Vagrant](https://www.vagrantup.com/) instalado na máquina host.

### 1. Subindo a Infraestrutura
Clone este repositório e, na raiz do projeto, execute o comando de orquestração do Vagrant:

```bash
vagrant up
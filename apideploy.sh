#!/bin/bash

set -euo pipefail

REPO_URL="https://github.com/FelipeBert/node-transactions.git"
APP_DIR="/tmp/node-transactions"

log() {
  printf '==> %s\n' "$*"
}

main() {
  log "Installing git..."
  sudo dnf install git -y

  if [ ! -d "$APP_DIR/.git" ]; then
    log "Cloning repository into $APP_DIR..."
    rm -rf "$APP_DIR"
    git clone "$REPO_URL" "$APP_DIR"
  else
    log "Repository already exists, using $APP_DIR"
  fi

  cd "$APP_DIR"

  log "Loading nvm environment..."
  # Desliga temporariamente a checagem de variáveis não definidas
  set +u
  if [ -f "$HOME/.nvm/nvm.sh" ]; then
    . "$HOME/.nvm/nvm.sh"
  elif [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
  # Religa a checagem
  set -u

  # Se o NVM ainda não existe, instala e carrega de forma segura
  if ! command -v nvm >/dev/null 2>&1; then
    log "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
    
    set +u
    . "$HOME/.nvm/nvm.sh"
    set -u
  fi

  log "Installing Node.js 22..."
  nvm install 22
  nvm use 22

  log "Installing system build dependencies..."
  sudo dnf groupinstall "Development Tools" -y
  sudo dnf install python3-devel -y

  log "Installing project dependencies..."
  npm install --save-dev typescript @types/node ts-node

  log "Installing PM2 globally..."
  npm install -g pm2

  log "Configuring environment..."
  cat > .env <<'EOF'
DATABASE_URL="./db/app.db"
NODE_ENV="development"
EOF

  log "Running migrations..."
  # Boas práticas: Node 22 lê o .env nativamente com --env-file.
  # O --loader ts-node/esm ensina o Node a resolver imports de TS sem extensão.
  node --env-file=.env --loader ts-node/esm ./node_modules/.bin/knex migrate:latest --knexfile knexfile.ts

  log "Starting application with PM2..."
  # Passamos as flags do Node 22 diretamente para dentro do PM2
  pm2 start npm --name "api-transactions" -- run start

  log "Saving PM2 state to resurrect on reboot..."
  pm2 save
}

main "$@"
#!/usr/bin/env bash
set -euo pipefail

# Ubuntu on WSL assumed.
# Installs: nvm, Node.js (LTS), AWS CLI v2, AWS CDK, Python 3.13, Docker Engine.

export DEBIAN_FRONTEND=noninteractive

log() { printf "\n==> %s\n" "$*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

log "Update apt and install base dependencies"
sudo apt-get update -y
sudo apt-get install -y \
  ca-certificates curl gnupg lsb-release unzip zip xz-utils \
  build-essential software-properties-common

# -----------------------------
# Python 3.13 (via deadsnakes PPA)
# -----------------------------
log "Install Python 3.13 (via deadsnakes PPA)"
if ! apt-cache show python3.13 >/dev/null 2>&1; then
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt-get update -y
fi

sudo apt-get install -y \
  python3.13 python3.13-venv python3.13-dev python3.13-distutils

# Optional: make python3 -> python3.13 (leave off by default; uncomment if you want)
# sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 20

log "Python version:"
python3.13 --version

# -----------------------------
# nvm + Node.js (LTS)
# -----------------------------
log "Install nvm"
if [ ! -d "${HOME}/.nvm" ]; then
  # Official install script
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Load nvm into this shell
export NVM_DIR="${HOME}/.nvm"
# shellcheck disable=SC1091
[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"

log "Install Node.js (LTS) via nvm"
nvm install --lts
nvm use --lts
node -v
npm -v

# -----------------------------
# AWS CLI v2
# -----------------------------
log "Install AWS CLI v2"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) AWS_ARCH="x86_64" ;;
  aarch64|arm64) AWS_ARCH="aarch64" ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

TMP_DIR="$(mktemp -d)"
pushd "$TMP_DIR" >/dev/null
curl -fsSLo "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
popd >/dev/null
rm -rf "$TMP_DIR"

log "AWS CLI version:"
aws --version

# -----------------------------
# AWS CDK (CLI)
# -----------------------------
log "Install AWS CDK CLI (global npm)"
npm install -g aws-cdk
cdk --version

# -----------------------------
# Docker Engine (official apt repo)
# -----------------------------
log "Install Docker Engine (official apt repository)"
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
fi

UBUNTU_CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME} stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log "Add current user to docker group (requires re-login to take effect)"
sudo groupadd -f docker
sudo usermod -aG docker "$USER"

log "Docker versions:"
docker --version || true
docker compose version || true

log "Done."
echo "NOTE:"
echo "- If 'docker' says permission denied, restart your shell/WSL to apply group membership."
echo "- On WSL, Docker Engine requires systemd enabled (Ubuntu 22.04+ typically supports this)."

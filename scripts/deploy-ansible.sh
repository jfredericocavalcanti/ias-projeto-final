#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[Ansible] Aguardando SSH ficar disponível..."

for i in $(seq 1 30); do
  if ansible -i ansible/inventory/hosts.yml app_server -m ansible.builtin.ping >/dev/null 2>&1; then
    echo "[Ansible] SSH disponível."
    break
  fi

  if [ "$i" -eq 30 ]; then
    echo "[Ansible] Não foi possível conectar via SSH."
    exit 1
  fi

  sleep 10
done

echo "[Ansible] Executando site.yml..."

if [ -n "${ANSIBLE_VAULT_PASSWORD_FILE:-}" ]; then
  ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml
else
  ansible-playbook --ask-vault-pass -i ansible/inventory/hosts.yml ansible/site.yml
fi

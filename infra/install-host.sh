#!/usr/bin/env bash
set -euo pipefail

die() {
  printf 'install-host: %s\n' "$*" >&2
  exit 1
}

[[ "$(id -u)" -eq 0 ]] || die 'execute como root'

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
[[ -f "$project_dir/.env" ]] || die "arquivo .env ausente em $project_dir; inicialize as credenciais primeiro"
[[ -x /usr/bin/docker ]] || die 'Docker não está instalado em /usr/bin/docker'
[[ -x /usr/bin/systemctl ]] || die 'systemd não está instalado'

cd "$project_dir"
/usr/bin/docker compose config --quiet

mkdir -p /usr/local/libexec /etc/systemd/system
install -o root -g root -m 0750 "$project_dir/infra/tony-network-firewall" /usr/local/libexec/tony-network-firewall

escaped_project_dir="${project_dir//\\/\\\\}"
escaped_project_dir="${escaped_project_dir//&/\\&}"
escaped_project_dir="${escaped_project_dir//|/\\|}"
for unit in tony-firewall.service tony-stack.service; do
  sed "s|@PROJECT_DIR@|$escaped_project_dir|g" \
    "$project_dir/infra/systemd/$unit" > "/etc/systemd/system/$unit"
  chown root:root "/etc/systemd/system/$unit"
  chmod 0644 "/etc/systemd/system/$unit"
done

/usr/bin/systemctl daemon-reload
/usr/bin/systemctl stop tony-stack.service 2>/dev/null || true
/usr/bin/docker compose down --remove-orphans
/usr/bin/systemctl enable tony-firewall.service tony-stack.service
/usr/bin/systemctl restart tony-firewall.service
/usr/bin/systemctl restart tony-stack.service

printf 'Tony instalado em %s\n' "$project_dir"
printf 'Estado: systemctl status tony-firewall tony-stack\n'

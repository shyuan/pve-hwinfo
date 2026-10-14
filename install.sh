#!/bin/bash
# Install pve-hwinfo on this Proxmox VE node. Run from the extracted pve-hwinfo directory.
set -euo pipefail
cd "$(dirname "$0")"

install -D -m 0755 pve-hwinfo /usr/local/sbin/pve-hwinfo
install -D -m 0755 lib/collect-nvme /usr/local/lib/pve-hwinfo/collect-nvme
install -m 0644 lib/*.snippet /usr/local/lib/pve-hwinfo/
install -m 0644 systemd/pve-hwinfo-nvme.service systemd/pve-hwinfo-nvme.timer /etc/systemd/system/
install -m 0644 systemd/99pve-hwinfo /etc/apt/apt.conf.d/99pve-hwinfo

systemctl daemon-reload
systemctl enable --now pve-hwinfo-nvme.timer
systemctl start pve-hwinfo-nvme.service

/usr/local/sbin/pve-hwinfo apply
/usr/local/sbin/pve-hwinfo status

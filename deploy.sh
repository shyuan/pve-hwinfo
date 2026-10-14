#!/bin/bash
# Copy pve-hwinfo to other cluster nodes and install it there. Run on a node that is already done:
#   bash deploy.sh <node> [<node> ...]
set -euo pipefail
cd "$(dirname "$0")/.."

for node in "$@"; do
    echo "===== $node"
    opts=(-o BatchMode=yes -o HostKeyAlias="$node" -o UserKnownHostsFile="/etc/pve/nodes/$node/ssh_known_hosts")
    tar cf - pve-hwinfo | ssh "${opts[@]}" "$node" 'cd /root && rm -rf pve-hwinfo && tar xf - && bash pve-hwinfo/install.sh'
done

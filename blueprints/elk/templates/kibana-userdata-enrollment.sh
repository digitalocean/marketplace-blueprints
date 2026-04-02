#!/bin/bash
set -euo pipefail

echo "Kibana enrollment prep (Kibana stays stopped until Terraform runs kibana-setup)" >> /var/log/user_data.log

systemctl stop kibana 2>/dev/null || true
systemctl disable kibana 2>/dev/null || true

cat > /etc/kibana/kibana.yml <<'EOM'
server.host: "0.0.0.0"

logging:
  appenders:
    file:
      type: file
      fileName: /var/log/kibana/kibana.log
      layout:
        type: json
  root:
    appenders:
      - default
      - file

pid.file: /run/kibana/kibana.pid
EOM

echo "Done (awaiting enrollment via Terraform local-exec)." >> /var/log/user_data.log

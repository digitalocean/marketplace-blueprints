resource "digitalocean_droplet" "kibana" {
  image  = "sharklabs-kibana"
  name   = "elk-stack-kibana"
  monitoring = true
  region = var.region
  size   = var.droplet_size_slug
  ssh_keys = [for key in data.digitalocean_ssh_keys.keys.ssh_keys : key.fingerprint]
  tags = [for k, v in digitalocean_tag.tags : v.id]

  depends_on = [ digitalocean_droplet.elasticsearch ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    agent = true
    timeout = "2m"
  }

  user_data = <<-EOF
    #!/bin/bash

    echo "Starting setup" >> /var/log/user_data.log

    echo "Updating Kibana config" >> /var/log/user_data.log

    cat > /etc/kibana/kibana.yml <<EOM
    server.host: "0.0.0.0"

    elasticsearch.hosts: ["http://${digitalocean_droplet.elasticsearch.ipv4_address}:9200"]

    elasticsearch.username: "kibana"
    elasticsearch.password: "${random_password.kibana_password.result}"

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

    echo "Restarting Kibana" >> /var/log/user_data.log

    systemctl restart kibana

    echo "Done!" >> /var/log/user_data.log

    EOF
}

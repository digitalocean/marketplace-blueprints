resource "digitalocean_droplet" "elasticsearch" {
  image  = "elasticsearch"
  name   = "elk-stack-elasticsearch"
  monitoring = true
  region = var.region
  size   = var.droplet_size_slug
  ssh_keys = [for key in data.digitalocean_ssh_keys.keys.ssh_keys : key.fingerprint]
  tags = [for k, v in digitalocean_tag.tags : v.id]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    agent = true
    timeout = "7m"
  }

  user_data = <<-EOF
    #!/bin/bash

    echo "Waiting for ElastiсSearch service to become active" >> /var/log/user_data.log

    while ! [ "$(systemctl is-active elasticsearch.service)" = "active" ]; do
      echo "." >> /var/log/user_data.log
      sleep 10
    done

    echo "ElasticSearch is active. Starting setup" >> /var/log/user_data.log

    sleep 30

    . /root/.digitalocean_passwords

    echo "Overwriting Kibana password env" >> /var/log/user_data.log

    cat > /root/.digitalocean_passwords <<EOM
    ELASTIC_PASSWORD=$${ELASTIC_PASSWORD}
    KIBANA_PASSWORD=${random_password.kibana_password.result}
    LOGSTASH_PASSWORD=${random_password.logstash_password.result}
    LOGSTASH_SYSTEM_PASSWORD=$${LOGSTASH_SYSTEM_PASSWORD}
    KIBANA_ENROLLMENT_TOKEN=$${KIBANA_ENROLLMENT_TOKEN}
    EOM

    echo "Updating ElasticSearch config" >> /var/log/user_data.log

    cat > /etc/elasticsearch/elasticsearch.yml <<EOM
    path.data: /var/lib/elasticsearch
    path.logs: /var/log/elasticsearch
    xpack.security.enabled: true

    http.host: 0.0.0.0
    network.host: 0.0.0.0

    discovery.type: single-node
    EOM

    echo "Refreshing ElasticSearch keystore" >> /var/log/user_data.log

    rm /etc/elasticsearch/elasticsearch.keystore
    /usr/share/elasticsearch/bin/elasticsearch-keystore create

    echo "Restarting Elastic" >> /var/log/user_data.log

    systemctl restart elasticsearch

    sleep 10

    echo "Resetting Kibana and LogStash users password via ElasticSearch API" >> /var/log/user_data.log

    . /root/.digitalocean_passwords

    kibana_payload=$(printf '{"password": "%s"}' "$KIBANA_PASSWORD")
    logstash_writer_role_payload='{"cluster": ["manage_index_templates", "monitor", "manage_ilm"],"indices": [{"names": [ "logstash-*" ], "privileges": ["write","create","create_index","manage","manage_ilm"]}]}'
    logstash_payload=$(printf '{"password": "%s", "roles": ["logstash_writer"]}' "$LOGSTASH_PASSWORD")

    echo "Creating kibana user" >> /var/log/user_data.log
    curl -uelastic:"$${ELASTIC_PASSWORD}" -XPOST -H 'Content-Type: application/json' 'http://0.0.0.0:9200/_security/user/kibana/_password?pretty' -d "$kibana_payload" >> /var/log/user_data_curl.log

    echo "Creating logstash_writer role" >> /var/log/user_data.log
    curl -uelastic:"$${ELASTIC_PASSWORD}" -XPOST -H 'Content-Type: application/json' 'http://0.0.0.0:9200/_security/role/logstash_writer' -d "$logstash_writer_role_payload" >> /var/log/user_data_curl.log

    echo "Creating logstash user" >> /var/log/user_data.log
    curl -uelastic:"$${ELASTIC_PASSWORD}" -XPOST -H 'Content-Type: application/json' 'http://0.0.0.0:9200/_security/user/logstash' -d "$logstash_payload" >> /var/log/user_data_curl.log

    echo "Kibana and LogStash users password are set, restarting ElasticSearch" >> /var/log/user_data.log

    systemctl restart elasticsearch

    echo "Done. Enjoy your ELK stack!" >> /var/log/user_data.log

    EOF
}

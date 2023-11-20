resource "digitalocean_droplet" "logstash" {
  image  = "sharklabs-logstash"
  name   = "elk-stack-logstash"
  region = var.region
  size   = var.droplet_size_slug
  ssh_keys = [for key in data.digitalocean_ssh_keys.keys.ssh_keys : key.fingerprint]
  tags = [for k, v in digitalocean_tag.tags : v.id]

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

      echo "Updating LogStash config" >> /var/log/user_data.log

      cat > /etc/logstash/logstash.conf <<EOM
      input {
        udp {
          port => 1514
          type => syslog
        }
        tcp {
          port => 10514
          type => syslog
        }
      }

      filter {
        if [type] == "syslog" {
          grok {
            match => { "message" => "%%{SYSLOGTIMESTAMP:syslog_timestamp} %%{SYSLOGHOST:syslog_hostname} %%{DATA:syslog_program}(?:\[%%{POSINT:syslog_pid}\])?: %%{GREEDYDATA:syslog_message}" }
            add_field => [ "received_at", "%%{@timestamp}" ]
            add_field => [ "received_from", "%%{host}" ]
          }
          date {
            match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
            target => "syslog_timestamp"
          }
        }
      }

      output {
        elasticsearch {
          hosts => "http://${digitalocean_droplet.elasticsearch.ipv4_address}:9200"
          user => "logstash"
          password => "${random_password.logstash_password.result}"
          index => "logstash-syslog"
        }

        stdout { codec => rubydebug }
      }
      EOM

      echo "Creating LogStash service" >> /var/log/user_data.log

      cat > /lib/systemd/system/logstash.service <<EOM
      [Unit]
      Description=logstash

      [Service]
      Type=simple
      User=logstash
      Group=logstash

      ExecStart=/usr/share/logstash/bin/logstash -f /etc/logstash/logstash.conf
      Restart=always
      WorkingDirectory=/
      Nice=19
      LimitNOFILE=16384

      TimeoutStopSec=infinity

      [Install]
      WantedBy=multi-user.target
      EOM

      chown -R logstash /usr/share/logstash

      echo "Starting LogStash service" >> /var/log/user_data.log

      systemctl enable logstash
      systemctl start logstash

      echo "Adding ports 514/udp and 10514/tcp to UFW" >> /var/log/user_data.log
      ufw allow 1514/udp
      ufw allow 10514/tcp

      echo "Done!" >> /var/log/user_data.log

      EOF
}

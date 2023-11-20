# Welcome to the DigitalOcean ELK Terraform Stack!

This stack will deploy 3 droplets with the following components: ElasticSearch, Kibana, and LogStash.

ElasticSearch, Kibana, and LogStash are configured out-of-box. 

## How to use this blueprint?

Learn [here](../../README.md#how-to-use-digitalocean-blueprints) how to use this blueprint.

Keep in mind, the ELK stack requires around 5-6 minutes after droplets creation to self-configure.

## Getting started with ELK stack

After the stack is deployed, give it 5-6 minutes to finish the configuration. After this, you can access Kibana at `http://<kibana-droplet-ip>:5601`. You should see the Login screen:

![Kibana Login](https://do-not-delete-droplet-assets.nyc3.digitaloceanspaces.com/Screenshot%202023-09-29%20at%2012.32.56.png)

If the Kibana page asks you for the enrollment token or says: "Kibana server is not ready yet.", you need to wait a bit more until it finishes configuring.

To get credentials, SSH in ElasticSearch droplet, and you will see a password for the Elastic user like this:
![Elastic Pass](https://do-not-delete-droplet-assets.nyc3.digitaloceanspaces.com/Screenshot%202023-09-21%20at%2015.55.36.png)
Near the Elastic password, you will see Kibana and LogStash passwords as well.

After you log in, you will have access to the Kibana dashboard!

LogStash if configured with the `syslog` inputs on ports: `1514` for UDP messages and `10514` for TCP messages. The output is configured to write to index `logstash-syslog` of the ElasticSearch instance created with the stack. LogStash Droplet uses the `logstash` user with the `logstash_writer` role providing access to the `logstash-*` indices.

## Stack details
- XPACK basic security enabled.
- This stack does not provide an Elastic license. If your business requires one, it is your responsibility to get one.
- Latest APT versions of ElasticSearch, Kibana, and LogStash.
- ElasticSearch discovery mode is set to a single node.
- ElasticSearch, Kibana, and LogStash and configured to run as systemctl services.
- ElasticSearch configuration logs are available at `/var/log/user_data.log` file.
- Kibana configuration logs are available at `/var/log/user_data.log` file.

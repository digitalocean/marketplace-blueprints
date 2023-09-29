# Welcome to the DigitalOcean ELK Terraform Stack!

This stack will deploy 3 droplets with the following components: ElasticSearch, Kibana and LogStash.

ElasticSearch and Kibana are configured out-of-box and LogStash is ready-to-use. 

## Getting started with ELK stack

After the stack is deployed, give it 5-6 minutes to finish configuration. After this, you can access Kibana at `http://<kibana-droplet-ip>:5601`. You should see Login screen:

![Kibana Login](https://do-not-delete-droplet-assets.nyc3.digitaloceanspaces.com/Screenshot%202023-09-29%20at%2012.32.56.png)

If Kibana page asks you for the enrollment token or says: "Kibana server is not ready yet.", you need to wait a bit more until it finishes configuring.

To get credentials, SSH in ElasticSearch droplet, and you will see password for the Elastic user like this:
![Elastic Pass](https://do-not-delete-droplet-assets.nyc3.digitaloceanspaces.com/Screenshot%202023-09-21%20at%2015.55.36.png)
Near Elastic password, you will see Kibana and LogStash password as well.

After you log in, you will have access to the Kibana dashboard!

## Stack details
- XPACK basic security enabled.
- Latest APT versions of ElasticSearch, Kibana and LogStash.
- ElasticSearch discovery mode is set to single node.
- ElasticSearch, Kibana and LogStash and configured to run as systemctl services.
- ElasticSearch configuration logs are available at `/var/log/user_data.log` file.
- Kibana configuration logs are available at `/var/log/user_data.log` file.

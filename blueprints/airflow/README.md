# Welcome to the DigitalOcean Airflow Terraform Stack!

This stack will deploy the following resources :

- A droplet with an Airflow installation pre-configured with the basic connections.
- DBaaS PostgreSQL database instance.
- DBaas Redis instance.
- Spaces Block Storage bucket for remote-logging.

The connections for PostgreSQL, Spaces Block Storage and Redis are configured out of the box.

## How to use this blueprint?

Learn [here](../../README.md#how-to-use-digitalocean-blueprints) how to use this blueprint.

## Getting started with Airflow

After the stack is deployed, you can access the Airflow dashboard at `http://<airflow-droplet-ip>`. You should see the Login screen:

![Airflow Login](https://do-not-delete-droplet-assets.nyc3.digitaloceanspaces.com/airflow-1.png)

After you log in, you will have access to the airflow dashboard!

There are two example DAGs preinstalled to test out connectivity with the Spaces bucket used for remote logging and with Redis.

![Sample DAGS](https://do-not-delete-droplet-assets.nyc3.digitaloceanspaces.com/airflow-3.png)

To view the connections details got to the Connections option under Admin.

![Connection Details](https://do-not-delete-droplet-assets.nyc3.digitaloceanspaces.com/airflow-2.png)

## Stack details

- Latest versions of Airflow, PostgreSQL and Redis.
- Airflow server and scheduler to run as systemctl services.
- Remote logging is pre-configured out of the box and is available at  `https://<bucket-name>.<region>.digitaloceanspaces.com/logs/` file.

## Security

Certbot is preinstalled. Run it to configure HTTPS.
To make your Airflow droplet more secure please refer to the [Airflow Docs](https://airflow.apache.org/docs/apache-airflow/1.10.13/security.html)

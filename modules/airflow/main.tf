terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "airflow" {
  name = var.airflow_image
}

#
# Airflow Init
#
resource "docker_container" "airflow_init" {
  name  = "airflow-init"
  image = docker_image.airflow.image_id

  env = [
    "AIRFLOW__CORE__EXECUTOR=LocalExecutor",
    "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://${var.postgres_user}:${var.postgres_password}@${var.postgres_host}:5432/${var.postgres_db}",
    "AIRFLOW__CORE__LOAD_EXAMPLES=False",
    "AIRFLOW_CONN_POSTGRES_DEFAULT=postgresql://airflow:airflow@postgres:5432/airflow",
    "_PIP_ADDITIONAL_REQUIREMENTS=apache-airflow-providers-amazon apache-airflow-providers-postgres"
  ]

  command = [
    "bash", "-c",
    <<-EOF
      until airflow db check; do
        echo "Waiting for database..."
        sleep 5
      done

      airflow db init

      airflow users create \
        --username ${var.airflow_user} \
        --password ${var.airflow_password} \
        --firstname Admin \
        --lastname User \
        --role Admin \
        --email admin@example.com || true

      airflow connections add postgres_default \
        --conn-type postgres \
        --conn-host postgres \
        --conn-schema ${var.postgres_db} \
        --conn-login ${var.postgres_user} \
        --conn-password ${var.postgres_password} \
        --conn-port 5432 || true

      airflow connections add minio_s3 \
        --conn-type aws \
        --conn-login ${var.minio_access_key} \
        --conn-password ${var.minio_secret_key} \
        --conn-extra '{"endpoint_url":"http://minio:9000"}' || true
    EOF
  ]

  networks_advanced {
    name = var.network_name
  }

  # DAGs → bind mount (CORRECTO)
  volumes {
    host_path      = abspath("${path.module}/../../dags")
    container_path = "/opt/airflow/dags"
  }

  # Logs → volumen Docker (CORRECTO)
  volumes {
    volume_name    = var.logs_volume
    container_path = "/opt/airflow/logs"
  }

  must_run = false
}

#
# Airflow Webserver
#
resource "docker_container" "airflow_web" {
  name  = "airflow-webserver"
  image = docker_image.airflow.image_id

  depends_on = [docker_container.airflow_init]

  env = [
    "AIRFLOW__CORE__EXECUTOR=LocalExecutor",
    "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://${var.postgres_user}:${var.postgres_password}@${var.postgres_host}:5432/${var.postgres_db}",
    "AIRFLOW__CORE__LOAD_EXAMPLES=False",

    "AIRFLOW__WEBSERVER__WEB_SERVER_HOST=0.0.0.0",
    "AIRFLOW__WEBSERVER__WEB_SERVER_PORT=8080",
    "AIRFLOW__WEBSERVER__BASE_URL=http://localhost:8080",
    "AIRFLOW_CONN_POSTGRES_DEFAULT=postgresql://airflow:airflow@postgres:5432/airflow",

    "_PIP_ADDITIONAL_REQUIREMENTS=apache-airflow-providers-amazon apache-airflow-providers-postgres"
  ]

  command = ["airflow", "webserver"]

  ports {
    internal = 8080
    external = 8080
  }

  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path      = abspath("${path.module}/../../dags")
    container_path = "/opt/airflow/dags"
  }

  volumes {
    volume_name    = var.logs_volume
    container_path = "/opt/airflow/logs"
  }

  restart = "unless-stopped"
}

#
# Airflow Scheduler
#
resource "docker_container" "airflow_scheduler" {
  name  = "airflow-scheduler"
  image = docker_image.airflow.image_id

  depends_on = [docker_container.airflow_web]

  env = [
    "AIRFLOW__CORE__EXECUTOR=LocalExecutor",
    "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://${var.postgres_user}:${var.postgres_password}@${var.postgres_host}:5432/${var.postgres_db}",
    "AIRFLOW_CONN_POSTGRES_DEFAULT=postgresql://airflow:airflow@postgres:5432/airflow",
    "_PIP_ADDITIONAL_REQUIREMENTS=apache-airflow-providers-amazon apache-airflow-providers-postgres"
  ]

  command = ["airflow", "scheduler"]

  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path      = abspath("${path.module}/../../dags")
    container_path = "/opt/airflow/dags"
  }

  volumes {
    volume_name    = var.logs_volume
    container_path = "/opt/airflow/logs"
  }

  restart = "unless-stopped"
}

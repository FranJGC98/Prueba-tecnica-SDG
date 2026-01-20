terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_volume" "minio" {
  name = "minio-data"
  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "postgres" {
  name = "postgres-data"
  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "airflow_logs" {
  name = "airflow-logs"
  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "airflow_dags" {
  name = "airflow-dags"
}

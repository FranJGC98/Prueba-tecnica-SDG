terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_volume" "minio" {
  name = "minio-data"
}

resource "docker_volume" "postgres" {
  name = "postgres-data"
}

resource "docker_volume" "airflow_logs" {
  name = "airflow-logs"
}

resource "docker_volume" "airflow_dags" {
  name = "airflow-dags"
}
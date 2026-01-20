output "minio" {
  description = "MinIO volume name"
  value       = docker_volume.minio.name
}

output "postgres" {
  description = "Postgres volume name"
  value       = docker_volume.postgres.name
}

output "airflow_logs" {
  description = "Airflow logs volume name"
  value       = docker_volume.airflow_logs.name
}

output "airflow_dags" {
  description = "Airflow dags volume name"
  value       = docker_volume.airflow_dags.name
}

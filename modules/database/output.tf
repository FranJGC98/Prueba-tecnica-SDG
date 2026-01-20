output "container_name" {
  value = docker_container.postgres.name
}

output "host" {
  value = "postgres"
}

output "port" {
  value = 5432
}

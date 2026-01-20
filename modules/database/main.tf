terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "postgres" {
  name = "postgres:15"
}

resource "docker_container" "postgres" {
  name  = "postgres"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}"
  ]

  volumes {
    volume_name    = var.volume_name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 5432
    external = var.port
  }

  restart = "unless-stopped"
  healthcheck {
  test     = ["CMD-SHELL", "pg_isready -U ${var.postgres_user}"]
  interval = "30s"
  timeout  = "5s"
  retries  = 5
}

}

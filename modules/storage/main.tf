terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "minio" {
  name = "minio/minio:latest"
}

resource "docker_container" "minio" {
  name  = "minio"
  image = docker_image.minio.image_id

  command = [
    "server",
    "/data",
    "--console-address",
    ":9001"
  ]

  env = [
    "MINIO_ROOT_USER=${var.minio_root_user}",
    "MINIO_ROOT_PASSWORD=${var.minio_root_password}"
  ]

  networks_advanced {
    name = var.network_name
  }

  volumes {
    volume_name    = var.volume_name
    container_path = "/data"
  }

  ports {
    internal = 9000
    external = var.api_port
  }

  ports {
    internal = 9001
    external = var.console_port
  }

  restart = "unless-stopped"
}

resource "docker_container" "minio_mc" {
  name  = "minio-mc-init"
  image = "minio/mc:latest"
  must_run = false


  depends_on = [docker_container.minio]

  entrypoint = [
  "/bin/sh", "-c",
  <<-EOF
    until mc alias set local http://minio:9000 ${var.minio_root_user} ${var.minio_root_password}; do
      echo "Waiting for MinIO..."
      sleep 3
    done

    mc mb --ignore-existing local/data-bucket
  EOF
]

  networks_advanced {
    name = var.network_name
  }

  restart = "no"
}

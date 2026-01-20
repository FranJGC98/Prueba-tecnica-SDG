resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "nginx" {
  name  = "tf-nginx-test"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8089
  }
}

module "network" {
  source        = "./modules/network"
  name          = "network01"
}

module "volumes" {
  source        = "./modules/volumes"
}

module "storage" {
  source = "./modules/storage"

  network_name = module.network.name
  volume_name  = module.volumes.minio

  minio_root_user     = "minioadmin"
  minio_root_password = "minioadmin"
}

module "databse" {
  source = "./modules/database"

  network_name = module.network.name
  volume_name  = module.volumes.postgres

  db_name     = "airflow"
  db_user     = "airflow"
  db_password = "airflow"
}

module "airflow" {
  source = "./modules/airflow"

  network_name = module.network.name

  dags_volume = module.volumes.airflow_dags
  logs_volume = module.volumes.airflow_logs

  postgres_db       = "airflow"
  postgres_user     = "airflow"
  postgres_password = "airflow"
  postgres_host     = "postgres"

  minio_access_key = "minioadmin"
  minio_secret_key = "minioadmin"
}


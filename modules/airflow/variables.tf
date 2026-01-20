variable "network_name" {
  type = string
}

variable "dags_volume" {
  type = string
}

variable "logs_volume" {
  type = string
}

variable "postgres_db" {
  type = string
}

variable "db_user" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "postgres_host" {
  type = string
}

variable "airflow_user" {
  type    = string
  default = "admin"
}

variable "airflow_password" {
  type    = string
  default = "admin"
}

variable "airflow_image" {
  type    = string
  default = "apache/airflow:2.7.3"
}

variable "minio_access_key" {
  type = string
}

variable "minio_secret_key" {
  type = string
}

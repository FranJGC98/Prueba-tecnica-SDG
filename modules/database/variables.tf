variable "network_name" {
  type        = string
  description = "Docker network name"
}

variable "volume_name" {
  type        = string
  description = "Docker volume name for Postgres data"
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "port" {
  type    = number
  default = 5432
}
variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
}

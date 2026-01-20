variable "network_name" {
  type        = string
  description = "Docker network name"
}

variable "volume_name" {
  type        = string
  description = "Docker volume name for MinIO data"
}

variable "minio_root_user" {
  type        = string
}

variable "minio_root_password" {
  type        = string
}

variable "api_port" {
  type    = number
  default = 9000
}

variable "console_port" {
  type    = number
  default = 9001
}
variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
}

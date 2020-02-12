# Start a container
resource "docker_container" "postgres" {
  name  = var.db_name
  image = docker_image.postgres.latest
  env = ["POSTGRES_PASSWORD=${random_password.password.result}",
         "POSTGRES_USER=${var.db_admin}",
         "POSTGRES_DB=${var.db_name}"]
  ports {
    internal = 5432
    external = var.db_port
  }
}

# Find the latest Postgres alpine image.
resource "docker_image" "postgres" {
  name = "postgres:alpine"
}

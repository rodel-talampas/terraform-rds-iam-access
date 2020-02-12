# Start a container
data "docker_registry_image" "localstack" {
  name = "localstack/localstack"
}

resource "docker_image" "localstack" {
  name          = data.docker_registry_image.localstack.name
  pull_triggers = [data.docker_registry_image.localstack.sha256_digest]
}

resource "docker_container" "secretsmanager" {
  name  = "secrets_manager"
  image = docker_image.localstack.latest
  env = ["SERVICES=secretsmanager",
         "DEBUG=$DEBUG",
         "DOCKER_HOST=unix:///var/run/docker.sock"]
  ports {
    internal = 4584
    external = var.secretmanager_port
  }
}

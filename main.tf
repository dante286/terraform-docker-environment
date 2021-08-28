# Create a series of pods on remote docker host that can be reached individually
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

provider "docker" {
  # Configuration options
  host = "ssh://${var.docker_user}@docker.${var.domain_name}:22"
}

data "docker_registry_image" "nginx_image" {
  name = "jwilder/nginx-proxy"
}

resource "docker_image" "rproxy_latest" {
  name          = data.docker_registry_image.nginx_image.name
  pull_triggers = [data.docker_registry_image.nginx_image.sha256_digest]
}

data "docker_registry_image" "jenkins_image" {
  name = "jenkins/jenkins"
}

resource "docker_image" "jenkins_latest" {
  name          = data.docker_registry_image.jenkins_image.name
  pull_triggers = [data.docker_registry_image.jenkins_image.sha256_digest]
}

resource "docker_volume" "jenkins_volume" {
  name = "jenkins_data"
  lifecycle {
    prevent_destroy = true
  }
}

data "docker_registry_image" "transmission_image" {
  name = "linuxserver/transmission"
}

resource "docker_image" "transmission_latest" {
  name          = data.docker_registry_image.transmission_image.name
  pull_triggers = [data.docker_registry_image.transmission_image.sha256_digest]
}

resource "docker_volume" "transmission_config" {
  name = "transmission_config"
  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "transmission_watch" {
  name = "transmission_watch"
}

resource "docker_container" "rproxy_container" {
  name    = "rproxy"
  image   = docker_image.rproxy_latest.name
  restart = "always"
  volumes {
    host_path      = var.ssl_certs
    container_path = "/etc/nginx/certs"
    read_only      = false
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/tmp/docker.sock"
    read_only      = true
  }
  ports {
    internal = "80"
    external = "80"
  }
  ports {
    internal = "443"
    external = "443"
  }

  depends_on = [
    docker_image.rproxy_latest
  ]
}

resource "docker_container" "jenkins_container" {
  name    = "jenkins"
  image   = docker_image.jenkins_latest.name
  restart = "always"
  volumes {
    container_path = "/var/jenkins_home"
    volume_name    = docker_volume.jenkins_volume.name
    read_only      = false
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  env = [
    "VIRTUAL_HOST=jenkins.${var.domain_name}",
    "VIRTUAL_PORT=8080"
  ]

  depends_on = [
    docker_image.jenkins_latest,
    docker_volume.jenkins_volume,
    docker_container.rproxy_container
  ]
}

resource "docker_container" "transmission_container" {
  name    = "transmission"
  image   = docker_image.transmission_latest.name
  restart = "always"
  volumes {
    container_path = "/config"
    volume_name    = docker_volume.transmission_config.name
    read_only      = false
  }
  volumes {
    container_path = "/watch"
    read_only      = false
    volume_name    = docker_volume.transmission_watch.name
  }
  volumes {
    host_path      = var.transmission_download_storage
    container_path = "/downloads"
    read_only      = false
  }
  env = [
    "GID=1000",
    "PUID=1000",
    "TZ=America/New_York",
    "VIRTUAL_HOST=torrent.${var.domain_name}",
    "VIRTUAL_PORT=9091"
  ]

  depends_on = [
    docker_image.transmission_latest,
    docker_volume.transmission_config,
    docker_volume.transmission_watch,
    docker_container.rproxy_container
  ]
}
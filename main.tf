# Create a series of pods on remote docker host that can be reached individually
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
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
}

resource "docker_volume" "transmission_watch" {
  name = "transmission_watch"
}

resource "docker_container" "rproxy_container" {
  name = "rproxy"
  image = docker_image.rproxy_latest
}
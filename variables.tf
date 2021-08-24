variable "domain_name" {
  type = string
  description = "Domain name for reverse proxy to use, e.g. example.com"
}

variable "docker_user" {
  type = string
  description = "User who has docker permissions on the remote host.  Passwordless SSH required."
}

variable "ssl_certs" {
    type = string
    description = "Location for ssl certs for nginx to use"
}

variable "transmission_download_storage" {
    type = string
    description = "Shared storage location for where transmission can put downloads"
}
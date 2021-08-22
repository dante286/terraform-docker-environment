variable "domain_name" {
  type = string
  description = "Domain name for reverse proxy to use, e.g. example.com"
}

variable "docker_user" {
  type = string
  description = "User who has docker permissions on the remote host.  Passwordless SSH required."
}
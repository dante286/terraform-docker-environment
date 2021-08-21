# terraform-docker-environment
Can be used to spin up a small docker environment that uses a single host backend.  
Right now this includes the following containers:
* jwilder/nginx-proxy
* jenkins/jenkins
* linuxserver/transmission

The jwilder/nginx-proxy can use environment varialbe host names to create reverse proxy virtual hosts.  This makes it very easy to create multiple containers that each have their own fully qualified domain name (FQDN) such as jenkins.example.com or transmission.example.com.

## Variables
domain name - the local domain that you will be using this on.  Such as "example.com"

# Some manual steps
1. Create DNS entries on your local DNS server to direct traffic to the containers
2. Configure transmission container to update password and whatever else you need.  See the [linuxserver transmission documentation](https://hub.docker.com/r/linuxserver/transmission) for how to configure the transmission container.

# Usage
Simply:
`terraform plan -var="domain_name=example.com"`
`terraform apply -var="domain_name=example.com"`

To delete:
`terraform destroy -var="domain_name=example.com"`
# terraform-docker-environment
Can be used to spin up a small docker environment that uses a single host backend.  
Right now this includes the following containers:
* jwilder/nginx-proxy
* jenkins/jenkins

The jwilder/nginx-proxy can use environment varialbe host names to create reverse proxy virtual hosts.  This makes it very easy to create multiple containers that each have their own fully qualified domain name (FQDN) such as jenkins.example.com.

## Variables
domain name - the local domain that you will be using this on.  Such as "example.com"

# Some manual steps
1. Create DNS entries on your local DNS server to direct traffic to the containers
2. Generate SSL certs for your sites.

# Usage
Simply:
`terraform plan -var-file="variables.tfvars"`
`terraform apply -var-file="variables.tfvars"`

To delete:
`terraform destroy -var=-file="variables.tfvars"`
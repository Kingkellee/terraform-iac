# Variables from ALB
variable "public-sg" {
    description = "Security group for external load balancer"
}

variable "public-subnet-1" {
    description = "Public Subnet for External Load Balancer"
}

variable "public-subnet-2" {
    description = "Public Subnet for External Load Balancer"
}


variable "private-sg" {
  description = "Security group for Internal Load Balance"
}

variable "private-subnet-1" {
  description = "Private subnets to deploy Internal ALB"
}
variable "private-subnet-2" {
  description = "Private subnets to deploy Internal ALB"
}

variable "ip_address_type" {
    type = string
    description = "IP address for Appplication Load Balancer"
}

variable "load_balancer_type" {
    type = string
    description = "the Type of the Load balancer"
}

# Variables from Certificate
variable "domain_name" {
    type = string
    description = "Domain name for which the certificate should be issued."
}

variable "validation_method" {
    type = string
    description = "Validartion method for our DNS"
}

variable "route53_name" {
    type = string
    description = "Route 53 hosted Zone Name"
}

variable "private_zone" {
    type = bool
    description = "Value for our Private Zone"
}

variable "tooling_route" {
    type = string
    description = "route for tooling server"
}

variable "wordpress_route" {
    type = string
    description = "route for wordpress server"
}

variable "record_type" {
    type = string
    description = "Record type for Hosted Zone"
}

# Listener Variables
variable "port" {
    type = number
    description = "Port on which the load balancer is listening"
}

variable "protocol" {
    type = string
    description = "Protocol for connections from clients to the load balancer"
}

# Target Group Variable

variable "vpc_id" {
  type        = string
  description = "The vpc ID"
}


variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}


variable "name" {
    type = string
    description = "name of the loadbalancer"
  
}
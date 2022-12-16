# Create an ALB to balance the traffic between the Instances
resource "aws_lb" "ext-alb" {
  name     = var.name
  internal = false
  security_groups = [var.public-sg]

  subnets = [
    var.public-subnet-1,
    var.public-subnet-2,
  ]

  tags = merge(
    var.tags,
    {
      Name = var.name
    },
  )

  ip_address_type    = var.ip_address_type
  load_balancer_type = var.load_balancer_type
}


# ----------------------------
#Internal Load Balancers for webservers
#---------------------------------

resource "aws_lb" "ialb" {
  name     = "ialb"
  internal = true
  security_groups = [
    var.private-sg
  ]

  subnets = [
    var.private-subnet-1,
    var.private-subnet-2,
  ]

  tags = merge(
    var.tags,
    {
      Name = var.name
    },
  )

  ip_address_type    = var.ip_address_type
  load_balancer_type = var.load_balancer_type
}
# Note: The bucket name may not work for you since buckets are unique globally in AWS, so you must give it a unique name.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "kingkellee-dev-terraform-bucket-1"
  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = true
  }
  force_destroy = true
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Dynamo DB resource for locking and consistency checking:

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

module "VPC" {
  source                              = "./modules/VPC"
  region                              = var.region
  vpc_cidr                            = var.vpc_cidr
  enable_dns_support                  = var.enable_dns_support
  enable_dns_hostnames                = var.enable_dns_hostnames
  enable_classiclink                  = var.enable_classiclink
  preferred_number_of_public_subnets  = var.preferred_number_of_public_subnets
  preferred_number_of_private_subnets = var.preferred_number_of_private_subnets
  private_subnets                     = [for i in range(1, 8, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets                      = [for i in range(2, 5, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

module "ALB" {
  source                  = "./modules/ALB"
  name                    = "ACS-ext-alb"
  vpc_id                  = module.VPC.vpc_id
  public-sg               = module.security.ALB-sg
  private-sg              = module.security.IALB-sg
  public-subnet-1         = module.VPC.public_subnets-1
  public-subnet-2         = module.VPC.public_subnets-2
  private-subnet-1        = module.VPC.private_subnets-1
  private-subnet-2        = module.VPC.private_subnets-2
  load_balancer_type      = "application"
  ip_address_type         = "ipv4"
  domain_name             = "*.kingkellee.ga"
  validation_method       = "DNS"
  route53_name            = "kingkellee.ga"
  private_zone            = false
  tooling_route           = "tooling.kingkellee.ga"
  wordpress_route         = "wordpress.kingkellee.ga"
  record_type             = "A"
  port                    = 443
  protocol                = "HTTPS"
}

module "AutoScalling" {
  source            = "./modules/Autoscalling"
  ami-web           = var.ami
  ami-bastion       = var.ami
  ami-nginx         = var.ami
  desired_capacity  = 2
  min_size          = 2
  max_size          = 2
  web-sg            = [module.security.web-sg]
  bastion-sg        = [module.security.bastion-sg]
  nginx-sg          = [module.security.nginx-sg]
  wordpress-alb-tgt = module.ALB.wordpress-tgt
  nginx-alb-tgt     = module.ALB.nginx-tgt
  tooling-alb-tgt   = module.ALB.tooling-tgt
  instance_profile  = module.VPC.instance_profile
  public_subnets    = [module.VPC.public_subnets-1, module.VPC.public_subnets-2]
  private_subnets   = [module.VPC.private_subnets-1, module.VPC.private_subnets-2]
  keypair           = var.keypair
}


module "EFS" {
  source       = "./modules/EFS"
  efs-subnet-1 = module.VPC.private_subnets-1
  efs-subnet-2 = module.VPC.private_subnets-2
  efs-sg       = [module.security.datalayer-sg]
  account_no   = var.account_no
}

# RDS module; this module will create the RDS instance in the private subnet

module "RDS" {
  source          = "./modules/RDS"
  master-password     = var.master-password
  master-username     = var.master-username
  db-sg           = [module.security.datalayer-sg]
  private_subnets = [module.VPC.private_subnets-3, module.VPC.private_subnets-4]
}

# Security module
module "security" {
  source = "./modules/Security"
  vpc_id = module.VPC.vpc_id
}


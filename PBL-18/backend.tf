# terraform {
#   backend "s3" {
#     bucket         = "kingkellee-dev-terraform-bucket-1"
#     key            = "global/s3/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
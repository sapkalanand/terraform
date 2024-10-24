terraform {
  backend "s3" {
    bucket         = "anand-sapkal-tech-terraform-backend"
    encrypt        = true
    key            = "terraform.tfstate"
    region         = "us-east-1"
    #dynamodb_table = "ajit-inamdar-tech-terraform-backend"
  }
}
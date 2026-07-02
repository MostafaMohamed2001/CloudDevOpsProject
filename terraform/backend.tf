terraform {
  backend "s3" {
    bucket         = "mustafa-devops-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
  }
}
terraform {
  backend "s3" {
    bucket         = "fastfood-terraform-state"
    key            = "k8s/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

terraform {
  backend "s3" {
    bucket     = "sshtf-bucket"
    key        = "key/terraform.tfstate"
    region     = "us-east-1"
  }
}

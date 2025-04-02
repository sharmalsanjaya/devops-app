terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0" # Ensure you're using a supported version
    }
  }
}

provider "aws" {
  region     = "us-east-1"
}

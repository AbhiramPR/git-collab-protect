terraform {
  backend "s3" {
    bucket = "terraform-project-backend.getabhiram.tech"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}


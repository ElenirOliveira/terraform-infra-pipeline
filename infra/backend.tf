terraform {
  backend "s3" {
    bucket = "lucasvacilao"
    key = "terraform/terraform.tfstate"
    region = "us-east-1"    
  }
}
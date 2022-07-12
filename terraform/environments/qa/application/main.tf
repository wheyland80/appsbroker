provider "google" {
  credentials = "./gcp-service-account.json"
  project     = var.project_id
  region      = var.region
}

data "terraform_remote_state" "resource" {
  backend = "gcs"
  config = {
    bucket  = "appsbroker-terraform"
    prefix  = "${var.env}-resource"
    credentials = "./gcp-service-account.json"
  }
}

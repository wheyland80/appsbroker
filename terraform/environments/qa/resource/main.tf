provider "google" {
  credentials = "./gcp-service-account.json"
  project     = var.project_id
  region      = var.region
}

data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket  = "appsbroker-terraform"
    prefix  = "${var.env}-network"
    credentials = "./gcp-service-account.json"
  }
}

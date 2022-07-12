provider "google" {
  credentials = "./gcp-service-account.json"
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  credentials = "./gcp-service-account.json"
  project     = var.project_id
  region      = var.region
}
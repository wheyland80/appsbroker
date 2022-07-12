terraform {
  backend "gcs" {
    credentials = "./gcp-service-account.json"
  }
  required_version = ">= 1.2.4"
}

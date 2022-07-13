/*
  Enable the relevant APIs the layer uses
*/

# Enable the Compute API
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  disable_on_destroy = "false"
}

# Enable the Secret Manager service API
resource "google_project_service" "secret_manager" {
  service = "secretmanager.googleapis.com"
  disable_on_destroy = "false"
}

# Enable the Cloud Resource Manager API
resource "google_project_service" "cloud_resource_manager" {
  service = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = "false"
}

# Enable the SQL Admin API
resource "google_project_service" "sql_admin" {
  service = "sqladmin.googleapis.com"
  disable_on_destroy = "false"
}

# Enable the GCP Container API
resource "google_project_service" "containerapi" {
  service = "container.googleapis.com"
  disable_on_destroy = "false"
}

# Enable the Service Networking API
resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
  disable_on_destroy = "false"
}

# Enable the Cloud Build API
resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = "false"
}

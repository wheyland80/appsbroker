/*
  Enable the relevant APIs the layer uses
*/

# Enable the Compute API
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

# Enable the Secret Manager service API
resource "google_project_service" "secret_manager" {
  service = "secretmanager.googleapis.com"
}

# Enable the Cloud Resource Manager API
resource "google_project_service" "cloud_resource_manager" {
  service = "cloudresourcemanager.googleapis.com"
}

# Enable the SQL Admin API
resource "google_project_service" "sql_admin" {
  service = "sqladmin.googleapis.com"
}

# Enable the GCP Container API
resource "google_project_service" "containerapi" {
  service = "container.googleapis.com"
}

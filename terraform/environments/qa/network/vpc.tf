/*
  Create a simple VPC and subnet
*/
# Create the appsbroker-network vpc network
resource "google_compute_network" "appsbroker_network" {
  name = "appsbroker-network"
  auto_create_subnetworks = false
  depends_on = [resource.google_project_service.compute]
}

# Create the appsbroker-subnet subnet
resource "google_compute_subnetwork" "appsbroker_subnet" {
  name          = "appsbroker-subnet"
  ip_cidr_range = "10.5.0.0/16"
  network       = google_compute_network.appsbroker_network.id

  depends_on = [resource.google_project_service.compute]
}


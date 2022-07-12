output "network" {
  value       = google_compute_network.appsbroker_network.name
  description = "The appsbroker network"
}

output "network_id" {
  value       = google_compute_network.appsbroker_network.id
  description = "The appsbroker network"
}

output "subnet" {
  value       = google_compute_subnetwork.appsbroker_subnet.name
  description = "The appsbroker subnet"
}

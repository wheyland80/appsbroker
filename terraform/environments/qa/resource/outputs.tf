output "cloudsql_host" {
  value       = resource.google_sql_database_instance.instance.private_ip_address
  description = "The cloudsql private ip endpoint"
}

output "gke_endpoint" {
  value       = resource.google_container_cluster.primary.endpoint
  description = "GKE endpoint"
}
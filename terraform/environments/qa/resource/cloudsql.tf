/*
  Provision Cloud SQL Cluster
  ===========================
*/
data "google_secret_manager_secret_version" "cloudsql_replicator" {
  project = "${var.project_id}"
  secret  = "${var.env}-cloudsql-replicator"
  version = "1"
}

data "google_secret_manager_secret_version" "cloudsql_ro" {
  project = "${var.project_id}"
  secret  = "${var.env}-cloudsql-ro"
  version = "1"
}

data "google_secret_manager_secret_version" "cloudsql_rw" {
  project = "${var.project_id}"
  secret  = "${var.env}-cloudsql-rw"
  version = "1"
}

resource "google_compute_global_address" "cloudsql_private_ip" {
  provider = google-beta

  name          = "cloudsql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.terraform_remote_state.network.outputs.network
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = data.terraform_remote_state.network.outputs.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.cloudsql_private_ip.name]
}

resource "google_sql_database_instance" "instance" {
  name             = "${var.env}-mysql"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = data.terraform_remote_state.network.outputs.network_id
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]

  deletion_protection  = "false"
}

resource "google_sql_database" "database" {
  name     = "appsbroker"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "cloudsql_ro" {
  name     = "cloudsql-ro"
  instance = google_sql_database_instance.instance.name
  password = data.google_secret_manager_secret_version.cloudsql_ro.secret_data
}

resource "google_sql_user" "cloudsql_rw" {
  name     = "cloudsql-rw"
  instance = google_sql_database_instance.instance.name
  password = data.google_secret_manager_secret_version.cloudsql_rw.secret_data
}

/*
  Provision Cloud SQL Cluster
  ===========================
*/
data "google_secret_manager_secret_version" "cloudsql_replicator" {
  secret  = "${var.env}-cloudsql-replicator"
  version = "1"
}

data "google_secret_manager_secret_version" "cloudsql_ro" {
  secret  = "${var.env}-cloudsql-ro"
  version = "1"
}

resource "google_sql_database_instance" "instance" {
  name             = "${var.env}-appsbroker"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
  }

  deletion_protection  = "false"
}

resource "google_sql_database" "database" {
  name     = "appsbroker"
  instance = google_sql_database_instance.instance.name
}

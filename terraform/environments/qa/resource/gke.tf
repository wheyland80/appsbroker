/*
  Provision GKE Cluster
  =====================
*/
variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

data "google_secret_manager_secret_version" "gke_password" {
  secret  = "${var.env}-gke-password"
  version = "1"
}

resource "google_service_account" "kubernetes" {
  account_id   = "${var.env}-gke-service-account"
  display_name = "Kubernetes Service Account"
}

resource "google_container_cluster" "primary" {
  name               = "${var.env}-gke"
  location           = "${var.region}-a"
  initial_node_count = 3
  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      env = "${var.env}"
    }
    tags = ["gke", "${var.env}-gke"]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

# Add client certificate to google secret manager
resource "google_secret_manager_secret" "gke_client_certificate" {
  secret_id = "${var.env}-gke-client-certificate"
  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret_version" "gke_client_certificate" {
  secret = google_secret_manager_secret.gke_client_certificate.id
  secret_data = resource.google_container_cluster.primary.master_auth.0.client_certificate
}

# Add client key to google secret manager
resource "google_secret_manager_secret" "gke_client_key" {
  secret_id = "${var.env}-gke-client-key"
  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret_version" "gke_client_key" {
  secret = google_secret_manager_secret.gke_client_key.id
  secret_data = resource.google_container_cluster.primary.master_auth.0.client_key
}

# Add cluster ca certificate to google secret manager
resource "google_secret_manager_secret" "gke_cluster_ca_certificate" {
  secret_id = "${var.env}-gke-cluster-ca-certificate"
  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret_version" "gke_cluster_ca_certificate" {
  secret = google_secret_manager_secret.gke_cluster_ca_certificate.id
  secret_data = resource.google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

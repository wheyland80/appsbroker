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

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.env}-gke"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = data.terraform_remote_state.network.outputs.network
  subnetwork = data.terraform_remote_state.network.outputs.subnet

  depends_on = [data.terraform_remote_state.network]
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
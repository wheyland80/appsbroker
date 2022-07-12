resource "google_service_account" "gitlab_service_account" {
  account_id   = "gitlab-service-account"
  display_name = "Gitlab Service Account"
}

resource "google_compute_instance" "gitlab" {
  name         = "${var.env}-gitlab"
  machine_type = "g1-small"
  zone = "${var.region}-a"

  tags = ["gitlab", "${var.env}-gitlab"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size = "20"
      type = "pd-standard"
    }
  }

  network_interface {
    network = data.terraform_remote_state.network.outputs.network

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ENV = "${var.env}"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.gitlab_service_account.email
    scopes = ["cloud-platform"]
  }
}

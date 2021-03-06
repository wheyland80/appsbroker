resource "google_service_account" "gitlab_service_account" {
  account_id   = "${var.env}-gitlab-service-account"
  display_name = "Gitlab Service Account"
}

resource "google_compute_instance" "gitlab" {
  name         = "${var.env}-gitlab"
  machine_type = "f1-micro"
  zone = "${var.region}-b"

  tags = ["gitlab", "${var.env}-gitlab"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size = "20"
      type = "pd-standard"
    }
  }

  network_interface {
    subnetwork = data.terraform_remote_state.network.outputs.subnet

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

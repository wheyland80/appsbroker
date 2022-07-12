resource "google_service_account" "jenkins_service_account" {
  account_id   = "jenkins-service-account"
  display_name = "Jenkins Service Account"
}

resource "google_compute_instance" "jenkins" {
  name         = "${var.env}-gitlab"
  machine_type = "g1-small"
  zone = "${var.region}-b"

  tags = ["jenkins", "${var.env}-jenkins"]

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
    email  = google_service_account.jenkins_service_account.email
    scopes = ["cloud-platform"]
  }
}

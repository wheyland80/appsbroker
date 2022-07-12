resource "google_compute_firewall" "rules" {
  name        = "deny-ingress"
  network     = google_compute_network.appsbroker_network.id
  description = "Deny ingress by default"


  direction = "INGRESS"

  deny {
    protocol  = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

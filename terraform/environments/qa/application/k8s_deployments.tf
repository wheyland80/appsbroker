terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

data "google_secret_manager_secret_version" "client_certificate" {
  secret  = "${var.env}-gke-client-certificate"
  version = "1"
}

data "google_secret_manager_secret_version" "client_key" {
  secret  = "${var.env}-gke-client-key"
  version = "1"
}

data "google_secret_manager_secret_version" "cluster_ca_certificate" {
  secret  = "${var.env}-gke-cluster-ca-certificate"
  version = "1"
}

provider "kubernetes" {
  host = data.terraform_remote_state.resource.outputs.gke_endpoint

  client_certificate     = base64decode(data.google_secret_manager_secret_version.client_certificate.secret_data)
  client_key             = base64decode(data.google_secret_manager_secret_version.client_key.secret_data)
  cluster_ca_certificate = base64decode(data.google_secret_manager_secret_version.cluster_ca_certificate.secret_data)
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      App = "nginx"
      Env = "${var.env}"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          App = "nginx"
        }
      }
      spec {
        container {
          image = "us.gcr.io/${var.project_id}/${var.env}-nginx:latest"
          name  = "nginx"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "php" {
  metadata {
    name = "php-fpm"
    labels = {
      App = "php-fpm"
      Env = "${var.env}"
    }
  }

  spec {
    replicas = 4
    selector {
      match_labels = {
        App = "php-fpm"
      }
    }
    template {
      metadata {
        labels = {
          App = "php-fpm"
        }
      }
      spec {
        container {
          image = "us.gcr.io/${var.project_id}/${var.env}-php-fpm:latest"
          name  = "php-fpm"

          port {
            container_port = 9000
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

/* Expose nginx */
resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

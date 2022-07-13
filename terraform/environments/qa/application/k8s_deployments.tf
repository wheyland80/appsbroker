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
  host = "https://${data.terraform_remote_state.resource.outputs.gke_endpoint}:6443"

  client_certificate     = base64decode(data.google_secret_manager_secret_version.client_certificate.secret_data)
  client_key             = base64decode(data.google_secret_manager_secret_version.client_key.secret_data)
  cluster_ca_certificate = base64decode(data.google_secret_manager_secret_version.cluster_ca_certificate.secret_data)
}

resource "kubernetes_namespace" "appsbroker" {
  metadata {
    name = "appsbroker"
  }
}

resource "kubernetes_deployment" "appsbroker" {
  metadata {
    name = "appsbroker"
    namespace = "appsbroker"
    labels = {
      App = "appsbroker"
      Env = "${var.env}"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "appsbroker"
      }
    }
    template {
      metadata {
        labels = {
          App = "appsbroker"
        }
      }
      spec {
        container {
          image = "eu.gcr.io/${var.project_id}/nginx:latest"
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
        container {
          image = "eu.gcr.io/${var.project_id}/php-fpm:latest"
          name  = "php"
          port {
            container_port = 9000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "php" {
  metadata {
    name = "php"
    labels = {
      App = "php"
    }
  }
  spec {
    selector = {
      App = kubernetes_deployment.appsbroker.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port = 9000
      target_port = 9000
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    selector = {
      App = kubernetes_deployment.appsbroker.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

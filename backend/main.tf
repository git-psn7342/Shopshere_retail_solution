# Terraform configuration for backend (App Engine + Firestore + Pub/Sub)

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable necessary APIs
resource "google_project_service" "appengine" {
  service = "appengine.googleapis.com"
}

resource "google_project_service" "firestore" {
  service = "firestore.googleapis.com"
}

resource "google_project_service" "pubsub" {
  service = "pubsub.googleapis.com"
}

resource "google_app_engine_application" "app" {
  location_id = var.region
}

resource "google_firestore_database" "default" {
  name     = "(default)"
  location_id = var.region
  type     = "NATIVE"
}

# Pub/Sub topic for order events
resource "google_pubsub_topic" "order_events" {
  name = "order-events"
}

# App Engine service (code deployment is handled by Cloud Build)
resource "google_app_engine_standard_app_version" "api" {
  service = "default"
  runtime = "python39"
  entrypoint {
    shell = "gunicorn -b :$PORT main:app"
  }

  deployment {
    zip {
      source_url = var.source_archive_url
    }
  }

  env_variables = {
    FIRESTORE_COLLECTION = "orders"
    PUBSUB_TOPIC         = google_pubsub_topic.order_events.name
  }
}

# IAM for App Engine default service account to use Firestore and Pub/Sub
resource "google_project_iam_member" "appengine_firestore_access" {
  role   = "roles/datastore.user"
  member = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "appengine_pubsub_access" {
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

variable "project_id" {}
variable "region" {}
variable "source_archive_url" {}


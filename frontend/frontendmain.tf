terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

resource "google_app_engine_standard_app_version" "frontend" {
  service      = "frontend"
  version_id   = "v1"
  runtime      = "nodejs20"
  entrypoint   = "npm start"
  deployment {
    zip {
      source_url = var.frontend_zip_url
    }
  }
  env_variables = {
    REACT_APP_API_URL = var.api_url
  }
  noop_on_destroy = true
}

variable "frontend_zip_url" {
  description = "The GCS URL of the frontend zip file"
  type        = string
}

variable "api_url" {
  description = "The base URL of the backend API"
  type        = string
}

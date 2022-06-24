terraform {
  required_version = ">= 1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.86.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.2"
    }

    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}

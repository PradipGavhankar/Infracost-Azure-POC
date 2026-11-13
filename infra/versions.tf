terraform {
  # Require the supported Terraform CLI family; the pipeline installs 1.17.2.
  required_version = ">= 1.17.2, < 1.18.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Pin provider minor/patch for reproducible builds.
      version = "= 5.13.0"
    }
  }
}

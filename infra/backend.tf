terraform {
  backend "azurerm" {
    # Backend values are injected by terraform init -backend-config.
    # OIDC is enabled in the pipeline; do not put credentials in this file.
  }
}

# Minimal billable-resource-free starting point.
# Replace/extend with your actual Landing Zone modules after pipeline validation.
resource "azurerm_resource_group" "poc" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    managed_by  = "terraform"
    cost_center = "cloud-platform"
    project     = "infracost-poc"
  }
}

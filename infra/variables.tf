variable "location" {
  description = "Azure region for this environment."
  type        = string
  default     = "centralindia"
}

variable "resource_group_name" {
  description = "Resource group name for the POC."
  type        = string
}

variable "environment" {
  description = "Environment identifier used for tagging."
  type        = string
  default     = "poc"
}

variable "mysql_admin_password" {
  description = "MySQL administrator password supplied at runtime."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "location" {
  description = "Azure region for the project workload."
  type        = string
  default     = "westus2"
}

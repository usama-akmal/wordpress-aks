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

variable "ssh_public_key_path" {
  description = "Local path to the administrator SSH public key."
  type        = string
  default     = "~/.ssh/wordpress-aks-lab.pub"
}

variable "wordpress_db_password" {
  description = "Password for the dedicated WordPress database user."
  type        = string
  sensitive   = true
  ephemeral   = true
}

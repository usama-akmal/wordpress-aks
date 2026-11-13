variable "mysql_admin_password" {
  description = "MySQL administrator password supplied at runtime."
  type        = string
  sensitive   = true
  ephemeral   = true
}

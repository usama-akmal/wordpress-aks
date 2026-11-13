locals {
  web_setup_script = join("\n", [
    file("${path.module}/../scripts/install-web-stack.sh"),
    file("${path.module}/../scripts/install-wordpress.sh"),
    templatefile(
      "${path.module}/../scripts/configure-wordpress-secrets.sh.tftpl",
      {
        vault_name = azurerm_key_vault.project.name
      }
    ),
    templatefile(
      "${path.module}/../scripts/configure-wordpress-site.sh.tftpl",
      {
        mysql_hostname = azurerm_mysql_flexible_server.project.fqdn
      }
    )
  ])
}

resource "azurerm_virtual_machine_scale_set_extension" "web_stack" {
  name                         = "install-web-stack"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.wordpress.id

  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true

  protected_settings = jsonencode({
    commandToExecute = "printf '%s' '${base64encode(local.web_setup_script)}' | base64 --decode > /var/tmp/setup-wordpress.sh && bash /var/tmp/setup-wordpress.sh"
  })

  force_update_tag = substr(
    sha256(local.web_setup_script),
    0,
    40
  )

  depends_on = [
    azurerm_role_assignment.wordpress_secret_reader
  ]
}

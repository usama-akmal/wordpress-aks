resource "azurerm_virtual_machine_scale_set_extension" "web_stack" {
  name                         = "install-web-stack"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.wordpress.id

  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true

  protected_settings = jsonencode({
    commandToExecute = "printf '%s' '${filebase64("${path.module}/../scripts/install-web-stack.sh")}' | base64 --decode > /var/tmp/install-web-stack.sh && bash /var/tmp/install-web-stack.sh"
  })

  force_update_tag = substr(
    filesha256("${path.module}/../scripts/install-web-stack.sh"),
    0,
    40
  )
}

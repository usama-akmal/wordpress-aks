variable "wordpress_alert_email" {
  description = "Email address for WordPress availability alerts."
  type        = string
}

variable "wordpress_backend_metric_dimension" {
  description = "BackendSettingsPool metric dimension for the live WordPress AKS backend."
  type        = string
}

variable "wordpress_min_healthy_backends" {
  description = "Minimum healthy gateway backends. Temporarily set to 2 for the alert drill."
  type        = number
  default     = 1
}

resource "azurerm_monitor_action_group" "wordpress" {
  name                = "ag-wordpress-ops"
  resource_group_name = data.azurerm_resource_group.project.name
  short_name          = "wp-ops"

  email_receiver {
    name                    = "wordpress-operator"
    email_address           = var.wordpress_alert_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "wordpress_availability" {
  name                = "wordpress-aks-backend-unavailable"
  resource_group_name = data.azurerm_resource_group.project.name
  scopes              = [azurerm_application_gateway.wordpress.id]
  description         = "Check Application Gateway backend health, the Traefik Service, WordPress pod readiness, and MySQL connectivity."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  auto_mitigate       = true

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "HealthyHostCount"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.wordpress_min_healthy_backends

    dimension {
      name     = "BackendSettingsPool"
      operator = "Include"
      values   = [var.wordpress_backend_metric_dimension]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.wordpress.id
  }
}

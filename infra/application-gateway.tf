variable "gateway_client_cidr" {
  description = "Public IPv4 CIDR allowed to reach the lab gateway during setup."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.gateway_client_cidr)) && endswith(var.gateway_client_cidr, "/32")
    error_message = "Supply your public IPv4 address with a /32 prefix."
  }
}

resource "azurerm_public_ip" "gateway" {
  name                = "pip-wordpress-gateway"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.project.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "wp-${substr(sha1(data.azurerm_resource_group.project.id), 0, 12)}"

  tags = {
    project = "wordpress-aks"
  }
}

resource "azurerm_network_security_group" "gateway" {
  name                = "nsg-wordpress-gateway"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.project.name

  security_rule {
    name                       = "Allow-Lab-Client-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.gateway_client_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-GatewayManager"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-AzureLoadBalancer"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-Other-Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    project = "wordpress-aks"
  }
}

resource "azurerm_subnet_network_security_group_association" "gateway" {
  subnet_id                 = azurerm_subnet.gateway.id
  network_security_group_id = azurerm_network_security_group.gateway.id
}

resource "azurerm_application_gateway" "wordpress" {
  name                = "agw-wordpress"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.project.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gateway-ip"
    subnet_id = azurerm_subnet.gateway.id
  }

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.gateway.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  backend_address_pool {
    name = "wordpress-pool"
  }

  probe {
    name                = "wordpress-probe"
    protocol            = "Http"
    host                = "127.0.0.1"
    path                = "/wp-login.php"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
    }
  }

  backend_http_settings {
    name                  = "wordpress-http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "wordpress-probe"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name               = "wordpress-routing"
    priority           = 100
    rule_type          = "PathBasedRouting"
    http_listener_name = "http-listener"
    url_path_map_name  = "wordpress-backends"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.gateway
  ]

  tags = {
    project = "wordpress-aks"
  }

  backend_address_pool {
    name         = "wordpress-aks-pool"
    ip_addresses = ["10.224.0.5"]
  }

  probe {
    name                = "wordpress-aks-probe"
    protocol            = "Http"
    host                = azurerm_public_ip.gateway.fqdn
    path                = "/ready.php"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 3

    match {
      status_code = ["200"]
      body        = "ready"
    }
  }

  backend_http_settings {
    name                  = "wordpress-aks-http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "wordpress-aks-probe"
  }

  url_path_map {
    name                               = "wordpress-backends"
    default_backend_address_pool_name  = "wordpress-pool"
    default_backend_http_settings_name = "wordpress-http"

    path_rule {
      name                       = "aks-readiness"
      paths                      = ["/ready.php"]
      backend_address_pool_name  = "wordpress-aks-pool"
      backend_http_settings_name = "wordpress-aks-http"
    }
  }
}

output "wordpress_url" {
  description = "Lab HTTP endpoint, initially restricted to the configured client IP."
  value       = "http://${azurerm_public_ip.gateway.fqdn}"
}



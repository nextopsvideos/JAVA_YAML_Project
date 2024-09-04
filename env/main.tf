terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.80.0"
    }
  }
  backend "azurerm" {    
  } 
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  for_each = toset(var.environments)

  name     = "DevOpsRG"
  location = var.location
}

# App Service Plan
resource "azurerm_service_plan" "example" {
  for_each = toset(var.environments)

  name                = "nextopsasp-${each.key}-01"
  resource_group_name = azurerm_resource_group.example[each.key].name
  location            = azurerm_resource_group.example[each.key].location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Linux Web App
resource "azurerm_linux_web_app" "example" {
  for_each = toset(var.environments)

  name                = "nextopsapp-${each.key}-01"
  resource_group_name = azurerm_resource_group.example[each.key].name
  location            = azurerm_resource_group.example[each.key].location
  service_plan_id     = azurerm_service_plan.example[each.key].id
  site_config {
    # Additional site configurations go here
  }

  app_settings = {
    "WEBSITE_JAVA_CONTAINER"          = "TOMCAT"
    "WEBSITE_JAVA_CONTAINER_VERSION"  = "8.5"
  }
}

# MySQL Server
# resource "azurerm_mysql_server" "example" {
#   for_each = toset(var.environments)

#   name                = "nextopsmysql-${each.key}01"
#   resource_group_name = azurerm_resource_group.example[each.key].name
#   location            = azurerm_resource_group.example[each.key].location
#   sku_name            = "GP_Gen5_2"
#   version             = "8.0"
#   ssl_enforcement_enabled = true
#   administrator_login          = "petclinic"
#   administrator_login_password = "P2ssw0rd@123"
# }

resource "azurerm_mysql_flexible_server" "example" {
  for_each = toset(var.environments)
  name                   = "nextopsmysql-${each.key}01"
  resource_group_name    = azurerm_resource_group.example[each.key].name
  location               = azurerm_resource_group.example[each.key].location
  administrator_login    = "petclinic"
  administrator_password = "P2ssw0rd@123"
  sku_name               = "B_Standard_B1ms"
}

# # MySQL Firewall Rule
# resource "azurerm_mysql_firewall_rule" "example" {
#   for_each = toset(var.environments)

#   name                = "nextopsmysqlrule-${each.key}"
#   resource_group_name = azurerm_resource_group.example[each.key].name
#   server_name         = azurerm_mysql_server.example[each.key].name
#   start_ip_address    = "0.0.0.0"
#   end_ip_address      = "0.0.0.0"
# }

resource "azurerm_mysql_flexible_server_firewall_rule" "example" {
  for_each = toset(var.environments)
  name                = "nextopsmysqlrule-${each.key}"
  resource_group_name = azurerm_resource_group.example[each.key].name
  server_name         = azurerm_mysql_flexible_server.example[each.key].name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# MySQL Database
# resource "azurerm_mysql_database" "example" {
#   for_each = toset(var.environments)

#   name                = "petclinic"
#   resource_group_name = azurerm_resource_group.example[each.key].name
#   server_name         = azurerm_mysql_server.example[each.key].name
#   charset             = "utf8mb4"
#   collation           = "utf8mb4_unicode_ci"
# }

resource "azurerm_mysql_flexible_database" "example" {
  for_each = toset(var.environments)

  name                = "petclinic"
  resource_group_name = azurerm_resource_group.example[each.key].name
  server_name         = azurerm_mysql_flexible_server.example[each.key].name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

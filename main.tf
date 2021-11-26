# Configure the Azure provider
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-postgresql-rg"
  location = var.location
}

data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "example" {
  name                       = "azureramsvault"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "list",
      "purge",
      "recover"
    ]
  }
}
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Create a PostgreSQL Server
resource "azurerm_postgresql_server" "postgresql-server" {
  name                = "${var.prefix}-postgresql-server"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  administrator_login          = var.postgresql-admin-login
  administrator_login_password = random_password.password.result

  sku_name = var.postgresql-sku-name
  version  = var.postgresql-version

  storage_mb        = var.postgresql-storage
  auto_grow_enabled = true

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_key_vault_secret" "example" {
  name         = "postgres-keypass"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.example.id
}

# Create a PostgreSQL Database
resource "azurerm_postgresql_database" "postgresql-db" {
  name                = "ramtestdb"
  resource_group_name = azurerm_resource_group.this.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  charset             = "utf8"
  collation           = "English_United States.1252"
}

# Firewall Rule to access the PostgreSQL Server
resource "azurerm_postgresql_firewall_rule" "postgresql-fw-rule" {
  name                = "${var.prefix}-postgresql-ram-access"
  resource_group_name = azurerm_resource_group.this.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  start_ip_address    = "122.171.156.18"
  end_ip_address      = "122.171.156.18"
}

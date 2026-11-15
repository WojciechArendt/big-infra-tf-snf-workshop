locals {
  database_name       = "${var.name_prefix}_DB"
  admin_role_name     = "${var.name_prefix}_ADMIN"
  developer_role_name = "${var.name_prefix}_DEVELOPER"
}

resource "snowflake_database" "this" {
  name    = local.database_name
  comment = var.comment
}

resource "snowflake_account_role" "admin" {
  name    = local.admin_role_name
  comment = var.comment
}

resource "snowflake_account_role" "developer" {
  name    = local.developer_role_name
  comment = var.comment
}

# Admin moze tworzyc schematy w bazie.
resource "snowflake_grant_privileges_to_account_role" "admin_on_database" {
  account_role_name = snowflake_account_role.admin.name
  privileges        = ["USAGE", "CREATE SCHEMA"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
}

# Developer widzi baze (USAGE) i moze uzywac warehouse'u. Admin dziedziczy te uprawnienia przez role developera.
resource "snowflake_grant_privileges_to_account_role" "developer_on_database" {
  account_role_name = snowflake_account_role.developer.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "developer_on_warehouse" {
  account_role_name = snowflake_account_role.developer.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

# Admin zostaje wlascicielem roli developera - tylko wlasciciel roli moze ja nadawac uzytkownikom.
resource "snowflake_grant_ownership" "developer_role_to_admin" {
  account_role_name   = snowflake_account_role.admin.name
  outbound_privileges = "COPY"

  on {
    object_type = "ROLE"
    object_name = snowflake_account_role.developer.name
  }
}

# Rola developera jest zgrantowana do roli admina (hierarchia: admin dziedziczy uprawnienia developera).
resource "snowflake_grant_account_role" "developer_to_admin" {
  role_name        = snowflake_account_role.developer.name
  parent_role_name = snowflake_account_role.admin.name

  depends_on = [snowflake_grant_ownership.developer_role_to_admin]
}

# Wlasne role podpinamy pod SYSADMIN (dobra praktyka Snowflake). ACCOUNTADMIN dziedziczy SYSADMIN, wiec Terraform
# zachowuje kontrole nad rolami, ktorych wlascicielem stal sie admin bazy.
resource "snowflake_grant_account_role" "admin_to_sysadmin" {
  role_name        = snowflake_account_role.admin.name
  parent_role_name = "SYSADMIN"
}

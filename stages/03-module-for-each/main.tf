resource "snowflake_warehouse" "workshop" {
  name                = local.warehouse_name
  warehouse_size      = var.warehouse_size
  auto_suspend        = var.warehouse_auto_suspend_seconds
  auto_resume         = "true"
  initially_suspended = true
  comment             = local.comment
}

resource "snowflake_database" "sandbox" {
  name    = local.sandbox_database_name
  comment = local.comment
}

resource "snowflake_account_role" "sandbox_developer" {
  name    = "${local.sandbox_database_name}_DEVELOPER"
  comment = local.comment
}

resource "snowflake_grant_privileges_to_account_role" "sandbox_developer_on_database" {
  account_role_name = snowflake_account_role.sandbox_developer.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.sandbox.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "sandbox_developer_on_warehouse" {
  account_role_name = snowflake_account_role.sandbox_developer.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.workshop.name
  }
}

# --- Stage 3: ten sam wzorzec (baza + role + granty), ale jako modul wywolany 10 razy ---

module "databases" {
  source   = "./modules/database_with_roles"
  for_each = toset(var.database_names)

  database_name  = each.value
  warehouse_name = snowflake_warehouse.workshop.name
  comment        = local.comment
}

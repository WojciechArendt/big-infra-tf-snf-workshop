output "warehouse_name" {
  value = snowflake_warehouse.workshop.name
}

output "sandbox_database_name" {
  value = snowflake_database.sandbox.name
}

output "sandbox_developer_role_name" {
  value = snowflake_account_role.sandbox_developer.name
}

output "databases" {
  description = "Baza i role utworzone przez modul, kluczowane nazwa bazy."
  value = {
    for name, db in module.databases : name => {
      database       = db.database_name
      admin_role     = db.admin_role_name
      developer_role = db.developer_role_name
    }
  }
}

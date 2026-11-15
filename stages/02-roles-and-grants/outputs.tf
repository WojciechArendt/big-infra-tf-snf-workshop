output "warehouse_name" {
  value = snowflake_warehouse.workshop.name
}

output "sandbox_database_name" {
  value = snowflake_database.sandbox.name
}

output "sandbox_developer_role_name" {
  value = snowflake_account_role.sandbox_developer.name
}

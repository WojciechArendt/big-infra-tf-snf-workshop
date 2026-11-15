output "warehouse_name" {
  value = snowflake_warehouse.workshop.name
}

output "sandbox_database_name" {
  value = snowflake_database.sandbox.name
}

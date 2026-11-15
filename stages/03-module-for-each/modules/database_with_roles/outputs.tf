output "database_name" {
  value = snowflake_database.this.name
}

output "admin_role_name" {
  value = snowflake_account_role.admin.name
}

output "developer_role_name" {
  value = snowflake_account_role.developer.name
}

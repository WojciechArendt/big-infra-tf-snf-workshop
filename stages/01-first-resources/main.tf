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

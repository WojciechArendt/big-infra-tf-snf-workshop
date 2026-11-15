locals {
  warehouse_name        = "WORKSHOP_WH"
  sandbox_prefix        = "WORKSHOP_SANDBOX"
  sandbox_database_name = "${local.sandbox_prefix}_DB"
  comment               = "Managed by Terraform (big-infra-tf-snf-workshop)"
}

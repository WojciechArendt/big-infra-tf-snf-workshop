terraform {
  required_version = ">= 1.9"

  # Modul tylko deklaruje, z jakiego zrodla pochodzi provider - konfiguracje (provider "snowflake") dziedziczy od wywolujacego.
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.23"
    }
  }
}

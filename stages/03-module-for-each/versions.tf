terraform {
  required_version = ">= 1.9"

  # Stan (state) lokalnie. Wspolna sciezka dla wszystkich krokow, bo kazdy rozszerza poprzedni.
  backend "local" {
    path = "../terraform.tfstate"
  }

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.23"
    }
  }
}

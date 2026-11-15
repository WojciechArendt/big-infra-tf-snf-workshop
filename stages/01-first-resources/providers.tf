# Dane logowania (organization_name, account_name, user, private_key)
# provider czyta ze zmiennych srodowiskowych SNOWFLAKE_* - patrz README w katalogu glownym.
provider "snowflake" {
  authenticator = "SNOWFLAKE_JWT" # logowanie kluczem prywatnym
  role          = "ACCOUNTADMIN"  # uproszczenie na potrzeby warsztatow
}

# Skopiuj do scripts/env.ps1 (plik jest w .gitignore), uzupelnij i zaladuj w terminalu:
#   . .\scripts\env.ps1

# Snowflake: SELECT CURRENT_ORGANIZATION_NAME(), CURRENT_ACCOUNT_NAME();
$env:SNOWFLAKE_ORGANIZATION_NAME = "<ORGANIZATION_NAME>"
$env:SNOWFLAKE_ACCOUNT_NAME      = "<ACCOUNT_NAME>"
$env:SNOWFLAKE_USER              = "TERRAFORM_SVC"
# Uruchamiaj z katalogu glownego repozytorium (sciezka do klucza jest wzgledna).
$env:SNOWFLAKE_PRIVATE_KEY       = Get-Content -Raw "keys/snowflake_tf.p8"

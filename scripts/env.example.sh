# Skopiuj do scripts/env.sh (plik jest w .gitignore), uzupelnij i zaladuj w terminalu:
#   source ./scripts/env.sh

# Snowflake: SELECT CURRENT_ORGANIZATION_NAME(), CURRENT_ACCOUNT_NAME();
export SNOWFLAKE_ORGANIZATION_NAME="<ORGANIZATION_NAME>"
export SNOWFLAKE_ACCOUNT_NAME="<ACCOUNT_NAME>"
export SNOWFLAKE_USER="TERRAFORM_SVC"
# Uruchamiaj z katalogu glownego repozytorium (sciezka do klucza jest wzgledna).
export SNOWFLAKE_PRIVATE_KEY="$(cat keys/snowflake_tf.p8)"

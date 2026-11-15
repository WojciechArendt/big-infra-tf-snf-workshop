# Skopiuj do scripts/env.sh (plik jest w .gitignore), uzupelnij i zaladuj w terminalu:
#   source ./scripts/env.sh

# Snowflake: SELECT CURRENT_ORGANIZATION_NAME(), CURRENT_ACCOUNT_NAME();
export SNOWFLAKE_ORGANIZATION_NAME="<ORGANIZATION_NAME>"
export SNOWFLAKE_ACCOUNT_NAME="<ACCOUNT_NAME>"
export SNOWFLAKE_USER="TERRAFORM_SVC"
export SNOWFLAKE_PRIVATE_KEY="$(cat "$(dirname "${BASH_SOURCE[0]}")/../keys/snowflake_tf.p8")"

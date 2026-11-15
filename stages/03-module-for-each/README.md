# Krok 3: własny moduł i `for_each`

## Cel

Zapakować powtarzalny wzorzec (baza + role + uprawnienia) w **moduł** i wdrożyć go 10 razy z jednej listy nazw baz.

## Co robi moduł

[modules/database_with_roles](modules/database_with_roles/) dla podanego prefiksu nazw (np. `SALES`) tworzy 9 zasobów. Baza dostaje przyrostek `_DB`, role `_ADMIN` i `_DEVELOPER`:

| Zasób | Opis |
|-------|------|
| `snowflake_database.this` | baza `SALES_DB` |
| `snowflake_account_role.admin` | rola `SALES_ADMIN` |
| `snowflake_account_role.developer` | rola `SALES_DEVELOPER` |
| `snowflake_grant_privileges_to_account_role.admin_on_database` | admin: `USAGE` i `CREATE SCHEMA` na bazie (może tworzyć w niej schematy) |
| `snowflake_grant_privileges_to_account_role.developer_on_database` | developer: `USAGE` na bazie |
| `snowflake_grant_privileges_to_account_role.developer_on_warehouse` | developer: `USAGE` na warehouse'ie |
| `snowflake_grant_ownership.developer_role_to_admin` | admin jest właścicielem roli developera, więc może ją nadawać użytkownikom |
| `snowflake_grant_account_role.developer_to_admin` | rola developera zgrantowana do roli admina (admin dziedziczy jej uprawnienia) |
| `snowflake_grant_account_role.admin_to_sysadmin` | rola admina podpięta pod `SYSADMIN` (dobra praktyka Snowflake; dzięki temu `ACCOUNTADMIN`, z którego działa Terraform, dziedziczy kontrolę nad rolami) |

Warehouse **nie jest** częścią modułu - powstaje w głównej konfiguracji i jest przekazywany do modułu jako zmienna `warehouse_name`.

### Celowe uproszczenia

Moduł jest przykładem, nie gotowym wzorcem produkcyjnym. Pominięto m.in.: uprawnienia developera do schematów i obiektów w nich (np. `future grants`), osobne role tylko do odczytu, ograniczenia kosztów (resource monitor). Bez uprawnień na schematach developer widzi bazę, ale nie zobaczy schematów utworzonych przez admina - admin musi mu je nadać (albo dopisze się je do modułu).

Anatomia modułu: `variables.tf` (wejścia), `main.tf` (zasoby), `outputs.tf` (wyjścia), `versions.tf` (źródło providera). Zwróć uwagę na `validation` przy `name_prefix` - błąd w danych wejściowych wychodzi na etapie `plan`, a nie w trakcie tworzenia obiektów.

## Wywołanie modułu

W [main.tf](main.tf):

```hcl
module "databases" {
  source   = "./modules/database_with_roles"
  for_each = toset(var.name_prefixes)

  name_prefix    = each.value
  warehouse_name = snowflake_warehouse.workshop.name
  comment        = local.comment
}
```

`for_each` tworzy jedną instancję modułu na każdy element listy `name_prefixes` ([variables.tf](variables.tf)). Adresy zasobów wyglądają np. tak: `module.databases["SALES"].snowflake_database.this`.

## Ćwiczenie

```bash
cd stages/03-module-for-each

terraform init       # init pobiera także moduły
terraform validate
terraform plan       # oczekiwane: 90 to add (10 baz x 9 zasobów)
terraform apply      # potrwa chwilę - Terraform tworzy niezależne zasoby równolegle
terraform output databases
```

Sprawdź w Snowsight:

```sql
SHOW DATABASES;
SHOW ROLES LIKE '%_ADMIN';
SHOW GRANTS TO ROLE SALES_ADMIN;
SHOW GRANTS TO ROLE SALES_DEVELOPER;
SHOW GRANTS OF ROLE SALES_DEVELOPER;   -- komu nadana jest rola developera
```

## Poeksperymentuj

1. **Dodaj bazę:** dopisz `"OPERATIONS"` do listy `name_prefixes` i zrób `terraform plan` - dostaniesz plan dodania 9 zasobów, reszta bez zmian. To jest skalowanie przez dopisanie jednej linijki.
2. **Walidacja:** zmień prefiks na `"sales"` albo `"SALES-1"` i zrób `terraform plan` - zobaczysz komunikat z `validation`.
3. **Usuń bazę z listy:** `terraform plan` pokaże usunięcie wszystkich zasobów tej bazy. Terraform usuwa to, czego nie ma już w kodzie.
4. **Własny test uprawnień** (opcjonalnie): nadaj rolę `SALES_ADMIN` własnemu użytkownikowi w Snowsight (`GRANT ROLE SALES_ADMIN TO USER <twoj_user>;`), przełącz się na nią (`USE ROLE SALES_ADMIN;`), utwórz schemat (`CREATE SCHEMA SALES_DB.RAW;`) i nadaj rolę developera innemu użytkownikowi.

## Sprzątanie

Na koniec ćwiczeń usuń wszystko, co powstało w krokach 1-3:

```bash
terraform destroy
```

Zwróć uwagę, że `destroy` usuwa zasoby w odwrotnej kolejności zależności.

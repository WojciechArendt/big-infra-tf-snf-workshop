# Krok 2: rola i uprawnienia (zależności między zasobami)

## Cel

Dodać do istniejącej bazy i warehouse'u **rolę** oraz **uprawnienia**, i zrozumieć, jak Terraform ustala kolejność tworzenia zasobów.

## Co się zmienia względem kroku 1

W [main.tf](main.tf) dochodzą trzy zasoby:

| Zasób | Opis |
|-------|------|
| `snowflake_account_role.sandbox_developer` | rola `WORKSHOP_SANDBOX_DEVELOPER` |
| `snowflake_grant_privileges_to_account_role.sandbox_developer_on_database` | `USAGE` na bazie |
| `snowflake_grant_privileges_to_account_role.sandbox_developer_on_warehouse` | `USAGE` na warehouse'ie |

Kluczowa nowość: **odwołanie do atrybutu innego zasobu** (`snowflake_database.sandbox.name`). Dzięki temu Terraform sam wie, że grant musi powstać po bazie i po roli - buduje graf zależności i tworzy niezależne zasoby równolegle.

## Ćwiczenie

```bash
cd stages/02-roles-and-grants

terraform init
terraform plan       # oczekiwane: 3 to add (warehouse i baza już istnieją w stanie)
terraform apply
```

Sprawdź w Snowsight:

```sql
SHOW GRANTS TO ROLE WORKSHOP_SANDBOX_DEVELOPER;
```

Powinieneś/powinnaś zobaczyć `USAGE` na bazie `WORKSHOP_SANDBOX_DB` i na warehouse'ie `WORKSHOP_WH`.

## Poeksperymentuj

1. Dodaj do listy `privileges` w grancie na bazie drugi element, np. `"MONITOR"`, i zrób `terraform plan` - grant zmieni się w miejscu.
2. Zobacz graf zależności: `terraform graph` (wynik w formacie DOT; można go wkleić np. do [webgraphviz.com](http://www.webgraphviz.com/)).
3. Po `apply` uruchom `terraform plan` - ma być `No changes`.

Gotowe? Przejdź do [kroku 3](../03-module-for-each/README.md).

# Krok 1: pierwsze zasoby (provider, zmienne, warehouse, baza)

## Cel

Połączyć Terraform ze Snowflake i utworzyć pierwsze obiekty: **warehouse** i **bazę danych**.

## Bloki, które tu poznajesz

| Plik | Blok | Do czego służy |
|------|------|----------------|
| [versions.tf](versions.tf) | `terraform` | wymagana wersja Terraforma, wymagane providery, backend (`local` = stan w lokalnym pliku) |
| [providers.tf](providers.tf) | `provider` | konfiguracja połączenia ze Snowflake (dane logowania z zmiennych środowiskowych) |
| [variables.tf](variables.tf) | `variable` | parametry wejściowe konfiguracji (można je nadpisać z zewnątrz) |
| [locals.tf](locals.tf) | `locals` | wartości wyliczane/stałe używane wewnątrz konfiguracji |
| [main.tf](main.tf) | `resource` | obiekty, którymi zarządza Terraform |
| [outputs.tf](outputs.tf) | `output` | wartości wyświetlane po `apply` |

`variable` vs `locals`: zmienna to **wejście** (ktoś z zewnątrz może ją zmienić), `locals` to **wewnętrzny skrót** - nazwa dla wartości, której nie chcemy powtarzać.

## Ćwiczenie

```bash
cd stages/01-first-resources

terraform init       # pobiera provider, konfiguruje backend
terraform validate   # sprawdza składnię
terraform plan       # co zostanie utworzone? (oczekiwane: 2 to add)
terraform apply      # wpisz "yes", żeby zatwierdzić
```

Sprawdź efekt w Snowsight (Worksheet):

```sql
SHOW WAREHOUSES LIKE 'WORKSHOP_WH';
SHOW DATABASES LIKE 'WORKSHOP_SANDBOX_DB';
```

## Poeksperymentuj

1. **Zmiana zmiennej:** `terraform plan -var="warehouse_size=SMALL"` - zwróć uwagę na `~` (zmiana w miejscu) zamiast `+` (utworzenie). Nie wykonuj `apply`.
2. **Idempotentność:** uruchom `terraform plan` jeszcze raz - powinno być `No changes`. Kod i rzeczywistość są zgodne.
3. **Dryf konfiguracji (drift):** w Snowsight zmień komentarz bazy: `ALTER DATABASE WORKSHOP_SANDBOX_DB SET COMMENT = 'zmiana reczna';`, a potem uruchom `terraform plan`. Terraform wykrywa różnicę i zaproponuje przywrócenie stanu z kodu.
4. Zajrzyj do stanu: `terraform state list` i `terraform state show snowflake_warehouse.workshop` (stan leży w pliku `stages/terraform.tfstate`).

Gotowe? Przejdź do [kroku 2](../02-roles-and-grants/README.md). Nie wykonuj `terraform destroy` - następne kroki rozszerzają to, co już istnieje.

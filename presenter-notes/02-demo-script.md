# Skrypt demo i lista kontrolna

> Notatki wygenerowane przez AI - patrz [README](README.md).

## Przed spotkaniem (dzień wcześniej)

- [ ] Konto trial Snowflake aktywne, kredyty są (trial trwa 30 dni - nie zakładaj konta zbyt wcześnie).
- [ ] Bootstrap wykonany (`TERRAFORM_SVC` istnieje, `DESC USER TERRAFORM_SVC` pokazuje `RSA_PUBLIC_KEY_FP`).
- [ ] Stan lokalny: przed próbą usuń `stages/terraform.tfstate*`, a przed warsztatem sprawdź, że plik nie istnieje (pusty start).
- [ ] **Pełna próba od zera**: kroki 1 → 2 → 3 → `destroy`. **Zmierz czas** `apply` w kroku 3 i `destroy`.
- [ ] Na koncie demo: sprawdź, że po próbie nic nie zostało (`SHOW DATABASES`, `SHOW ROLES`), a workspace ma pusty stan.
- [ ] Zweryfikuj w trakcie próby punkty oznaczone w sekcji „Do sprawdzenia" poniżej.
- [ ] Wyślij uczestnikom README z wyprzedzeniem; poproś o wykonanie sekcji „Przygotowanie środowiska" i napisanie, jeśli coś nie działa.
- [ ] Powiększ czcionkę w terminalu i edytorze, otwórz repo w VS Code (rozszerzenie HashiCorp Terraform), przygotuj Snowsight w drugiej karcie.
- [ ] Plan B: nagranie lub zrzuty z udanego `apply`, na wypadek problemów z siecią/Snowflake.

## Do sprawdzenia podczas próby (nie były testowane na koncie Snowflake)

1. `apply` kroku 3 przechodzi w całości - w szczególności `snowflake_grant_ownership` roli developera na rolę admina oraz kolejność z `snowflake_grant_account_role` (`depends_on`).
2. `terraform destroy` kroku 3 przechodzi bez błędów (usunięcie ról, których właścicielem jest inna rola).
3. W Snowsight po `USE ROLE SALES_ADMIN` da się utworzyć schemat i nadać rolę `SALES_DEVELOPER` użytkownikowi.
4. Liczby w planach: krok 1 → 2 add, krok 2 → 3 add, krok 3 → 90 add.
5. Dryf z kroku 1 (`ALTER DATABASE ... SET COMMENT`) faktycznie pokazuje zmianę w `plan`.
6. Czy w Twoim koncie nie ma ograniczeń sieciowych (network policy) blokujących logowanie service usera.

## Krok 1 (~20 min)

**Zanim zaczniesz kodować** (3 min): pokaż [bootstrap SQL](../bootstrap/01_create_terraform_service_user.sql). Powiedz:
- Terraform potrzebuje tożsamości → ktoś musi ją stworzyć ręcznie (problem „jajka i kury").
- Service user z kluczem, bez hasła. **Nadajemy ACCOUNTADMIN tylko dla uproszczenia - tak się nie robi.**

**Pokaż pliki** w `stages/01-first-resources` w kolejności: `versions.tf` → `providers.tf` → `variables.tf` → `locals.tf` → `main.tf` → `outputs.tf`.

| Co powiedzieć | Komenda |
|---------------|---------|
| Co robi `init`, skąd pobrał provider, co to `.terraform.lock.hcl`, gdzie będzie stan (`backend "local"`) | `terraform init` |
| `validate` nie łączy się ze Snowflake | `terraform validate` |
| Jak czytać plan: `+`, liczby na dole, `(known after apply)` | `terraform plan` |
| `apply` ponawia plan i pyta o zgodę | `terraform apply` |
| Pokaż obiekty w Snowsight | `SHOW WAREHOUSES LIKE 'WORKSHOP_WH';` |
| Idempotentność | `terraform plan` → `No changes` |
| **Drift** (kluczowy moment) | w Snowsight: `ALTER DATABASE WORKSHOP_SANDBOX_DB SET COMMENT = 'zmiana reczna';` → `terraform plan` |
| Zmiana wejścia | `terraform plan -var="warehouse_size=SMALL"` |
| Stan | `terraform state list` |

Pułapki:
- Uczestnik w nowym oknie terminala bez załadowanych zmiennych środowiskowych → błąd organizacji/logowania.
- Plan chce tworzyć obiekty, które już istnieją („object already exists”) → plik stanu został usunięty lub uczestnik uruchomił inny krok z innym stanem.
- Zbyt mało czasu na `variable` vs `locals` - powiedz to jednym zdaniem (wejście vs skrót).

## Krok 2 (~10 min)

- Pokaż diff `01` ↔ `02` (w VS Code: porównanie plików) - **3 nowe zasoby**.
- Pokaż odwołanie `snowflake_database.sandbox.name` i wyjaśnij zależność niejawną. Opcjonalnie `terraform graph`.
- `terraform plan` → 3 to add; `apply`; `SHOW GRANTS TO ROLE WORKSHOP_SANDBOX_DEVELOPER;`.
- Podkreśl: zwróć uwagę, że warehouse i baza **nie są** ruszane - Terraform dodaje tylko różnicę.

## Krok 3 (~20 min)

1. Otwórz `modules/database_with_roles` (3 min): `variables.tf` (+ `validation`), `main.tf` (9 zasobów), `outputs.tf`, `versions.tf`.
   - Wyjaśnij: dlaczego admin jest właścicielem roli developera (tylko właściciel roli/`MANAGE GRANTS` może ją nadawać) - to najczęstsze „dlaczego?".
   - Warehouse jest poza modułem → przekazujemy go zmienną.
2. Pokaż wywołanie `module "databases"` z `for_each` i listę `name_prefixes` (2 min).
3. `terraform init` (moduł jest „pobierany" lokalnie) → `terraform plan` → **90 to add**.
4. `terraform apply` - **w trakcie** omawiaj: adresy `module.databases["SALES"]...`, `for_each` vs `count`, równoległość.
5. `terraform output databases`, Snowsight: `SHOW DATABASES;`, `SHOW ROLES LIKE '%_ADMIN';`, `SHOW GRANTS TO ROLE SALES_ADMIN;`, `SHOW GRANTS OF ROLE SALES_DEVELOPER;`.
6. **Moment wow** (3 min): dopisz `"OPERATIONS"` do `name_prefixes` → `plan`: 9 to add, reszta bez zmian → `apply`.
7. Walidacja: zmień na `"sales"` lub `"SALES-1"` → `plan` → komunikat z `validation`. Cofnij.
8. (Opcjonalnie) test uprawnień w Snowsight jako `SALES_ADMIN`: `CREATE SCHEMA SALES_DB.RAW;`.

## Zakończenie (~5 min)

- Podsumowanie: automatyzacja, standaryzacja, wersjonowanie (wróć do problemów z początku - co z listy rozwiązaliśmy?).
- Jak to wygląda normalnie: kod w Git → pull request → `plan` w pipeline → review → `apply`. Dziś robiliśmy to ręcznie.
- Przypomnij o ACCOUNTADMIN i o tym, że prawdziwe konto automatyzacji ma minimalne uprawnienia.
- Polecenie `terraform destroy` w kroku 3 (zajmie chwilę - pokaż odwrotną kolejność). Zachęć uczestników, by zrobili to u siebie.
- Linki: terraform-best-practices.com, dokumentacja providera, DCM Projects.

## Pytania, które mogą paść

| Pytanie | Krótka odpowiedź |
|---------|------------------|
| Co jeśli ktoś zmieni coś ręcznie? | `plan` pokaże drift; `apply` przywróci stan z kodu (albo zmieniamy kod, jeśli zmiana była słuszna). |
| Czemu stan jest lokalnie w pliku, a nie w repo? | Stan zawiera wrażliwe dane (nie commitujemy go); w zespole trzyma się go w zdalnym backendzie ze współdzieleniem i blokadą (np. HCP Terraform) - Git do tego się nie nadaje. |
| Czy Terraform zarządza tabelami i danymi? | Może (część zasobów jako preview), ale zwykle to rola dbt/DCM/migracji; Terraform - platforma. |
| Czym to się różni od skryptów SQL? | Deklaratywność, stan, plan przed zmianą, usuwanie tego, czego nie ma w kodzie, graf zależności. |
| Co z wieloma środowiskami (dev/prod)? | Ten sam moduł, różne zmienne i osobne stany/workspace'y (po warsztatach, w best practices). |
| Czy istnieje coś natywnego w Snowflake? | Tak - DCM Projects (PLAN/DEPLOY, Jinja); porównanie w `01-theory.md` §8. |
| Czemu nie `count`? | Indeksy przesuwają się przy usunięciu elementu; `for_each` używa stabilnych kluczy. |
| A jeśli `apply` padnie w połowie? | Stan zawiera to, co się udało; kolejny `plan` pokaże resztę - ponawiamy `apply`. |

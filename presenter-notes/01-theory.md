# Notatki teoretyczne (do przygotowania się)

> Notatki wygenerowane przez AI - patrz [README](README.md).

Hasła do rozwinięcia, nie gotowy skrypt. Numeracja odpowiada [agendzie](00-agenda.md).

## 1. Kim jest Inżynier Danych (krótka wzmianka, ~3 min)

Cel: wyjaśnić, **dlaczego uczymy infrastruktury osoby od danych**.

- „Inżynier danych" to szerokie określenie - spektrum ról:
  - skupiony na **kodzie transformacji** (SQL, dbt, Spark, pipeline'y),
  - skupiony na **platformie danych** (dostępy, środowiska, koszty, bezpieczeństwo, automatyzacja),
  - najczęściej **mix** - szczególnie w małych zespołach, gdzie jedna osoba robi i jedno, i drugie.
- Infrastruktura kojarzy się z DevOps, ale w danych wygląda inaczej niż w klasycznym IT: bazy, schematy, role, warehouse'y, integracje, polityki - to też infrastruktura i ktoś nią zarządza.
- Nawet jeśli nie zarządzasz platformą, **pracujesz na czymś, co jest zarządzane kodem** - warto rozumieć, jak to działa i czytać taki kod (pull requesty, prośby o nowe środowisko).

## 2. Dlaczego zarządzanie infrastrukturą staje się wyzwaniem ze skalą (~7 min)

Big Data to nie tylko wolumen danych - rośnie **liczba obiektów, środowisk, zespołów i integracji**.

- Rachunek: 10 zespołów × 3 środowiska (dev/test/prod) × ~8 obiektów (baza, role, granty, warehouse...) = **240 obiektów** do utrzymania. Dopisanie 11. zespołu = kolejne 24.
- Co się psuje przy ręcznej konfiguracji (klikanie w UI, ręczne skrypty SQL):
  - **Powolność** - onboarding zespołu/środowiska to godziny klikania.
  - **Błędy i niespójność** - środowiska „podobne, ale nie takie same" (konfiguracyjne „płatki śniegu"; gra słów ze Snowflake: *snowflake servers* to znany termin w DevOps).
  - **Brak audytu** - kto, kiedy i dlaczego nadał to uprawnienie? Historia siedzi w czyjejś głowie.
  - **Drift** - ktoś zmienił coś ręcznie „na chwilę" i nikt już nie wie, jaki jest stan docelowy.
  - **Trudne odtworzenie** (awaria, nowy region, nowe konto) i **trudny przegląd uprawnień** (compliance).
  - **Wąskie gardło ludzkie** - wiedza jednej osoby.
- Pytanie do sali: *„Ile minut zajęłoby Wam ręcznie założyć 10 baz z rolami i grantami? A po raz drugi na innym koncie?"*

## 3. Infrastructure as Code (~4 min)

- **IaC** = opis infrastruktury w plikach tekstowych (kodzie), z którego narzędzie tworzy i utrzymuje rzeczywiste obiekty.
- **Deklaratywnie, nie imperatywnie**: opisujesz *stan docelowy* („ma istnieć baza X z rolą Y"), narzędzie wylicza *jak* do niego dojść.
  - Kontrast: skrypt SQL `CREATE ... IF NOT EXISTS` mówi *co zrobić*, nie *jak ma wyglądać całość*; nie usunie niczego, czego już nie chcesz.
- **Idempotentność**: uruchomienie drugi raz nic nie zmienia, jeśli stan się zgadza.
- Korzyści (to są też wnioski na koniec spotkania):
  - **automatyzacja** - powtarzalne wdrożenia jedną komendą,
  - **standaryzacja** - jeden wzorzec (moduł) dla wszystkich zespołów,
  - **wersjonowanie** - kod w Git: historia zmian, code review, rollback, „kto i dlaczego",
  - **dokumentacja, która nie kłamie** - kod *jest* opisem stanu,
  - **przewidywalność** - `plan` pokazuje zmiany przed ich wykonaniem.

## 4. Terraform: jak działa (~6 min)

- Narzędzie HashiCorp (obecnie część IBM), język konfiguracji **HCL**, działa z wieloma platformami przez **providery**.
  - Provider = wtyczka tłumacząca zasoby HCL na wywołania API/SQL danej platformy. Tu: provider `snowflakedb/snowflake` (utrzymywany przez Snowflake; od v2.0 oficjalne wsparcie dla zasobów *stable*; zasoby *preview* wymagają włączenia i mogą się zmieniać).
  - Jeden Terraform może zarządzać Snowflake, chmurą (AWS/Azure/GCP), GitHubem itd. - to mocna strona.
- **State (stan)** - plik mapujący zasoby z kodu na rzeczywiste obiekty. Bez niego Terraform nie wie, co już stworzył.
  - Lokalnie (domyślnie) vs **zdalny backend** (np. HCP Terraform, S3, Azure Blob): wspólny dla zespołu, blokada równoległych zmian (locking), historia wersji, szyfrowanie. Na warsztatach: plik lokalny - powiedz, że w zespole to by nie działało.
  - Stan może zawierać wrażliwe dane → dostęp ograniczać.
- **Cykl pracy** (pokaż jako diagram: `init → validate → plan → apply`):
  - `init` - pobiera providery/moduły, konfiguruje backend,
  - `validate` - sprawdza składnię i spójność (bez łączenia się z platformą),
  - `plan` - porównuje **kod ↔ stan ↔ rzeczywistość** i pokazuje diff (`+` dodanie, `~` zmiana, `-` usunięcie, `-/+` odtworzenie); niczego nie zmienia,
  - `apply` - wykonuje plan po potwierdzeniu,
  - `destroy` - usuwa wszystko, czym zarządza konfiguracja.
- **Graf zależności** - Terraform sam ustala kolejność z odwołań między zasobami i wykonuje niezależne równolegle.
- **Plik blokady** `.terraform.lock.hcl` - przypina wersje providerów (commitujemy go).
- Pipeline: normalnie `plan` odpalany na pull requeście, `apply` po merge (GitHub Actions / HCP Terraform VCS-driven). Tu celowo ręcznie z terminala - widać, co robi każda komenda.
- Stan lokalny w tym warsztacie to uproszczenie; HCP Terraform jest w README opcjonalnie (stan zdalny, Execution Mode: Local).

## 5. Bloki konfiguracji (wprowadzaj w kroku 1-3)

| Blok | Jedno zdanie | Gdzie w repo |
|------|--------------|--------------|
| `terraform` | ustawienia samego Terraforma: wersja, providery, backend (`cloud`) | `versions.tf` |
| `provider` | jak łączyć się z platformą (tu: Snowflake, klucz prywatny z env) | `providers.tf` |
| `resource` | obiekt, którym zarządzamy; `typ.nazwa_lokalna`, np. `snowflake_database.sandbox` | `main.tf` |
| `variable` | **wejście** konfiguracji (typ, opis, default, `validation`) | `variables.tf` |
| `locals` | **wewnętrzny skrót** na wartość/wyrażenie; nie da się go nadpisać z zewnątrz | `locals.tf` |
| `output` | wartość widoczna po `apply` / dla wywołującego moduł | `outputs.tf` |
| `module` | wywołanie zestawu zasobów jak funkcji (wejścia → zasoby → wyjścia) | `stages/03.../main.tf` |

Tylko wspomnij: `data` (odczyt istniejących obiektów), `moved`/`import`.

- `variable` vs `locals` - najczęstsza wątpliwość początkujących: zmienna = parametr funkcji, `locals` = zmienna pomocnicza w funkcji.
- Odwołania: `var.x`, `local.x`, `resource_type.name.attribute`, `module.name.output`.
- Interpolacja: `"${var.name_prefix}_ADMIN"`.

## 6. Moduły i for_each (krok 3)

- Moduł = katalog z `.tf`, który ma wejścia (`variable`), zasoby i wyjścia (`output`). Główny katalog to też moduł („root module").
- Po co: **DRY, standaryzacja** (każdy zespół dostaje dokładnie ten sam wzorzec), jedno miejsce poprawki, testowalność.
- `for_each` na module: jedna instancja na element kolekcji; `each.key`/`each.value`; adresy `module.databases["SALES"]`.
- `for_each` vs `count`: `for_each` identyfikuje instancje **kluczem**, więc usunięcie elementu ze środka listy nie przesuwa pozostałych (przy `count` indeksy się przesuwają i Terraform chce odtwarzać zasoby).
- Klucze `for_each` muszą być znane w czasie `plan`.
- `validation` w zmiennej modułu - błędy danych wejściowych łapiemy w `plan`.
- Moduł deklaruje `required_providers` (źródło providera), ale **nie konfiguruje** providera - dziedziczy konfigurację od wywołującego.

## 7. Specyfika providera Snowflake (przydatne na pytania)

- Identyfikatory **rozróżniają wielkość liter** → konwencja wielkich liter (stąd `validation` w module).
- Model uprawnień: `snowflake_grant_privileges_to_account_role` (uprawnienia na obiekcie), `snowflake_grant_account_role` (hierarchia ról / rola → użytkownik), `snowflake_grant_ownership` (przekazanie własności). Tylko **właściciel roli** (lub `MANAGE GRANTS`) może nadać rolę - dlatego w module admin dostaje ownership roli developera.
- Stable vs preview - sprawdzaj listę w dokumentacji providera; część zasobów (np. tabele) jest oznaczona jako *preview*.
- Uwierzytelnianie: key-pair dla **service usera** (`TYPE = SERVICE`, bez hasła i MFA). Hasła i tokeny nie powinny trafiać do repozytorium.
- **Dlaczego ACCOUNTADMIN to zły pomysł** (powiedz wprost): konto automatyzacji z pełną władzą = ogromny blast radius. W praktyce: oddzielne role (np. SYSADMIN do obiektów, SECURITYADMIN/USERADMIN do ról i grantów) i osobne aliasowane providery lub dedykowane role o minimalnych uprawnieniach.

## 8. Dobre praktyki i alternatywy (~8 min)

**Dobre praktyki** (źródło polecane: [terraform-best-practices.com](https://www.terraform-best-practices.com/)):

- struktura plików (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`), spójne nazewnictwo,
- przypinanie wersji Terraforma i providerów + commit `.terraform.lock.hcl`,
- zdalny stan z blokadą, **mały blast radius** (podział na osobne stany/workspace'y),
- `terraform fmt` i `validate` w CI, linter (np. TFLint),
- sekrety poza kodem, minimalne uprawnienia konta automatyzacji,
- zmiany tylko przez pipeline (`plan` w PR, `apply` po merge), **nikt nie zmienia ręcznie** (inaczej drift).

**Alternatywy dla Terraform** (krótko, bez wchodzenia w szczegóły):

- **Snowflake DCM Projects** (Database Change Management) - natywne w Snowflake, deklaratywne: pliki SQL z `DEFINE`, szablony Jinja (pętle, zmienne), przepływ **PLAN → DEPLOY**; stan i historia wdrożeń przechowywane w Snowflake. Dokumentacja pokazuje właśnie nasz przypadek: jedna pętla Jinja po liście zespołów tworzy bazy, role i warehouse'y. Wynik porównania: DCM = tylko Snowflake, bez zewnętrznego stanu i providerów, blisko SQL; Terraform = jedno narzędzie do wielu platform (Snowflake + chmura + GitHub...), dojrzały ekosystem modułów.
  - **Zweryfikuj przed spotkaniem aktualny status** (GA/preview) i listę wspieranych typów obiektów w [dokumentacji](https://docs.snowflake.com/en/user-guide/dcm-projects/dcm-projects-overview) - funkcja szybko się rozwija.
- **OpenTofu** - fork Terraforma (po zmianie licencji HashiCorp na BSL w 2023), kompatybilny składniowo.
- **Pulumi** - IaC w zwykłych językach programowania (Python, TypeScript...).
- Skrypty SQL i narzędzia migracyjne (np. schemachange) - podejście **imperatywne**, wersjonowane migracje; dobre do zmian w obiektach danych (tabele), gorzej do utrzymania stanu docelowego infrastruktury.
- Narzędzia natywne dla chmury (CloudFormation, Bicep) - tylko dla swojej chmury.

Granica odpowiedzialności (częste pytanie): **Terraform - platforma** (konta, bazy, role, warehouse'y, integracje, polityki); **modele danych i transformacje** - zwykle dbt / DCM / migracje. Terraform potrafi zarządzać tabelami, ale rzadko to dobry wybór.

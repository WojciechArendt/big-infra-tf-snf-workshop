# Agenda i kolejność zagadnień (90 min)

> Notatki wygenerowane przez AI - patrz [README](README.md).

Założenie: uczestnicy wykonali przygotowanie środowiska z README **przed** spotkaniem (konto Snowflake, Terraform, klucze, bootstrap). Wyślij im README z wyprzedzeniem (min. 2-3 dni).

## Plan

| Czas | Min | Blok | Typ | Materiał |
|------|-----|------|-----|----------|
| 0:00 | 10 | Kim jest Inżynier Danych + problem skali | teoria | [01-theory.md](01-theory.md) §1-2 |
| 0:10 | 10 | IaC i Terraform: idea, state, providery, workflow komend | teoria | §3-4 |
| 0:20 | 5 | Szybki check środowisk (kto ma `terraform plan` działający) | praktyka | README, krok 8 |
| 0:25 | 20 | **Krok 1**: bloki `terraform`/`provider`/`variable`/`locals`/`resource`/`output`, komendy `init`→`apply`; bootstrap service usera | teoria + live | §5, [02-demo-script.md](02-demo-script.md) krok 1 |
| 0:45 | 10 | **Krok 2**: rola i granty, zależności, drift | live | demo krok 2 |
| 0:55 | 20 | **Krok 3**: moduł i `for_each` na 10 bazach | teoria + live | §6, demo krok 3 |
| 1:15 | 10 | Korzyści, dobre praktyki, pipeline CI/CD, alternatywy (DCM Projects) | teoria | §7-8 |
| 1:25 | 5 | Pytania, `terraform destroy`, co dalej | - | demo, sprzątanie |

## Dlaczego taka kolejność

1. **Najpierw „po co"** (skala, ból ręcznej konfiguracji) - bez motywacji bloki HCL są nudne.
2. **Potem „jak to działa"** (deklaratywność, state, plan/apply) - zanim ktokolwiek zobaczy kod, musi wiedzieć, co `plan` porównuje.
3. **Kod wprowadzamy przyrostowo**: 2 zasoby → role i granty → moduł. Każdy blok pojawia się dokładnie wtedy, gdy jest potrzebny (`variable`/`locals` w kroku 1, zależności w kroku 2, `module`/`for_each` w kroku 3).
4. **Kulminacja** = 90 zasobów jedną komendą po dopisaniu listy nazw - to jest „moment wow", który domyka tezę o skali.
5. **Na końcu** porównanie z alternatywami i dobre praktyki - uczestnicy mają już punkt odniesienia.

## Jeśli brakuje czasu (co wyciąć, w tej kolejności)

1. Eksperymenty z README kroku 1 (zostaw tylko idempotentność i drift - po 1 min).
2. `terraform graph` w kroku 2.
3. Test uprawnień w Snowsight w kroku 3 (pokaż tylko `SHOW GRANTS`).
4. Slajd o alternatywach skróć do 2 zdań o DCM Projects.

**Nie wycinaj:** drift w kroku 1 (najlepsza ilustracja, po co jest `plan`) oraz dopisanie 11. bazy w kroku 3.

## Co robić, gdy czekamy na `apply`

`apply` kroku 3 (90 zasobów) trwa dłużej niż reszta - **zmierz czas na próbie**. Uruchom `apply` i w trakcie omawiaj: strukturę modułu, adresy zasobów (`module.databases["SALES_DB"]...`), korzyści z for_each. Nie czekaj w ciszy.

## Świadomie pominięte (na pytania z sali)

`data` source, `count`, `dynamic` block, `moved`/`import`/`removed`, aliasy providerów, `terraform state mv`, workspaces CLI, sekrety w stanie, OpenTofu. Odeślij do dokumentacji i terraform-best-practices.com.

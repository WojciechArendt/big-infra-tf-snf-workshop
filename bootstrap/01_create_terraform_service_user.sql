-- Jednorazowy bootstrap wykonywany RECZNIE w Snowsight (Worksheet) jako ACCOUNTADMIN.
-- Terraform potrzebuje tozsamosci, zeby sie polaczyc ze Snowflake - ktos musi ja stworzyc "z zewnatrz".

USE ROLE ACCOUNTADMIN;

-- Wartosci potrzebne do konfiguracji providera (organization_name, account_name)
SELECT CURRENT_ORGANIZATION_NAME() AS organization_name,
       CURRENT_ACCOUNT_NAME()      AS account_name;

-- Uzytkownik typu SERVICE (_SVC w nazwie = service, konto serwisowe): bez hasla i bez MFA, logowanie wylacznie kluczem (key-pair)
CREATE USER IF NOT EXISTS TERRAFORM_SVC
  TYPE         = SERVICE
  DEFAULT_ROLE = ACCOUNTADMIN
  COMMENT      = 'Service user dla Terraform (warsztaty)';

-- Wklej klucz PUBLICZNY w jednej linii, BEZ naglowkow -----BEGIN/END PUBLIC KEY-----
ALTER USER TERRAFORM_SVC SET RSA_PUBLIC_KEY = '<WKLEJ_KLUCZ_PUBLICZNY>';

-- UPROSZCZENIE NA POTRZEBY WARSZTATOW: ACCOUNTADMIN dla Terraform.
-- W prawdziwym srodowisku NIE nadaje sie tej roli kontu automatyzacji.
-- Zamiast tego: SYSADMIN (bazy, warehouse'y) + SECURITYADMIN / USERADMIN (role, granty, uzytkownicy)
-- albo dedykowane role z minimalnymi uprawnieniami.
GRANT ROLE ACCOUNTADMIN TO USER TERRAFORM_SVC;

-- Weryfikacja: RSA_PUBLIC_KEY_FP musi byc uzupelnione, TYPE = SERVICE
DESC USER TERRAFORM_SVC;

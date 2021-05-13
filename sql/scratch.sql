DO
$do$
DECLARE
   _sql text;
BEGIN
   SELECT INTO _sql
          string_agg(format('DROP %s %s;'
                          , 'FUNCTION'
                          , oid::regprocedure)
                   , E'\n')
   FROM   pg_proc
   WHERE  pronamespace = 'core'::regnamespace
   and proname LIKE 'deposit_product_communication_schedule%';

   IF _sql IS NOT NULL THEN
      RAISE INFO '%', _sql;  -- debug / check first
      -- EXECUTE _sql;         -- uncomment payload once you are sure
   ELSE
      RAISE INFO 'No fuctions found in schema %', quote_ident(_schema);
   END IF;
END
$do$;

SELECT *
FROM core.legal_entity;

SELECT *
FROM customer.r_loan_tree(16, FALSE, '{
  "loan_id": 120001,
  "host_organisation_id": 1
}');
SELECT *
FROM customer.r_loan_tree(16, FALSE, '{
  "loan_reference": "LIVEL4P72"
}');

SELECT *
FROM events.r_loan_tree(NULL, FALSE, '{
  "loan_id": 120001,
  "host_organisation_id": 1
}');
SELECT *
FROM events.r_loan_tree(NULL, FALSE, '{
  "loan_reference": "LIVEL4P72"
}');

SELECT *
FROM staff.r_loan_tree(6, FALSE, '{
  "loan_id": 120001,
  "host_organisation_id": 1
}');
SELECT *
FROM staff.r_loan_tree(6, FALSE, '{
  "loan_reference": "LIVEL4P72"
}');

--r_deposit_account_logs
SELECT JSONB_PRETTY(p_function_response_json) AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_logs(1, FALSE, '{
  "deposit_account_references": [
    "SMRTD4P71",
    "SMRTD4P752222"
  ]
}');

--r_deposit_account_balances
SELECT JSONB_PRETTY(p_function_response_json) AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_balances(1, FALSE, '{
  "deposit_account_ids": [
    120000,
    120001
  ],
  "deposit_account_references": [
    "SMRTD4P71",
    "SMRTD4P752222"
  ],
  "datetime_to": "2019-01-01"
}')

--r_deposit_account_limits
SELECT JSONB_PRETTY(p_function_response_json) AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_limits(1, FALSE, '{
  "deposit_account_ids": [
    120000,
    120001
  ],
  "deposit_account_references": [
    "SMRTD4P71",
    "SMRTD4P752222"
  ],
  "datetime_to": "2019-01-01"
}');

--r_deposit_account_transactions
SELECT JSONB_PRETTY(p_function_response_json) AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_transactions(1, FALSE, '{
  "deposit_account_ids": [
    120000,
    120001
  ],
  "deposit_account_references": [
    "SMRTD4P71",
    "SMRTD4P752222"
  ],
  "datetime_to": "2019-01-01"
}');

--r_deposit_account_rates
SELECT JSONB_PRETTY(p_function_response_json) AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_rates(1, FALSE, '{
  "deposit_account_ids": [
    120000,
    120001
  ],
  "deposit_account_references": [
    "SMRTD4P71",
    "SMRTD4P752222"
  ],
  "datetime_to": "2019-01-01"
}');

--r_deposit_account_tree
SELECT JSONB_PRETTY(p_function_response_json) AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_tree(1, FALSE, '{
  "deposit_account_id": 120000,
  "deposit_account_reference": "SMRTD4P71"
}');

--r_deposit_account_event_schedules
SELECT JSONB_PRETTY(p_function_response_json) AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_event_schedules(1, FALSE, '{
  "deposit_account_ids": [
    120000,
    120001
  ],
  "deposit_account_references": [
    "SMRTD4P71",
    "SMRTD4P752222"
  ],
  "datetime_to": "2019-01-01"
}');

--r_loan_tree
SELECT JSONB_PRETTY(p_function_response_json) AS p_function_response_json, p_function_error_json
FROM staff.r_loan_tree(1, FALSE, '{
  "loan_id": 120000
}');

--*************************************************************************
--*************************************************************************
--*************************************************************************
--*************************************************************************
--*************************************************************************
--*************************************************************************

-- from "/home/andrew/workspace/YobotaDatabase/utils_sql/test_scripts/DATA-377 - r_ functions.sql"
-- from "/home/andrew/workspace/YobotaDatabase/utils_sql/test_scripts/D`ATA-377 - r_ functions.sql"
-- from "/home/andrew/workspace/YobotaDatabase/utils_sql/test_scripts/DATA-377 - r_ functions.sql"
-- from "/home/andrew/workspace/YobotaDatabase/utils_sql/test_scripts/DATA-377 - r_ functions.sql"

SELECT *
FROM
    staff.r_deposit_account_balances(1, FALSE, '{
      "deposit_account_ids": [
        120000,
        120001
      ],
      "deposit_account_references": [
        "SMRTD4P71",
        "SMRTD4P72"
      ],
      "deposit_account_balance_ids": [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25
      ],
      "host_organisation_id": 2,
      "datetime_from": "2000-03-17",
      "datetime_to": "2021-03-21"
    }');

SELECT *
FROM
    customer.r_deposit_account_transactions(16, FALSE, '{
      "transaction_status_application_codes": [
        "GLENTRY"
      ],
      "deposit_account_transaction_ids": [
        10
      ],
      "deposit_account_ids": [
        120001
      ]
    }');



SELECT *
FROM core.deposit_account;

SELECT *
FROM
    staff.r_deposit_account_limits(1, FALSE, '{
      "deposit_account_ids": [
        120000,
        120001
      ],
      "deposit_account_references": [
        "SMRTD4P71"
      ]
    }');



SELECT *
FROM
    staff.r_deposit_account_rates(1, FALSE, '{
      "deposit_account_ids": [
        120000
      ]
    }');

SELECT *
FROM
    staff.r_deposit_account_rates(1, FALSE, '{
      "deposit_account_references": [
        "SMRTD4P71"
      ],
      "datetime_from": "2018-06-20",
      "datetime_to": "2021-10-20"
    }');


SELECT *
FROM customer.r_deposit_account_tree(16, FALSE, '{
  "deposit_account_id": 120001,
  "host_organisation_id": 2
}');
SELECT *
FROM customer.r_deposit_account_tree(16, FALSE, '{
  "deposit_account_reference": "SMRTD4P71"
}');

SELECT *
FROM events.r_deposit_events(NULL, NULL, '{
  "number_of_requested_deposit_accounts": 2,
  "deposit_account_ids_to_exclude": [
    120000
  ]
}');
SELECT *
FROM events.r_deposit_events(NULL, NULL, '{
  "number_of_requested_deposit_accounts": 2,
  "product_event_type_application_codes": [
    "FUNDINGPERIODENDREACHEDCHECK"
  ]
}');
SELECT *
FROM events.r_deposit_events(NULL, NULL, '{
  "number_of_requested_deposit_accounts": 2,
  "deposit_account_ids_to_exclude": [
    120000
  ],
  "product_event_type_application_codes": [
    "FUNDINGPERIODENDREACHEDCHECK"
  ]
}');

SELECT *
FROM events.r_deposit_events(NULL, NULL, '{
  "number_of_requested_deposit_accounts": 2,
  "deposit_account_ids_to_exclude": [
    120001
  ]
}');



SELECT n.nspname                                         AS "Name",
       pg_catalog.PG_GET_USERBYID(n.nspowner)            AS "Owner",
       pg_catalog.ARRAY_TO_STRING(n.nspacl, E'\n')       AS "Access privileges",
       pg_catalog.OBJ_DESCRIPTION(n.oid, 'pg_namespace') AS "Description"
FROM pg_catalog.pg_namespace n
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY 1;

CREATE SCHEMA IF NOT EXISTS internal;

SELECT n.nspname AS name, *
FROM pg_catalog.pg_namespace n
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema';

SELECT *
FROM yobota_security.old_schema_usage;

SELECT r.rolname,
       r.rolsuper,
       r.rolinherit,
       r.rolcreaterole,
       r.rolcreatedb,
       r.rolcanlogin,
       r.rolconnlimit,
       r.rolvaliduntil,
       ARRAY(SELECT b.rolname
             FROM pg_catalog.pg_auth_members m
                      JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
             WHERE m.member = r.oid) AS memberof
        ,
       r.rolreplication
        ,
       r.rolbypassrls
FROM pg_catalog.pg_roles r
WHERE r.rolname !~ '^pg_'
ORDER BY 1;

SELECT grantee                               AS user,
       CONCAT(table_schema, '.', table_name) AS table,
       CASE
           WHEN COUNT(privilege_type) = 7 THEN 'ALL'
           ELSE ARRAY_TO_STRING(ARRAY_AGG(privilege_type), ', ')
           END                               AS grants
FROM information_schema.role_table_grants
GROUP BY table_name, table_schema, grantee;

SELECT grantor, grantee, table_schema, table_name, privilege_type
FROM information_schema.table_privileges;

-- Example call:>   /bin/bash /home/andrew/.config/JetBrains/PyCharm2020.3/scratches/_andrew_test.sh --db_name andrew

-- ./test_deposit_account_cru.sh "postgresql://postgres-dev-pg10.cqge30bitdmo.eu-west-1.rds.amazonaws.com:5432/ops_chitra?user=yobotadba&password=9002890028&ssl=true&sslmode=require"

-- /bin/bash /home/andrew/.config/JetBrains/PyCharm2020.3/scratches/_andrew_test.sh "postgresql://postgres-dev-pg11.cqge30bitdmo.eu-west-1.rds.amazonaws.com:5432/ops_andrew?user=yobotadba&password=9002890028&ssl=true&sslmode=require" andrew
-- /bin/bash ../scripts/grant_db_user_permissions.sh "postgresql://postgres-dev-pg11.cqge30bitdmo.eu-west-1.rds.amazonaws.com:5432/ops_andrew?user=yobotadba&password=9002890028&ssl=true&sslmode=require" andrew

-- insert into yobota_security.old_schema_usage
-- values(1,'public','ops_andrew_staff')
-- ,(2,'public','ops_andrew_customer')
-- ,(3,'public','ops_andrew_refdata')
-- ,(4,'public','ops_andrew_reporting')
-- ,(5,'public','ops_andrew_integrations')
-- ,(6,'public','ops_andrew_events')
-- ,(7,'public','ops_andrew_batch')
-- ,(8,'public','ops_andrew_support')
-- ,(9,'public','ops_andrew_glue')
-- ,(10,'public','ops_andrew_quant')


SELECT *
FROM core.employee e
         JOIN core.counterparty_person cp ON cp.person_id = e.person_id
         JOIN core.counterparty c ON c.counterparty_id = cp.counterparty_id
         JOIN core.loan_version lv ON lv.loan_version_counterparty_id = c.counterparty_id
         JOIN core.loan l ON l.loan_id = lv.loan_id
         JOIN core.host_organisation ho ON ho.host_organisation_id = l.host_organisation_id
WHERE e.employee_legal_entity_id = ho.host_organisation_legal_entity_id

SELECT *
FROM core.service_provider_identifier_key_value_set
WHERE service_provider_identifier_key_value_set_id IN (15,17,19);

SELECT *
FROM core.service_provider_system_type;

    SELECT *,legal_entity_id-- INTO v_legal_entity_id
    FROM core.legal_entity

SELECT service_provider_identifier_key_value_set_id,
       service_provider_identifier_key_value_set_name,
       service_provider_identifier_key_value_set_is_env_specific,
       service_provider_identifier_key_value_set_is_client_managed,
       legal_entity_id,
       service_provider_identifier_key_value_set_is_template,
       original_service_provider_identifier_key_value_set_id,
       insertion_datetime,
       insertion_transaction_id
FROM core.service_provider_identifier_key_value_set
--WHERE service_provider_identifier_key_value_set_id IN (15,17,19);
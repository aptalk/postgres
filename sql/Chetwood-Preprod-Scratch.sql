-- Following a Pipeline Migrate DB from Prod To DB-TEAM PreProd
-- you run the following to ready the database (takes 2-3 hours to complete)
-- -- select * from data_governance.pre_warm();

-- SELECT *
-- FROM core.legal_entity;
--
-- SELECT *
-- FROM core.deposit_account
-- LIMIT 10;
--
-- SELECT *
-- FROM core.deposit_account
-- LIMIT 10;

--r_deposit_account_logs
EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS)
SELECT p_function_response_json AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_logs(1, FALSE, '{
  "deposit_account_references": [
    "SMRTD4V2M",
    "SMRTD4TG2"
  ]
}');

--r_deposit_account_balances
EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS)
SELECT p_function_response_json AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_balances(2, FALSE, '{
  "deposit_account_ids": [
    126004,
    124385
  ],
  "deposit_account_references": [
    "SMRTD4V2M",
    "SMRTD4TG2"
  ],
  "datetime_to": "2021-05-01"
}');

--r_deposit_account_limits
EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS)
SELECT p_function_response_json AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_limits(1, FALSE, '{
  "deposit_account_ids": [
    126004,
    124385
  ],
  "deposit_account_references": [
    "SMRTD4V2M",
    "SMRTD4TG2"
  ],
  "datetime_to": "2021-05-01"
}');

--r_deposit_account_transactions
EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS)
SELECT p_function_response_json AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_transactions(1, FALSE, '{
  "deposit_account_ids": [
    126004,
    124385
  ],
  "deposit_account_references": [
    "SMRTD4V2M",
    "SMRTD4TG2"
  ],
  "datetime_to": "2021-05-01"
}');

--r_deposit_account_rates
EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS)
SELECT p_function_response_json AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_rates(1, FALSE, '{
  "deposit_account_ids": [
    126004,
    124385
  ],
  "deposit_account_references": [
    "SMRTD4V2M",
    "SMRTD4TG2"
  ],
  "datetime_to": "2021-05-01"
}');

--r_deposit_account_tree
EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS)
SELECT p_function_response_json AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_tree(1, FALSE, '{
  "deposit_account_id": 126004,
  "deposit_account_reference": "SMRTD4V2M"
}');

--r_deposit_account_event_schedules

EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS)
SELECT p_function_response_json AS p_function_response_json, p_function_error_json
FROM staff.r_deposit_account_event_schedules(1, FALSE, '{
  "deposit_account_ids": [
    126004,
    124385
  ],
  "deposit_account_references": [
    "SMRTD4V2M",
    "SMRTD4TG2"
  ],
  "datetime_to": "2021-05-01"
}');

--r_loan_tree
EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS)
SELECT p_function_response_json AS p_function_response_json, p_function_error_json
FROM staff.r_loan_tree(1, FALSE, '{
  "loan_id": 126004
}');

-- SELECT *
-- FROM common.r_deposit_account_balances()
SELECT aggregate_uuid,
       *--event_count
--  into v_aggregate_uuid, v_version
FROM api.awaiting_resolution('FRAUD_OVERRIDE')
ORDER BY cause_event_timestamp DESC
LIMIT 20;


SELECT --uv.cause_event_id,
       uv.aggregate_uuid,
       COUNT(e.vals::jsonb -> 'aggregate_version')
--        e.vals,
--        e.vals::jsonb -> 'aggregate_version'
FROM realtime.unresolved_view uv
         CROSS JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(uv.aggregate_history::jsonb) e (vals)
-- WHERE
-- --   uv.aggregate_uuid = '12b2ec3c-34e9-4b0e-ac38-7f224d54e2b4'    --p_aggregate_uuid
-- --   AND
--     uv.resolution_event_type_id = 3 --v_event_type_id
--   AND CAST(e.vals::jsonb -> 'event_id' AS integer) = uv.cause_event_id
GROUP BY uv.aggregate_uuid
HAVING COUNT(uv.aggregate_uuid) > 1
ORDER BY COUNT(*) DESC;


SELECT uv.cause_event_id,
       *,
       e.vals,
       e.vals::jsonb -> 'aggregate_version'
FROM realtime.unresolved_view uv
         CROSS JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(uv.aggregate_history::jsonb) e (vals)
WHERE uv.aggregate_uuid = '2ce43f87-582a-4aac-af81-ef3035a7413c' --p_aggregate_uuid
  AND uv.resolution_event_type_id = 3                            --v_event_type_id
  AND CAST(e.vals::jsonb -> 'event_id' AS integer) = uv.cause_event_id
  AND CAST(e.vals::jsonb -> 'aggregate_version' AS integer) = 2; --p_old_version

SELECT uv.cause_event_id,
       *,
       e.json,
       e.json::jsonb -> 'aggregate_version'
FROM realtime.unresolved_view uv
         CROSS JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(uv.aggregate_history::jsonb) e (json)
WHERE uv.aggregate_uuid = '2ce43f87-582a-4aac-af81-ef3035a7413c' --p_aggregate_uuid
  AND uv.resolution_event_type_id = 3                            --v_event_type_id
  AND CAST(e.json::jsonb -> 'event_id' AS integer) = uv.cause_event_id
  AND CAST(e.json::jsonb -> 'aggregate_version' AS integer) = 2; --p_old_version

SELECT MAX(aggregate_version) + 1
FROM realtime.event
WHERE aggregate_uuid = '2ce43f87-582a-4aac-af81-ef3035a7413c';

SELECT cause.event_id        AS cause_event_id,
       cause.aggregate_uuid,
       cause.event_timestamp AS cause_event_timestamp,
       rcetl.cause_event_type_id,
       rcetl.resolution_event_type_id,
       (SELECT JSON_AGG(history)
        FROM (
                 SELECT event_id,
                        aggregate_version,
                        event_timestamp,
                        event_type_id,
                        event_payload,
                        event_type_application_code
                 FROM realtime.event_view ev
                 WHERE ev.aggregate_uuid = cause.aggregate_uuid
                   AND ev.aggregate_version <= cause.aggregate_version
                 ORDER BY ev.aggregate_version
             ) history)      AS aggregate_history
FROM realtime.unresolved u,
     realtime.event cause,
     realtime.resolution_cause_event_type_link rcetl
WHERE u.cause_event_id = cause.event_id
  AND cause.event_type_id = rcetl.cause_event_type_id
  AND cause.aggregate_uuid = '2ce43f87-582a-4aac-af81-ef3035a7413c';

SELECT *
FROM realtime.unresolved_view
WHERE aggregate_uuid = '2ce43f87-582a-4aac-af81-ef3035a7413c';


SELECT *
FROM realtime.unresolved_view
WHERE aggregate_uuid = '022ec5d8-390f-452e-9863-e3425bd24fde'
;

SELECT PG_COLUMN_SIZE(aggregate_history), aggregate_history
FROM realtime.unresolved_view
WHERE aggregate_uuid = '45763f73-95dc-4110-b60d-97a89122e734'
;

SELECT *
FROM realtime.event
WHERE aggregate_uuid = '022ec5d8-390f-452e-9863-e3425bd24fde'
  AND event_id = 3320;



SELECT *
FROM realtime.unresolved
ORDER BY cause_event_id DESC
LIMIT 100;

DO
$$
    DECLARE
        p_resolution_event_type_application_code realtime.event_type.event_type_application_code%type = 'FRAUD_OVERRIDE';
        p_aggregate_uuid                         realtime.event.aggregate_uuid%TYPE                   = '2ce43f87-582a-4aac-af81-ef3035a7413c'; --(Dev) --'12b2ec3c-34e9-4b0e-ac38-7f224d54e2b4'--(CI)
        p_old_version                            realtime.event.aggregate_version%TYPE                = 3;
        v_event_type_id                          realtime.event_type.event_type_id%type;
        v_cause_event_id                         integer;


    BEGIN

        SELECT event_type_id
        INTO v_event_type_id
        FROM realtime.event_type
        WHERE event_type_application_code = p_resolution_event_type_application_code;

        SELECT uv.cause_event_id
        INTO v_cause_event_id
        FROM realtime.unresolved_view uv
        WHERE uv.aggregate_uuid = p_aggregate_uuid
          AND uv.resolution_event_type_id = v_event_type_id
          AND EXISTS(
                SELECT *
                FROM JSONB_ARRAY_ELEMENTS_TEXT(uv.aggregate_history::jsonb) e (vals)
                WHERE CAST(e.vals::jsonb -> 'event_id' AS integer) = uv.cause_event_id
                  AND CAST(e.vals::jsonb -> 'aggregate_version' AS integer) = p_old_version);

        RAISE INFO 'INFO %', v_cause_event_id;
--         RAISE WARNING 'WARNING %', v_cause_event_id;

    END
$$;

SELECT *
FROM realtime.unresolved u
WHERE u.cause_event_id IN (
    SELECT uv.cause_event_id
    FROM realtime.unresolved_view uv
    WHERE uv.aggregate_uuid = '2ce43f87-582a-4aac-af81-ef3035a7413c'
      AND uv.resolution_event_type_id = 3
      AND EXISTS(
            SELECT *
            FROM JSONB_ARRAY_ELEMENTS_TEXT(uv.aggregate_history::jsonb) e (vals)
            WHERE CAST(e.vals::jsonb -> 'event_id' AS integer) = uv.cause_event_id
              AND CAST(e.vals::jsonb -> 'aggregate_version' AS integer) = 3)
);

SELECT *
FROM api.awaiting_resolution('FRAUD_OVERRIDE')
ORDER BY cause_event_timestamp ASC
LIMIT 20;



SELECT cause.event_id        AS cause_event_id,
       cause.aggregate_uuid,
       cause.event_timestamp AS cause_event_timestamp,
       rcetl.cause_event_type_id,
       rcetl.resolution_event_type_id,
       (SELECT JSON_AGG(history)
        FROM (
                 SELECT event_id,
                        aggregate_version,
                        event_timestamp,
                        event_type_id,
                        event_payload,
                        event_type_application_code
                 FROM realtime.event_view ev
                 WHERE ev.aggregate_uuid = cause.aggregate_uuid
                   AND ev.aggregate_version <= cause.aggregate_version
                 ORDER BY ev.aggregate_version
             ) history)      AS aggregate_history
FROM realtime.unresolved u,
     realtime.event cause,
     realtime.resolution_cause_event_type_link rcetl
WHERE u.cause_event_id = cause.event_id
  AND cause.aggregate_uuid = '022ec5d8-390f-452e-9863-e3425bd24fde'
  AND cause.event_type_id = rcetl.cause_event_type_id;


SELECT event_id, aggregate_version, JSONB_PRETTY(event_payload)
FROM realtime.event_view
WHERE aggregate_uuid = '022ec5d8-390f-452e-9863-e3425bd24fde'
ORDER BY event_id;



SELECT uv.cause_event_id,
       *,
       e.vals,
       e.vals::jsonb -> 'aggregate_version'
FROM realtime.unresolved_view uv
         CROSS JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(uv.aggregate_history::jsonb) e (vals)
WHERE uv.aggregate_uuid = '022ec5d8-390f-452e-9863-e3425bd24fde' --p_aggregate_uuid
  AND uv.resolution_event_type_id = 3                            --v_event_type_id
--  AND CAST(e.vals::jsonb -> 'event_id' AS integer) = uv.cause_event_id
  AND CAST(e.vals::jsonb -> 'aggregate_version' AS integer) = 23; --p_old_version


SELECT uv.cause_event_id,
       *,
       e.json,
       e.json::jsonb -> 'aggregate_version'
FROM realtime.unresolved_view uv
         CROSS JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(uv.aggregate_history::jsonb) e (json)
WHERE uv.aggregate_uuid = '45763f73-95dc-4110-b60d-97a89122e734' --p_aggregate_uuid
  AND uv.resolution_event_type_id = 3                            --v_event_type_id
  AND CAST(e.json::jsonb -> 'event_id' AS integer) = uv.cause_event_id
--  AND CAST(e.json::jsonb -> 'aggregate_version' AS integer) = 2; --p_old_version

-- SELECT grantor, grantee, table_schema, table_name, privilege_type
-- FROM information_schema.table_privileges;
--
-- SELECT *
-- FROM pg_roles;

SELECT uv.cause_event_id,
       *
FROM realtime.unresolved_view uv
WHERE uv.aggregate_uuid = 'da8d0ffd-a963-4646-8beb-c769dc9c77f2' --p_aggregate_uuid


SELECT uv.cause_event_id,
       *,
       e.body,
       e.body::jsonb -> 'aggregate_version'
FROM realtime.unresolved_view uv
         CROSS JOIN LATERAL JSONB_ARRAY_ELEMENTS(uv.aggregate_history::jsonb) e (body)
WHERE uv.aggregate_uuid = 'da8d0ffd-a963-4646-8beb-c769dc9c77f2' --p_aggregate_uuid
  AND uv.resolution_event_type_id = 3                            --v_event_type_id
--  AND CAST(e.json::jsonb -> 'event_id' AS integer) = uv.cause_event_id;


SELECT uv.cause_event_id,
       aggregate_history,
       aggregate_history::jsonb ->> 'event_id'
FROM realtime.unresolved_view uv
WHERE uv.aggregate_uuid = 'da8d0ffd-a963-4646-8beb-c769dc9c77f2' --p_aggregate_uuid
;

SELECT *
FROM JSONB_ARRAY_ELEMENTS('[{"event_id":3034,"aggregate_version":1,"event_timestamp":"2021-03-29T15:23:20.599294+00:00","event_type_id":5,"event_payload":{"payload": {"ticket_list": {"tickets_failed": [], "tickets_pending": [{"job": "gocardless_bankdetailslookups", "status": "PENDING", "service": "integrations.bankaccount.availabledebitschemes", "ticket_id": "324", "created_time": "2018-01-14T19:00:38.110939Z", "modified_time": "2018-01-14T19:00:38.111333Z"}, {"job": "consumerservice_bankaccountverification", "status": "PENDING", "service": "integrations.bankaccount.verification", "ticket_id": "309", "created_time": "2018-01-14T19:00:39.244845Z", "modified_time": "2018-01-14T19:00:39.245168Z"}], "tickets_succeeded": [{"job": "iovation_checktransactiondetails", "status": "SUCCESS", "service": "integrations.device.verification", "ticket_id": "1703", "created_time": "2018-01-14T18:56:49.855988Z", "modified_time": "2018-01-14T18:56:52.227349Z"}, {"job": "gocardless_bankdetailslookups", "status": "SUCCESS", "service": "integrations.bankaccount.availabledebitschemes", "ticket_id": "323", "created_time": "2018-01-14T18:58:48.393523Z", "modified_time": "2018-01-14T18:58:50.214620Z"}, {"job": "consumerservice_bankaccountverification", "status": "SUCCESS", "service": "integrations.bankaccount.verification", "ticket_id": "308", "created_time": "2018-01-14T18:58:51.364478Z", "modified_time": "2018-01-14T18:58:53.692509Z"}]}, "user_inputs": {"sms": true, "email": true, "phone": true, "title": "Mr", "building": "319", "postcode": "CB6 2AG", "addresses": [{"line_1": "IDVERIFIER ST", "line_2": "", "ptcabs": "28030098290", "building": "319", "postcode": "CB62AG", "post_town": "ELY", "address_item": "", "address_json": {"line_1": "IDVERIFIER ST", "line_2": "", "ptcabs": "28030098290", "building": "319", "postcode": "CB62AG", "post_town": "ELY", "address_item": "", "address_type": "Current", "move_in_date": "2010-01-01", "move_out_date": "", "days_at_address": 2934, "time_at_address": 96, "unique_address_id": "28030098290", "residential_status": "Mortgage"}, "address_type": "MAIN", "move_in_date": "2010-01-01", "move_out_date": "", "address_to_date": "", "days_at_address": 2934, "time_at_address": 96, "address_from_date": "2010-01-01", "address_type_name": "MAIN", "unique_address_id": "28030098290", "residential_status": "Mortgage", "address_is_validated": null, "address_validation_json": null, "address_validation_datetime": null}], "last_name": "Caldwell", "sort_code": "110622", "first_name": "Fred", "loan_amount": "2000.00", "phone_number": "07890123456", "date_of_birth": "1960-01-19", "email_address": "chetwood03+fredcaldwell20180113@gmail.com", "account_number": "00300732", "product_offers": true, "repayment_date": 1, "term_in_months": 20, "account_changes": true, "loan_product_id": 10, "name_on_account": "Fred Caldwell", "employment_status": "FULLTIME", "communication_opt_in": [], "confirm_account_holder": true, "change_in_circumstances": true, "consent_for_credit_search": true, "user_provided_tax_position": "before_tax", "user_provided_income_amount": "24500.00", "user_provided_income_period": "Yearly", "consent_for_hard_credit_search": true, "expenditure_monthly_expenditure": "200.00", "communication_method_preferences": [{"communication_method_name": "email", "communication_method_opt_in": false}, {"communication_method_name": "sms", "communication_method_opt_in": false}, {"communication_method_name": "phone", "communication_method_opt_in": false}]}, "system_outputs": {"tax": "before_tax", "errors": [], "reason": null, "result": "A", "details": [{"name": "ruleset.score", "value": "0"}, {"name": "ruleset.rulesmatched", "value": "0"}, {"name": "realipaddress.source", "value": "subscriber"}, {"name": "realipaddress", "value": "77.97.84.179"}, {"name": "ipaddress", "value": "77.97.84.179"}, {"name": "device.tz", "value": "0"}, {"name": "device.type", "value": "MAC"}, {"name": "device.screen", "value": "1050X1680"}, {"name": "device.os", "value": "INTEL MAC OS X 10_13_2"}, {"name": "device.new", "value": "0"}, {"name": "device.js.enabled", "value": "1"}, {"name": "device.flash.installed", "value": "0"}, {"name": "device.flash.enabled", "value": "0"}, {"name": "device.firstseen", "value": "2017-12-13T18:38:42.410Z"}, {"name": "device.cookie.enabled", "value": "1"}, {"name": "device.browser.version", "value": "63.0.3239.132"}, {"name": "device.browser.type", "value": "CHROME"}, {"name": "device.browser.lang", "value": "EN-GB"}, {"name": "device.browser.configuredlang", "value": "EN-GB,EN-US;Q=0.9,EN;Q=0.8"}, {"name": "device.bb.timestamp", "value": "2018-01-13T15:16:47Z"}, {"name": "device.bb.age", "value": "55"}, {"name": "device.alias", "value": "716392803791626718"}], "raw_ebav": [], "response": {"customers": {"id": "CU0002YNEP4T41", "city": null, "email": "chetwood03+fredcaldwell20180113@gmail.com", "region": null, "language": "en", "metadata": {"person_id": "43"}, "created_at": "2018-01-13T15:20:33.689Z", "given_name": "Fred", "family_name": "Caldwell", "postal_code": null, "company_name": null, "country_code": null, "address_line1": null, "address_line2": null, "address_line3": null, "danish_identity_number": null, "swedish_identity_number": null}}, "SWIFT_BIC": "HLFXGB21R76", "_idv_type": "KBA", "bank_name": "HALIFAX (A TRADING NAME OF BANK OF SCOTLAND PLC)", "debtor_id": "CU0002YNEP4T41", "next_view": "process_consumerservice_bankaccountverification", "person_id": 43, "timestamp": "2018-01-13T15:19:14.463000Z", "user_type": "person", "idv_errors": [], "_idv_org_id": 8, "interaction": 1180001275240, "loan_quotes": [{"loan_amount": "2000.00", "loan_product_id": 10, "loan_product_name": "STANDARD_LOAN_Extended_Price_Range", "loan_total_payable": "2335.32", "loan_monthly_payments": "116.77", "loan_personalised_rate": "19.90"}], "transaction": 10002000000590112, "gc_person_id": "CU0002YNEP4T41", "product_name": "STANDARD LOAN", "user_profile": {"name": "chetwood03+fredcaldwell20180113@gmail.com", "email": "chetwood03+fredcaldwell20180113@gmail.com", "last_ip": "77.97.84.179", "picture": "https://s.gravatar.com/avatar/6de21f95e5652ed186cddfcce4358adb?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fch.png", "user_id": "auth0|5a5a23a7715a7d0b5095efd2", "nickname": "chetwood03+fredcaldwell20180113", "created_at": "2018-01-13T15:20:07.111Z", "identities": [{"user_id": "5a5a23a7715a7d0b5095efd2", "isSocial": false, "provider": "auth0", "connection": "chetwood-uat"}], "last_login": "2018-01-13T15:20:07.399Z", "updated_at": "2018-01-13T15:20:23.612Z", "logins_count": 1, "email_verified": true}, "_idv_complete": true, "consent_given": true, "credit_scores": [{"code": "FTILF04", "score": 398}, {"code": "EIILF91", "score": 219}, {"code": "RNOLF04", "score": 492}, {"code": "ScoreA", "score": 496}], "debit_schemes": ["bacs"], "idv_questions": [{"question_id": 6, "question_text": "How much was the mortgage for?", "correct_answer": 4, "question_choices": [{"answer_id": 1, "answer_value": "£ 4000 to £ 4499"}, {"answer_id": 2, "answer_value": "£ 4500 to £ 4999"}, {"answer_id": 3, "answer_value": "£ 5000 to £ 5499"}, {"answer_id": 4, "answer_value": "£ 5500 to £ 5999 (correct)"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 5, "question_text": "Who is your mortgage provider?", "correct_answer": 4, "question_choices": [{"answer_id": 1, "answer_value": "ALLIANCE & LEICESTER"}, {"answer_id": 2, "answer_value": "CHELTENHAM & GLOUCESTER"}, {"answer_id": 3, "answer_value": "COVENTRY BUILDING SOCIETY"}, {"answer_id": 4, "answer_value": "HSBC (correct)"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 4, "question_text": "What was your credit limit at the time of your last statement?", "correct_answer": 3, "question_choices": [{"answer_id": 1, "answer_value": "£ 1 to £ 499"}, {"answer_id": 2, "answer_value": "£ 500 to £ 999"}, {"answer_id": 3, "answer_value": "£ 1000 to £ 1499 (correct)"}, {"answer_id": 4, "answer_value": "£ 1500 to £ 1999"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 3, "question_text": "Who provides your credit or store card?", "correct_answer": 1, "question_choices": [{"answer_id": 1, "answer_value": "FIRST DIRECT (correct)"}, {"answer_id": 2, "answer_value": "PROVIDENT PERSONAL CREDIT"}, {"answer_id": 3, "answer_value": "ULSTER BANK LTD"}, {"answer_id": 4, "answer_value": "WHITE EAGLE"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 2, "question_text": "What is your overdraft limit on this account?", "correct_answer": 1, "question_choices": [{"answer_id": 1, "answer_value": "£ 1000 to £ 1499 (correct)"}, {"answer_id": 2, "answer_value": "£ 1500 to £ 1999"}, {"answer_id": 3, "answer_value": "£ 2000 to £ 2499"}, {"answer_id": 4, "answer_value": "£ 2500 to £ 2999"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 1, "question_text": "Who is the account provider?", "correct_answer": 1, "question_choices": [{"answer_id": 1, "answer_value": "LLOYDS BANK (correct)"}, {"answer_id": 2, "answer_value": "NATWEST BANK"}, {"answer_id": 3, "answer_value": "SANTANDER"}, {"answer_id": 4, "answer_value": "TSB BANK"}, {"answer_id": 5, "answer_value": "None of the Above"}]}], "income_amount": 1647, "income_period": "Monthly", "last_GET_path": "/customer/payment/", "originator_id": 1, "_waiting_loops": 30, "idv_session_id": 1, "_do_CRM_back_up": false, "completed_pages": ["personal_details", "check_customer_account_exists", "loan_threshold_check", "ensure_kba", "id_verification", "leave_credit_footprint", "attempt_gocardless_bankdetailslookups", "create_gocardless_person", "process_gocardless_person", "get_loan_decision", "credit_reference", "process_gocardless_bankdetailslookups", "contact_details", "borrowing_details", "product_offer", "loan_and_payment", "attempt_consumerservice_bankaccountverification"], "current_journey": "LOAN_APPLICATION", "iovation_result": "success", "iovation_ticket": "1661", "iovation_tokens": {"fpblackbox": "0400IKTe+l3LNUcHcCiyOFFxUAhYmr2DIf3YUzPtu+hsUXy52KYKxcAcnmZ7+EnMfC4LQOzK5c2NleI/Du8/nrckUfY1wXg57q9NQFstzopF3NylstiQH6vH9wgYJRkWF7F1bZWp/5NFsh3QANolZLufCAU8wqwM/zbpaoaJowy5lsf1CYi+TBqr3q1tPaKSfNbsiBrQVQSOwtAAdx4IaBJnTBxSBUSjJcoMzxDGWPDiv6B9Gngm+SS8HMfOmZa/a5KGhFK+6VYXOIEKOVTTL2g13+xNT3+OiL17WHRMjDmpBc6ayypN7tbNCDrs8OZl2fAC9R0fleH0V5mwHHrDW3HSYxnPse2ZJCsq4e3f1u/ETzp5VpgkQXTQzZ2bCkUkx/iDl5legzIN+IAZkasLpfIj0bM4AOtJN24mVIAW7uDQjXM9GC17jlnhcwCLIxeRPT/YCQf7ODMKeW6FkR2vuwB6rQig4TzBJtiIb5uxJAoBhHENfyJw5Y9lzLhejolH6jy42HYF5oyZHJeMPQTnQx9GfTy1SJwLx4eMT6CAXmDNHmRhRxE1wmzP7WPdoTUpq/pNvBLLD2l+arMffQ/ab1/udOdVvu4eBdAZo64UpL3D4/Gewb/Xb9ytWxYM8x0moWVyvIWQkhxgVBkG8+OF4jH/3mPdoTUpq/pNvBLLD2l+arPFz7yRIzcTdRKePA1UZdKAZDwic+y5/r+SkyAbziDM7k8xAXTS4l7D1erHMnjL6rgpCuO87vA9jjy1SJwLx4eM1ZajaJuzIyqWMCVbBcdxP+fMxqv4WdGaMrHg9Btf04cRCL7CUahnxfbKRXey06cYiFW+/3S0f2kR3F/Z8qOoAuRMSZbBA8lnmcIY8YqHbWKwLY4MxzBgJOfH8d/kXMM9COBxCZxjphtLxKF6v2PPxl4QQc9zoBJvG/4+kPO6g2PZuCYrzj4mEQTXvE++wwwVWZf3SmFcW9pdtj43LoRYVFNbXrREyZJ4vkV0LESmffBLBVfzGCP9LnhjNulTUCF2yNniUkn8Vy1Ve/dxifMzPlFC0zOEZRC+wkGouP5PPyszIheq5svTLaLBlZzRVwiEGVsh1GZGb/t2SzfqO5AZa0nbtw2dg9JBr5XHrcXp6A2ig+YdKzGIJBDAstLN4US59PE4fRZTRwxFXx+VLtT2uhh0yz82pvkwfDI5Ug7UI/ibabuLBDJ3/OudjcKV+pZNchXEpKmpK8vyEFmTUA9lLTlWr1BBzlUmQL+zPanOELFiDwK4w63kwurhYKIcxurYq5zT5DTBKE4SUIpdHSUC7o6H2W0dl9AikTjKsFmodbaMeDpA2UtaqeOuc+2v/DSO3eln9a65pRAfK8iuEI1eINdL6+h1zFR1699HTKKbPfUay81KIuCl4iHGJDEltWbP87AaHFUqTJgjoTjZ/TvEA6GCr7lrtJt9ED2sPFX3msXn7nDL3PBeawfMWUM0S84LK1509d9W6OcZdUG7SyrCLE7VOnzh7v+3sUz7eJUcE2/7clLlTqiIb1x250hVPA/4OhTHR1EcVM6Oeq+o+N/kg5ZWTExRGNlKhz5pwpTTL3GtB8WLhF4/u8uUxkbElryq+tHzXN1PQoXfXwtn2NzDjlAZLI+nsdDaLOdtBK0w86sdJSDibCCWUg==", "tpblackbox": "0400nyhffR+vPCUNf94lis1ztpRNmiaNjbTAWzHy4URGGB51aqxMHM/cBxF5BcMV73BjSOFxL5gXTaa5ZSsRF05n7lMz7bvobFF8udimCsXAHJ6odXyUKxUgVtZ++LaXDquIRV8flS7U9roYdMs/Nqb5MNKJikIjr8d4m2m7iwQyd/xVah0xS2NUk3ClB11+ifZBex1TLARybUqvwFRqyepQW4stPHxOZiJVdLDs+1JC1RHeqz7TtH33U4xBH+o5jDLyFmQWppRl6Bv4pp48B2PR0LUM6Rn3JtHEfF9hXdZ4DRRiwxmZVjl9I/x3mtGhDgzIySqkx4uIqaq7rzbxH0ZCbqQct2fIUhDBCu2Vndk9hzqdIs6MTpXev6dYrZ6H7f+9Eo/Wv+VaUMZJmq/LTcPoFv6YDSy7j1q/w3qy7PTL/t9CHbxLfjGyROhDG9oLeRo1DiRlq2B+9UYrFNC6lStdniAz6pKQhNLDh6b5XujdeD/D4TWhv78VEIne56x7fyVRBOU+OHRgh0DqMH5mYxq87tK3Sga2t5uGzI+DmQDOy+jF6dqVKPs+cBq6C3xOaDDvx7yacWI+PSIvPDCW/rWfvMCD6Kehlwp+JbLLhS+5swuixPMqjFULp9I8UWAJoym9T+HoQVdeZcQkFXUyKZOVY9ZDfBL8JCeXDtPq/jlyS0uKRrn6YOiFer1/Y9e8eiB47caT1pbMLWruEhetwA6rJPoMuBVEQHp9NDio1ddbaDE0qLP6Lq1GRxYM8x0moWVyvIWQkhxgVBkG8+OF4jH/3mPdoTUpq/pNvBLLD2l+arPFz7yRIzcTdRKePA1UZdKAZDwic+y5/r+SkyAbziDM7k8xAXTS4l7D1erHMnjL6rgpCuO87vA9jjy1SJwLx4eM1ZajaJuzIyqWMCVbBcdxP+fMxqv4WdGaMrHg9Btf04cRCL7CUahnxfbKRXey06cYiFW+/3S0f2nqtNuBmE4W+vmeG2mvWtA2vFQ3SxgXyvTx/y4JwLTE4P4M9O7lUiDQIMyfBSWv/vu3q9EURtkBWMc3hs+In8zms+Z7sqbWNX1/FOevBYpuqt7CLF3L3q/oembF760gA/zXrserGVeP0nibyWZKsXl3LxLMtt0bJskSD0SmqtmqAUYBKknoROYtdCujZOCEfYY3TJG+dLNRawalR6tq92sLbXR7w4autUYHyf83JPkBAvdbw86vRscVZ/lrwsKFYh1C4MHuHozkPSBfcDhwAT1javSu9sFFV3ncE4nZ3meVnqg0ESQ1nWNX3nzCh2d1uisUNYeLTRh04ahw887FpXvfuiPR/pi0lzTmx2vNwg2Qep0izoxOld6/p1itnoft/70Sj9a/5VpQxkmar8tNw+gW/pgNLLuPWr/DerLs9Mv+34L5kL+6EqUeXj9H/vkcpwvGmEOWXVG78rO45jqdlXkbJUnF8QoiU4kgtLV44t8up+HxIetcRa1WulACUWBdo3tVJqKtzBRNTslVCaZ1FHsbcj5QLCHUoFTD+b/u+jHBUvnZYYR0gYaH9//Vl09nuq4ZbHROZEyReg=="}, "legal_entity_id": 2, "quotestore_uuid": "bc9cbcbe-9f69-437c-88ff-e302849cedd9", "_user_session_id": "9b4c677f-20a2-4c61-b30a-8bf1b7df0555", "credit_decisions": [{"code": "AS001", "reason": "AS001 Score", "identifier": "PRIMARY", "description": "Accept"}], "idv_reason_codes": [], "_hard_search_made": true, "idv_overall_score": 70, "legal_entity_name": "Chetwood", "registration_time": "2018-01-13T15:20:33.689000Z", "credit_next_action": "PROCEED", "idv_proofing_score": 76, "response_reference": "bc9cbcbe-9f69-437c-88ff-e302849cedd9", "_total_waiting_time": 4.484941, "credit_response_raw": {"apr": "0.0", "job": "equifax_interconnectrequest", "url": "https://chetwood-integrations-uat.herokuapp.com/credit/loandecision/774/", "user": "https://chetwood-integrations-uat.herokuapp.com/user/3/", "brand": "CHETWOOD_CONSUMER_LENDING", "detail": "", "errors": [], "status": "SUCCESS", "channel": "Direct_web", "created": "2018-01-13T15:19:09.576041Z", "product": "CHET_PL_STAN", "modified": "2018-01-13T15:19:14.884310Z", "addresses": [{"ptcabs": "28030098290", "duration": "P8Y", "postcode": "CB62AG", "house_name": "319", "identifier": "Current", "residential_status": "Mortgage"}], "last_name": "Caldwell", "reference": "bc9cbcbe-9f69-437c-88ff-e302849cedd9", "timestamp": "2018-01-13T15:19:14.463000Z", "auto_refer": true, "dependents": 0, "first_name": "Fred", "processing": "2018-01-13T15:19:09.699447Z", "beneficiary": "https://chetwood-integrations-uat.herokuapp.com/beneficiary/3/", "interaction": 1180001275240, "loan_amount": "2000.00", "raw_request": "https://s3.eu-west-1.amazonaws.com/development-integrations/chetwood-integrations-uat/credit/loandecision/774/request.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIHQAQXJRRCXDL7YQ%2F20180113%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20180113T151915Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=d57a6e16c3fea3070cec807afa3d3dd011ba1295312aa83c1b3c042287d353d3", "term_months": 0, "transaction": 10002000000590112, "credit_rules": [{"enabled": false, "rule_id": "RID510", "overrides": []}, {"enabled": false, "rule_id": "RID260", "overrides": []}, {"enabled": true, "rule_id": "RID840", "overrides": [{"qcb": "Affordability_Percentage", "value": "60"}]}, {"enabled": true, "rule_id": "RID840A", "overrides": [{"qcb": "UNSECUREDAFFORDABILITYPERCENTAGE", "value": "30"}]}], "input_fields": ["expenditure_amount", "term_months", "monthly_loan", "addresses", "brand", "first_name", "monthly_living_costs", "product", "monthly_rent", "credit_rules", "reference", "apr", "upfront_amount", "auto_refer", "employment_status", "other_monthly_income", "income_currency", "dependents", "sole_monthly_mortgage", "joint_monthly_mortgage", "income_period", "income_amount", "channel", "loan_amount", "expenditure_period", "last_name", "date_of_birth"], "legal_entity": "https://chetwood-integrations-uat.herokuapp.com/referencedata/legalentity/2/", "monthly_loan": "0.00", "monthly_rent": "0.00", "product_name": "STANDARD LOAN", "raw_response": "https://s3.eu-west-1.amazonaws.com/development-integrations/chetwood-integrations-uat/credit/loandecision/774/response.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIHQAQXJRRCXDL7YQ%2F20180113%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20180113T151915Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=04cc64bc9873c13015051d3109e23570a544e690631621ac892c7f96894029d2", "credit_scores": [{"code": "FTILF04", "score": 398}, {"code": "EIILF91", "score": 219}, {"code": "RNOLF04", "score": 492}, {"code": "ScoreA", "score": 496}], "date_of_birth": "1960-01-19", "income_amount": 1647, "income_period": "Monthly", "output_fields": ["configuration_version", "response_reference", "credit_decisions", "transaction", "interaction", "timestamp", "product_name", "errors", "credit_scores"], "upfront_amount": "0.00", "income_currency": "GBP", "legal_entity_id": 2, "metadata_inputs": ["legal_entity_id", "job", "beneficiary"], "credit_decisions": [{"code": "AS001", "reason": "AS001 Score", "identifier": "PRIMARY", "description": "Accept"}], "metadata_outputs": ["legal_entity", "detail", "raw_request", "raw_response", "modified", "status", "input_fields", "metadata_outputs", "output_fields", "metadata_inputs", "created", "url", "user", "processing"], "employment_status": "FULLTIME", "expenditure_amount": "200.00", "expenditure_period": "Monthly", "response_reference": "bc9cbcbe-9f69-437c-88ff-e302849cedd9", "monthly_living_costs": "0.00", "other_monthly_income": "0.00", "configuration_version": 1, "sole_monthly_mortgage": "0.00", "joint_monthly_mortgage": "0.00"}, "idv_transaction_key": 8244000002130099, "request_tracking_id": "279174565234609061", "host_organisation_id": 1, "idv_question_headers": [{"header_text": "Your Equifax credit file indicates that you may have a mortgage account opened on or around November 2016 and updated in December 2017.", "applies_to_question": [5, 6]}, {"header_text": "Your Equifax credit file indicates that you may have a credit or store card account opened on or around September 2016 and updated in December 2017.", "applies_to_question": [3, 4]}, {"header_text": "Your Equifax credit file indicates that you may have a current account opened on or around December 2016.", "applies_to_question": [1, 2]}], "configuration_version": 1, "primary_ebav_decision": "DECLINE", "salesforce_contact_id": "0039E00000PrBHxQAN", "_journey_data_injected": true, "host_organisation_name": "LiveLend", "idv_transaction_expiry": "2018-01-13T15:48:19.069569Z", "idv_verification_score": 60, "idv_assessment_decision": "PASS", "idv_transaction_complete": "2018-01-13T15:19:51.994512Z", "_loan_and_payment_counter": 1, "session_unique_identifier": "1b7dc504-9ffb-4154-ace9-71826c0af7c2", "_full_account_data_refresh": false, "credit_reference_agency_id": 8, "income_amount_gross_annual": "24500.00", "service_list_item_counters": {}, "_update_auth0_profile_in_request_session": false}}, "person_id": 43},"event_type_application_code":"CUSTOMER_APP_SUBMIT"},
 {"event_id":3035,"aggregate_version":2,"event_timestamp":"2021-03-29T15:23:20.644554+00:00","event_type_id":2,"event_payload":{"decisions": {"primary_ewc_decision": "REFER", "primary_ebav_decision": "PROCEED", "primary_sira_decision": "PROCEED", "primary_aml_fraud_decision": "PROCEED"}, "person_id": 16, "primary_decision": "REFER", "integrations_payload": {"url": "https://integrations.com/bankaccount/verification/123/", "created": "2018-11-15T17:12:37.700360Z", "addresses": [{"county": null, "line_1": "YOBOTA STREET 1", "line_2": "YOBOTA STREET 2", "building": "100", "postcode": "YO30TA", "post_town": "YOBOTA TOWN", "address_type": "Current", "time_at_address": "180"}], "last_name": "Jackson", "sort_code": "112233", "first_name": "Michael", "date_of_birth": "1998-11-04", "account_number": "19874624", "bankaccount_verification_attributes": [{"outcome_code": "225", "characteristic_code": "USC4", "outcome_description": null, "characteristic_description": null}, {"outcome_code": "9", "characteristic_code": "USC302", "outcome_description": null, "characteristic_description": "Application 1 reference number char 10 onwards."}, {"outcome_code": "66569", "characteristic_code": "USC301", "outcome_description": null, "characteristic_description": "Application 1 reference number, chars 1 through 9."}, {"outcome_code": "1", "characteristic_code": "USC2", "outcome_description": null, "characteristic_description": "Number of applications referenced."}, {"outcome_code": "3", "characteristic_code": "USC1", "outcome_description": null, "characteristic_description": "Number of rules hit."}, {"outcome_code": "0", "characteristic_code": "FBC5", "outcome_description": "PASS", "characteristic_description": "FraudScan Bank Group - Combined Sort Code/Account Number."}, {"outcome_code": "Y", "characteristic_code": "FBC2", "outcome_description": "Passed Validation.", "characteristic_description": "FraudScan Bank Group - Account Number Check."}, {"outcome_code": "Y", "characteristic_code": "FBC1", "outcome_description": "Passed Validation.", "characteristic_description": "FraudScan Bank Group - Sort Code Check."}, {"outcome_code": "H", "characteristic_code": "QSP042", "outcome_description": "SortCode/AccountNumber not available.", "characteristic_description": "Company name check rather than sortcode"}, {"outcome_code": "M", "characteristic_code": "QSP074", "outcome_description": "No data found at the supplied address.", "characteristic_description": "Account number verification(Previous Address)."}, {"outcome_code": "M", "characteristic_code": "QSP070", "outcome_description": "No data found at the supplied address.", "characteristic_description": "Sort code verification (Previous Address)."}, {"outcome_code": "H", "characteristic_code": "QSC042", "outcome_description": "SortCode/AccountNumber not available.", "characteristic_description": "Company name check rather than sortcode"}, {"outcome_code": "1", "characteristic_code": "QSC074", "outcome_description": "SortCode/AccountNumber valid.", "characteristic_description": "Account number verification(Current Address)."}, {"outcome_code": "1", "characteristic_code": "QSC070", "outcome_description": "SortCode/AccountNumber valid.", "characteristic_description": "Sort code verification (Current Address)."}]}},"event_type_application_code":"FRAUD_DECISION"},
 {"event_id":3036,"aggregate_version":3,"event_timestamp":"2021-03-29T15:23:20.671544+00:00","event_type_id":2,"event_payload":{"decisions": {"primary_ebav_decision": "PROCEED", "primary_sira_decision": "REFER", "primary_aml_fraud_decision": "PROCEED"}, "person_id": 16, "primary_decision": "REFER", "integrations_payload": {"url": "https://integrations.com/bankaccount/verification/123/", "created": "2018-11-15T17:12:37.700360Z", "addresses": [{"county": null, "line_1": "YOBOTA STREET 1", "line_2": "YOBOTA STREET 2", "building": "100", "postcode": "YO30TA", "post_town": "YOBOTA TOWN", "address_type": "Current", "time_at_address": "180"}], "last_name": "Jackson", "sort_code": "112233", "first_name": "Michael", "date_of_birth": "1998-11-04", "account_number": "19874624", "bankaccount_verification_attributes": [{"outcome_code": "225", "characteristic_code": "USC4", "outcome_description": null, "characteristic_description": null}, {"outcome_code": "9", "characteristic_code": "USC302", "outcome_description": null, "characteristic_description": "Application 1 reference number char 10 onwards."}, {"outcome_code": "66569", "characteristic_code": "USC301", "outcome_description": null, "characteristic_description": "Application 1 reference number, chars 1 through 9."}, {"outcome_code": "1", "characteristic_code": "USC2", "outcome_description": null, "characteristic_description": "Number of applications referenced."}, {"outcome_code": "3", "characteristic_code": "USC1", "outcome_description": null, "characteristic_description": "Number of rules hit."}, {"outcome_code": "0", "characteristic_code": "FBC5", "outcome_description": "PASS", "characteristic_description": "FraudScan Bank Group - Combined Sort Code/Account Number."}, {"outcome_code": "Y", "characteristic_code": "FBC2", "outcome_description": "Passed Validation.", "characteristic_description": "FraudScan Bank Group - Account Number Check."}, {"outcome_code": "Y", "characteristic_code": "FBC1", "outcome_description": "Passed Validation.", "characteristic_description": "FraudScan Bank Group - Sort Code Check."}, {"outcome_code": "H", "characteristic_code": "QSP042", "outcome_description": "SortCode/AccountNumber not available.", "characteristic_description": "Company name check rather than sortcode"}, {"outcome_code": "M", "characteristic_code": "QSP074", "outcome_description": "No data found at the supplied address.", "characteristic_description": "Account number verification(Previous Address)."}, {"outcome_code": "M", "characteristic_code": "QSP070", "outcome_description": "No data found at the supplied address.", "characteristic_description": "Sort code verification (Previous Address)."}, {"outcome_code": "H", "characteristic_code": "QSC042", "outcome_description": "SortCode/AccountNumber not available.", "characteristic_description": "Company name check rather than sortcode"}, {"outcome_code": "1", "characteristic_code": "QSC074", "outcome_description": "SortCode/AccountNumber valid.", "characteristic_description": "Account number verification(Current Address)."}, {"outcome_code": "1", "characteristic_code": "QSC070", "outcome_description": "SortCode/AccountNumber valid.", "characteristic_description": "Sort code verification (Current Address)."}]}},"event_type_application_code":"FRAUD_DECISION"}]');


SELECT *
FROM JSONB_TO_RECORDSET('[{"a": 1,"b": "foo"},{"a": "2","c": "bar"}]') AS x(a int, b text, c text);

SELECT *
FROM JSONB_TO_RECORDSET('[{"event_id":3034,"aggregate_version":1,"event_timestamp":"2021-03-29T15:23:20.599294+00:00","event_type_id":5,"event_payload":{"payload": {"ticket_list": {"tickets_failed": [], "tickets_pending": [{"job": "gocardless_bankdetailslookups", "status": "PENDING", "service": "integrations.bankaccount.availabledebitschemes", "ticket_id": "324", "created_time": "2018-01-14T19:00:38.110939Z", "modified_time": "2018-01-14T19:00:38.111333Z"}, {"job": "consumerservice_bankaccountverification", "status": "PENDING", "service": "integrations.bankaccount.verification", "ticket_id": "309", "created_time": "2018-01-14T19:00:39.244845Z", "modified_time": "2018-01-14T19:00:39.245168Z"}], "tickets_succeeded": [{"job": "iovation_checktransactiondetails", "status": "SUCCESS", "service": "integrations.device.verification", "ticket_id": "1703", "created_time": "2018-01-14T18:56:49.855988Z", "modified_time": "2018-01-14T18:56:52.227349Z"}, {"job": "gocardless_bankdetailslookups", "status": "SUCCESS", "service": "integrations.bankaccount.availabledebitschemes", "ticket_id": "323", "created_time": "2018-01-14T18:58:48.393523Z", "modified_time": "2018-01-14T18:58:50.214620Z"}, {"job": "consumerservice_bankaccountverification", "status": "SUCCESS", "service": "integrations.bankaccount.verification", "ticket_id": "308", "created_time": "2018-01-14T18:58:51.364478Z", "modified_time": "2018-01-14T18:58:53.692509Z"}]}, "user_inputs": {"sms": true, "email": true, "phone": true, "title": "Mr", "building": "319", "postcode": "CB6 2AG", "addresses": [{"line_1": "IDVERIFIER ST", "line_2": "", "ptcabs": "28030098290", "building": "319", "postcode": "CB62AG", "post_town": "ELY", "address_item": "", "address_json": {"line_1": "IDVERIFIER ST", "line_2": "", "ptcabs": "28030098290", "building": "319", "postcode": "CB62AG", "post_town": "ELY", "address_item": "", "address_type": "Current", "move_in_date": "2010-01-01", "move_out_date": "", "days_at_address": 2934, "time_at_address": 96, "unique_address_id": "28030098290", "residential_status": "Mortgage"}, "address_type": "MAIN", "move_in_date": "2010-01-01", "move_out_date": "", "address_to_date": "", "days_at_address": 2934, "time_at_address": 96, "address_from_date": "2010-01-01", "address_type_name": "MAIN", "unique_address_id": "28030098290", "residential_status": "Mortgage", "address_is_validated": null, "address_validation_json": null, "address_validation_datetime": null}], "last_name": "Caldwell", "sort_code": "110622", "first_name": "Fred", "loan_amount": "2000.00", "phone_number": "07890123456", "date_of_birth": "1960-01-19", "email_address": "chetwood03+fredcaldwell20180113@gmail.com", "account_number": "00300732", "product_offers": true, "repayment_date": 1, "term_in_months": 20, "account_changes": true, "loan_product_id": 10, "name_on_account": "Fred Caldwell", "employment_status": "FULLTIME", "communication_opt_in": [], "confirm_account_holder": true, "change_in_circumstances": true, "consent_for_credit_search": true, "user_provided_tax_position": "before_tax", "user_provided_income_amount": "24500.00", "user_provided_income_period": "Yearly", "consent_for_hard_credit_search": true, "expenditure_monthly_expenditure": "200.00", "communication_method_preferences": [{"communication_method_name": "email", "communication_method_opt_in": false}, {"communication_method_name": "sms", "communication_method_opt_in": false}, {"communication_method_name": "phone", "communication_method_opt_in": false}]}, "system_outputs": {"tax": "before_tax", "errors": [], "reason": null, "result": "A", "details": [{"name": "ruleset.score", "value": "0"}, {"name": "ruleset.rulesmatched", "value": "0"}, {"name": "realipaddress.source", "value": "subscriber"}, {"name": "realipaddress", "value": "77.97.84.179"}, {"name": "ipaddress", "value": "77.97.84.179"}, {"name": "device.tz", "value": "0"}, {"name": "device.type", "value": "MAC"}, {"name": "device.screen", "value": "1050X1680"}, {"name": "device.os", "value": "INTEL MAC OS X 10_13_2"}, {"name": "device.new", "value": "0"}, {"name": "device.js.enabled", "value": "1"}, {"name": "device.flash.installed", "value": "0"}, {"name": "device.flash.enabled", "value": "0"}, {"name": "device.firstseen", "value": "2017-12-13T18:38:42.410Z"}, {"name": "device.cookie.enabled", "value": "1"}, {"name": "device.browser.version", "value": "63.0.3239.132"}, {"name": "device.browser.type", "value": "CHROME"}, {"name": "device.browser.lang", "value": "EN-GB"}, {"name": "device.browser.configuredlang", "value": "EN-GB,EN-US;Q=0.9,EN;Q=0.8"}, {"name": "device.bb.timestamp", "value": "2018-01-13T15:16:47Z"}, {"name": "device.bb.age", "value": "55"}, {"name": "device.alias", "value": "716392803791626718"}], "raw_ebav": [], "response": {"customers": {"id": "CU0002YNEP4T41", "city": null, "email": "chetwood03+fredcaldwell20180113@gmail.com", "region": null, "language": "en", "metadata": {"person_id": "43"}, "created_at": "2018-01-13T15:20:33.689Z", "given_name": "Fred", "family_name": "Caldwell", "postal_code": null, "company_name": null, "country_code": null, "address_line1": null, "address_line2": null, "address_line3": null, "danish_identity_number": null, "swedish_identity_number": null}}, "SWIFT_BIC": "HLFXGB21R76", "_idv_type": "KBA", "bank_name": "HALIFAX (A TRADING NAME OF BANK OF SCOTLAND PLC)", "debtor_id": "CU0002YNEP4T41", "next_view": "process_consumerservice_bankaccountverification", "person_id": 43, "timestamp": "2018-01-13T15:19:14.463000Z", "user_type": "person", "idv_errors": [], "_idv_org_id": 8, "interaction": 1180001275240, "loan_quotes": [{"loan_amount": "2000.00", "loan_product_id": 10, "loan_product_name": "STANDARD_LOAN_Extended_Price_Range", "loan_total_payable": "2335.32", "loan_monthly_payments": "116.77", "loan_personalised_rate": "19.90"}], "transaction": 10002000000590112, "gc_person_id": "CU0002YNEP4T41", "product_name": "STANDARD LOAN", "user_profile": {"name": "chetwood03+fredcaldwell20180113@gmail.com", "email": "chetwood03+fredcaldwell20180113@gmail.com", "last_ip": "77.97.84.179", "picture": "https://s.gravatar.com/avatar/6de21f95e5652ed186cddfcce4358adb?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fch.png", "user_id": "auth0|5a5a23a7715a7d0b5095efd2", "nickname": "chetwood03+fredcaldwell20180113", "created_at": "2018-01-13T15:20:07.111Z", "identities": [{"user_id": "5a5a23a7715a7d0b5095efd2", "isSocial": false, "provider": "auth0", "connection": "chetwood-uat"}], "last_login": "2018-01-13T15:20:07.399Z", "updated_at": "2018-01-13T15:20:23.612Z", "logins_count": 1, "email_verified": true}, "_idv_complete": true, "consent_given": true, "credit_scores": [{"code": "FTILF04", "score": 398}, {"code": "EIILF91", "score": 219}, {"code": "RNOLF04", "score": 492}, {"code": "ScoreA", "score": 496}], "debit_schemes": ["bacs"], "idv_questions": [{"question_id": 6, "question_text": "How much was the mortgage for?", "correct_answer": 4, "question_choices": [{"answer_id": 1, "answer_value": "£ 4000 to £ 4499"}, {"answer_id": 2, "answer_value": "£ 4500 to £ 4999"}, {"answer_id": 3, "answer_value": "£ 5000 to £ 5499"}, {"answer_id": 4, "answer_value": "£ 5500 to £ 5999 (correct)"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 5, "question_text": "Who is your mortgage provider?", "correct_answer": 4, "question_choices": [{"answer_id": 1, "answer_value": "ALLIANCE & LEICESTER"}, {"answer_id": 2, "answer_value": "CHELTENHAM & GLOUCESTER"}, {"answer_id": 3, "answer_value": "COVENTRY BUILDING SOCIETY"}, {"answer_id": 4, "answer_value": "HSBC (correct)"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 4, "question_text": "What was your credit limit at the time of your last statement?", "correct_answer": 3, "question_choices": [{"answer_id": 1, "answer_value": "£ 1 to £ 499"}, {"answer_id": 2, "answer_value": "£ 500 to £ 999"}, {"answer_id": 3, "answer_value": "£ 1000 to £ 1499 (correct)"}, {"answer_id": 4, "answer_value": "£ 1500 to £ 1999"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 3, "question_text": "Who provides your credit or store card?", "correct_answer": 1, "question_choices": [{"answer_id": 1, "answer_value": "FIRST DIRECT (correct)"}, {"answer_id": 2, "answer_value": "PROVIDENT PERSONAL CREDIT"}, {"answer_id": 3, "answer_value": "ULSTER BANK LTD"}, {"answer_id": 4, "answer_value": "WHITE EAGLE"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 2, "question_text": "What is your overdraft limit on this account?", "correct_answer": 1, "question_choices": [{"answer_id": 1, "answer_value": "£ 1000 to £ 1499 (correct)"}, {"answer_id": 2, "answer_value": "£ 1500 to £ 1999"}, {"answer_id": 3, "answer_value": "£ 2000 to £ 2499"}, {"answer_id": 4, "answer_value": "£ 2500 to £ 2999"}, {"answer_id": 5, "answer_value": "None of the Above"}]}, {"question_id": 1, "question_text": "Who is the account provider?", "correct_answer": 1, "question_choices": [{"answer_id": 1, "answer_value": "LLOYDS BANK (correct)"}, {"answer_id": 2, "answer_value": "NATWEST BANK"}, {"answer_id": 3, "answer_value": "SANTANDER"}, {"answer_id": 4, "answer_value": "TSB BANK"}, {"answer_id": 5, "answer_value": "None of the Above"}]}], "income_amount": 1647, "income_period": "Monthly", "last_GET_path": "/customer/payment/", "originator_id": 1, "_waiting_loops": 30, "idv_session_id": 1, "_do_CRM_back_up": false, "completed_pages": ["personal_details", "check_customer_account_exists", "loan_threshold_check", "ensure_kba", "id_verification", "leave_credit_footprint", "attempt_gocardless_bankdetailslookups", "create_gocardless_person", "process_gocardless_person", "get_loan_decision", "credit_reference", "process_gocardless_bankdetailslookups", "contact_details", "borrowing_details", "product_offer", "loan_and_payment", "attempt_consumerservice_bankaccountverification"], "current_journey": "LOAN_APPLICATION", "iovation_result": "success", "iovation_ticket": "1661", "iovation_tokens": {"fpblackbox": "0400IKTe+l3LNUcHcCiyOFFxUAhYmr2DIf3YUzPtu+hsUXy52KYKxcAcnmZ7+EnMfC4LQOzK5c2NleI/Du8/nrckUfY1wXg57q9NQFstzopF3NylstiQH6vH9wgYJRkWF7F1bZWp/5NFsh3QANolZLufCAU8wqwM/zbpaoaJowy5lsf1CYi+TBqr3q1tPaKSfNbsiBrQVQSOwtAAdx4IaBJnTBxSBUSjJcoMzxDGWPDiv6B9Gngm+SS8HMfOmZa/a5KGhFK+6VYXOIEKOVTTL2g13+xNT3+OiL17WHRMjDmpBc6ayypN7tbNCDrs8OZl2fAC9R0fleH0V5mwHHrDW3HSYxnPse2ZJCsq4e3f1u/ETzp5VpgkQXTQzZ2bCkUkx/iDl5legzIN+IAZkasLpfIj0bM4AOtJN24mVIAW7uDQjXM9GC17jlnhcwCLIxeRPT/YCQf7ODMKeW6FkR2vuwB6rQig4TzBJtiIb5uxJAoBhHENfyJw5Y9lzLhejolH6jy42HYF5oyZHJeMPQTnQx9GfTy1SJwLx4eMT6CAXmDNHmRhRxE1wmzP7WPdoTUpq/pNvBLLD2l+arMffQ/ab1/udOdVvu4eBdAZo64UpL3D4/Gewb/Xb9ytWxYM8x0moWVyvIWQkhxgVBkG8+OF4jH/3mPdoTUpq/pNvBLLD2l+arPFz7yRIzcTdRKePA1UZdKAZDwic+y5/r+SkyAbziDM7k8xAXTS4l7D1erHMnjL6rgpCuO87vA9jjy1SJwLx4eM1ZajaJuzIyqWMCVbBcdxP+fMxqv4WdGaMrHg9Btf04cRCL7CUahnxfbKRXey06cYiFW+/3S0f2kR3F/Z8qOoAuRMSZbBA8lnmcIY8YqHbWKwLY4MxzBgJOfH8d/kXMM9COBxCZxjphtLxKF6v2PPxl4QQc9zoBJvG/4+kPO6g2PZuCYrzj4mEQTXvE++wwwVWZf3SmFcW9pdtj43LoRYVFNbXrREyZJ4vkV0LESmffBLBVfzGCP9LnhjNulTUCF2yNniUkn8Vy1Ve/dxifMzPlFC0zOEZRC+wkGouP5PPyszIheq5svTLaLBlZzRVwiEGVsh1GZGb/t2SzfqO5AZa0nbtw2dg9JBr5XHrcXp6A2ig+YdKzGIJBDAstLN4US59PE4fRZTRwxFXx+VLtT2uhh0yz82pvkwfDI5Ug7UI/ibabuLBDJ3/OudjcKV+pZNchXEpKmpK8vyEFmTUA9lLTlWr1BBzlUmQL+zPanOELFiDwK4w63kwurhYKIcxurYq5zT5DTBKE4SUIpdHSUC7o6H2W0dl9AikTjKsFmodbaMeDpA2UtaqeOuc+2v/DSO3eln9a65pRAfK8iuEI1eINdL6+h1zFR1699HTKKbPfUay81KIuCl4iHGJDEltWbP87AaHFUqTJgjoTjZ/TvEA6GCr7lrtJt9ED2sPFX3msXn7nDL3PBeawfMWUM0S84LK1509d9W6OcZdUG7SyrCLE7VOnzh7v+3sUz7eJUcE2/7clLlTqiIb1x250hVPA/4OhTHR1EcVM6Oeq+o+N/kg5ZWTExRGNlKhz5pwpTTL3GtB8WLhF4/u8uUxkbElryq+tHzXN1PQoXfXwtn2NzDjlAZLI+nsdDaLOdtBK0w86sdJSDibCCWUg==", "tpblackbox": "0400nyhffR+vPCUNf94lis1ztpRNmiaNjbTAWzHy4URGGB51aqxMHM/cBxF5BcMV73BjSOFxL5gXTaa5ZSsRF05n7lMz7bvobFF8udimCsXAHJ6odXyUKxUgVtZ++LaXDquIRV8flS7U9roYdMs/Nqb5MNKJikIjr8d4m2m7iwQyd/xVah0xS2NUk3ClB11+ifZBex1TLARybUqvwFRqyepQW4stPHxOZiJVdLDs+1JC1RHeqz7TtH33U4xBH+o5jDLyFmQWppRl6Bv4pp48B2PR0LUM6Rn3JtHEfF9hXdZ4DRRiwxmZVjl9I/x3mtGhDgzIySqkx4uIqaq7rzbxH0ZCbqQct2fIUhDBCu2Vndk9hzqdIs6MTpXev6dYrZ6H7f+9Eo/Wv+VaUMZJmq/LTcPoFv6YDSy7j1q/w3qy7PTL/t9CHbxLfjGyROhDG9oLeRo1DiRlq2B+9UYrFNC6lStdniAz6pKQhNLDh6b5XujdeD/D4TWhv78VEIne56x7fyVRBOU+OHRgh0DqMH5mYxq87tK3Sga2t5uGzI+DmQDOy+jF6dqVKPs+cBq6C3xOaDDvx7yacWI+PSIvPDCW/rWfvMCD6Kehlwp+JbLLhS+5swuixPMqjFULp9I8UWAJoym9T+HoQVdeZcQkFXUyKZOVY9ZDfBL8JCeXDtPq/jlyS0uKRrn6YOiFer1/Y9e8eiB47caT1pbMLWruEhetwA6rJPoMuBVEQHp9NDio1ddbaDE0qLP6Lq1GRxYM8x0moWVyvIWQkhxgVBkG8+OF4jH/3mPdoTUpq/pNvBLLD2l+arPFz7yRIzcTdRKePA1UZdKAZDwic+y5/r+SkyAbziDM7k8xAXTS4l7D1erHMnjL6rgpCuO87vA9jjy1SJwLx4eM1ZajaJuzIyqWMCVbBcdxP+fMxqv4WdGaMrHg9Btf04cRCL7CUahnxfbKRXey06cYiFW+/3S0f2nqtNuBmE4W+vmeG2mvWtA2vFQ3SxgXyvTx/y4JwLTE4P4M9O7lUiDQIMyfBSWv/vu3q9EURtkBWMc3hs+In8zms+Z7sqbWNX1/FOevBYpuqt7CLF3L3q/oembF760gA/zXrserGVeP0nibyWZKsXl3LxLMtt0bJskSD0SmqtmqAUYBKknoROYtdCujZOCEfYY3TJG+dLNRawalR6tq92sLbXR7w4autUYHyf83JPkBAvdbw86vRscVZ/lrwsKFYh1C4MHuHozkPSBfcDhwAT1javSu9sFFV3ncE4nZ3meVnqg0ESQ1nWNX3nzCh2d1uisUNYeLTRh04ahw887FpXvfuiPR/pi0lzTmx2vNwg2Qep0izoxOld6/p1itnoft/70Sj9a/5VpQxkmar8tNw+gW/pgNLLuPWr/DerLs9Mv+34L5kL+6EqUeXj9H/vkcpwvGmEOWXVG78rO45jqdlXkbJUnF8QoiU4kgtLV44t8up+HxIetcRa1WulACUWBdo3tVJqKtzBRNTslVCaZ1FHsbcj5QLCHUoFTD+b/u+jHBUvnZYYR0gYaH9//Vl09nuq4ZbHROZEyReg=="}, "legal_entity_id": 2, "quotestore_uuid": "bc9cbcbe-9f69-437c-88ff-e302849cedd9", "_user_session_id": "9b4c677f-20a2-4c61-b30a-8bf1b7df0555", "credit_decisions": [{"code": "AS001", "reason": "AS001 Score", "identifier": "PRIMARY", "description": "Accept"}], "idv_reason_codes": [], "_hard_search_made": true, "idv_overall_score": 70, "legal_entity_name": "Chetwood", "registration_time": "2018-01-13T15:20:33.689000Z", "credit_next_action": "PROCEED", "idv_proofing_score": 76, "response_reference": "bc9cbcbe-9f69-437c-88ff-e302849cedd9", "_total_waiting_time": 4.484941, "credit_response_raw": {"apr": "0.0", "job": "equifax_interconnectrequest", "url": "https://chetwood-integrations-uat.herokuapp.com/credit/loandecision/774/", "user": "https://chetwood-integrations-uat.herokuapp.com/user/3/", "brand": "CHETWOOD_CONSUMER_LENDING", "detail": "", "errors": [], "status": "SUCCESS", "channel": "Direct_web", "created": "2018-01-13T15:19:09.576041Z", "product": "CHET_PL_STAN", "modified": "2018-01-13T15:19:14.884310Z", "addresses": [{"ptcabs": "28030098290", "duration": "P8Y", "postcode": "CB62AG", "house_name": "319", "identifier": "Current", "residential_status": "Mortgage"}], "last_name": "Caldwell", "reference": "bc9cbcbe-9f69-437c-88ff-e302849cedd9", "timestamp": "2018-01-13T15:19:14.463000Z", "auto_refer": true, "dependents": 0, "first_name": "Fred", "processing": "2018-01-13T15:19:09.699447Z", "beneficiary": "https://chetwood-integrations-uat.herokuapp.com/beneficiary/3/", "interaction": 1180001275240, "loan_amount": "2000.00", "raw_request": "https://s3.eu-west-1.amazonaws.com/development-integrations/chetwood-integrations-uat/credit/loandecision/774/request.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIHQAQXJRRCXDL7YQ%2F20180113%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20180113T151915Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=d57a6e16c3fea3070cec807afa3d3dd011ba1295312aa83c1b3c042287d353d3", "term_months": 0, "transaction": 10002000000590112, "credit_rules": [{"enabled": false, "rule_id": "RID510", "overrides": []}, {"enabled": false, "rule_id": "RID260", "overrides": []}, {"enabled": true, "rule_id": "RID840", "overrides": [{"qcb": "Affordability_Percentage", "value": "60"}]}, {"enabled": true, "rule_id": "RID840A", "overrides": [{"qcb": "UNSECUREDAFFORDABILITYPERCENTAGE", "value": "30"}]}], "input_fields": ["expenditure_amount", "term_months", "monthly_loan", "addresses", "brand", "first_name", "monthly_living_costs", "product", "monthly_rent", "credit_rules", "reference", "apr", "upfront_amount", "auto_refer", "employment_status", "other_monthly_income", "income_currency", "dependents", "sole_monthly_mortgage", "joint_monthly_mortgage", "income_period", "income_amount", "channel", "loan_amount", "expenditure_period", "last_name", "date_of_birth"], "legal_entity": "https://chetwood-integrations-uat.herokuapp.com/referencedata/legalentity/2/", "monthly_loan": "0.00", "monthly_rent": "0.00", "product_name": "STANDARD LOAN", "raw_response": "https://s3.eu-west-1.amazonaws.com/development-integrations/chetwood-integrations-uat/credit/loandecision/774/response.xml?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIHQAQXJRRCXDL7YQ%2F20180113%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20180113T151915Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=04cc64bc9873c13015051d3109e23570a544e690631621ac892c7f96894029d2", "credit_scores": [{"code": "FTILF04", "score": 398}, {"code": "EIILF91", "score": 219}, {"code": "RNOLF04", "score": 492}, {"code": "ScoreA", "score": 496}], "date_of_birth": "1960-01-19", "income_amount": 1647, "income_period": "Monthly", "output_fields": ["configuration_version", "response_reference", "credit_decisions", "transaction", "interaction", "timestamp", "product_name", "errors", "credit_scores"], "upfront_amount": "0.00", "income_currency": "GBP", "legal_entity_id": 2, "metadata_inputs": ["legal_entity_id", "job", "beneficiary"], "credit_decisions": [{"code": "AS001", "reason": "AS001 Score", "identifier": "PRIMARY", "description": "Accept"}], "metadata_outputs": ["legal_entity", "detail", "raw_request", "raw_response", "modified", "status", "input_fields", "metadata_outputs", "output_fields", "metadata_inputs", "created", "url", "user", "processing"], "employment_status": "FULLTIME", "expenditure_amount": "200.00", "expenditure_period": "Monthly", "response_reference": "bc9cbcbe-9f69-437c-88ff-e302849cedd9", "monthly_living_costs": "0.00", "other_monthly_income": "0.00", "configuration_version": 1, "sole_monthly_mortgage": "0.00", "joint_monthly_mortgage": "0.00"}, "idv_transaction_key": 8244000002130099, "request_tracking_id": "279174565234609061", "host_organisation_id": 1, "idv_question_headers": [{"header_text": "Your Equifax credit file indicates that you may have a mortgage account opened on or around November 2016 and updated in December 2017.", "applies_to_question": [5, 6]}, {"header_text": "Your Equifax credit file indicates that you may have a credit or store card account opened on or around September 2016 and updated in December 2017.", "applies_to_question": [3, 4]}, {"header_text": "Your Equifax credit file indicates that you may have a current account opened on or around December 2016.", "applies_to_question": [1, 2]}], "configuration_version": 1, "primary_ebav_decision": "DECLINE", "salesforce_contact_id": "0039E00000PrBHxQAN", "_journey_data_injected": true, "host_organisation_name": "LiveLend", "idv_transaction_expiry": "2018-01-13T15:48:19.069569Z", "idv_verification_score": 60, "idv_assessment_decision": "PASS", "idv_transaction_complete": "2018-01-13T15:19:51.994512Z", "_loan_and_payment_counter": 1, "session_unique_identifier": "1b7dc504-9ffb-4154-ace9-71826c0af7c2", "_full_account_data_refresh": false, "credit_reference_agency_id": 8, "income_amount_gross_annual": "24500.00", "service_list_item_counters": {}, "_update_auth0_profile_in_request_session": false}}, "person_id": 43},"event_type_application_code":"CUSTOMER_APP_SUBMIT"},
 {"event_id":3035,"aggregate_version":2,"event_timestamp":"2021-03-29T15:23:20.644554+00:00","event_type_id":2,"event_payload":{"decisions": {"primary_ewc_decision": "REFER", "primary_ebav_decision": "PROCEED", "primary_sira_decision": "PROCEED", "primary_aml_fraud_decision": "PROCEED"}, "person_id": 16, "primary_decision": "REFER", "integrations_payload": {"url": "https://integrations.com/bankaccount/verification/123/", "created": "2018-11-15T17:12:37.700360Z", "addresses": [{"county": null, "line_1": "YOBOTA STREET 1", "line_2": "YOBOTA STREET 2", "building": "100", "postcode": "YO30TA", "post_town": "YOBOTA TOWN", "address_type": "Current", "time_at_address": "180"}], "last_name": "Jackson", "sort_code": "112233", "first_name": "Michael", "date_of_birth": "1998-11-04", "account_number": "19874624", "bankaccount_verification_attributes": [{"outcome_code": "225", "characteristic_code": "USC4", "outcome_description": null, "characteristic_description": null}, {"outcome_code": "9", "characteristic_code": "USC302", "outcome_description": null, "characteristic_description": "Application 1 reference number char 10 onwards."}, {"outcome_code": "66569", "characteristic_code": "USC301", "outcome_description": null, "characteristic_description": "Application 1 reference number, chars 1 through 9."}, {"outcome_code": "1", "characteristic_code": "USC2", "outcome_description": null, "characteristic_description": "Number of applications referenced."}, {"outcome_code": "3", "characteristic_code": "USC1", "outcome_description": null, "characteristic_description": "Number of rules hit."}, {"outcome_code": "0", "characteristic_code": "FBC5", "outcome_description": "PASS", "characteristic_description": "FraudScan Bank Group - Combined Sort Code/Account Number."}, {"outcome_code": "Y", "characteristic_code": "FBC2", "outcome_description": "Passed Validation.", "characteristic_description": "FraudScan Bank Group - Account Number Check."}, {"outcome_code": "Y", "characteristic_code": "FBC1", "outcome_description": "Passed Validation.", "characteristic_description": "FraudScan Bank Group - Sort Code Check."}, {"outcome_code": "H", "characteristic_code": "QSP042", "outcome_description": "SortCode/AccountNumber not available.", "characteristic_description": "Company name check rather than sortcode"}, {"outcome_code": "M", "characteristic_code": "QSP074", "outcome_description": "No data found at the supplied address.", "characteristic_description": "Account number verification(Previous Address)."}, {"outcome_code": "M", "characteristic_code": "QSP070", "outcome_description": "No data found at the supplied address.", "characteristic_description": "Sort code verification (Previous Address)."}, {"outcome_code": "H", "characteristic_code": "QSC042", "outcome_description": "SortCode/AccountNumber not available.", "characteristic_description": "Company name check rather than sortcode"}, {"outcome_code": "1", "characteristic_code": "QSC074", "outcome_description": "SortCode/AccountNumber valid.", "characteristic_description": "Account number verification(Current Address)."}, {"outcome_code": "1", "characteristic_code": "QSC070", "outcome_description": "SortCode/AccountNumber valid.", "characteristic_description": "Sort code verification (Current Address)."}]}},"event_type_application_code":"FRAUD_DECISION"},
 {"event_id":3036,"aggregate_version":3,"event_timestamp":"2021-03-29T15:23:20.671544+00:00","event_type_id":2,"event_payload":{"decisions": {"primary_ebav_decision": "PROCEED", "primary_sira_decision": "REFER", "primary_aml_fraud_decision": "PROCEED"}, "person_id": 16, "primary_decision": "REFER", "integrations_payload": {"url": "https://integrations.com/bankaccount/verification/123/", "created": "2018-11-15T17:12:37.700360Z", "addresses": [{"county": null, "line_1": "YOBOTA STREET 1", "line_2": "YOBOTA STREET 2", "building": "100", "postcode": "YO30TA", "post_town": "YOBOTA TOWN", "address_type": "Current", "time_at_address": "180"}], "last_name": "Jackson", "sort_code": "112233", "first_name": "Michael", "date_of_birth": "1998-11-04", "account_number": "19874624", "bankaccount_verification_attributes": [{"outcome_code": "225", "characteristic_code": "USC4", "outcome_description": null, "characteristic_description": null}, {"outcome_code": "9", "characteristic_code": "USC302", "outcome_description": null, "characteristic_description": "Application 1 reference number char 10 onwards."}, {"outcome_code": "66569", "characteristic_code": "USC301", "outcome_description": null, "characteristic_description": "Application 1 reference number, chars 1 through 9."}, {"outcome_code": "1", "characteristic_code": "USC2", "outcome_description": null, "characteristic_description": "Number of applications referenced."}, {"outcome_code": "3", "characteristic_code": "USC1", "outcome_description": null, "characteristic_description": "Number of rules hit."}, {"outcome_code": "0", "characteristic_code": "FBC5", "outcome_description": "PASS", "characteristic_description": "FraudScan Bank Group - Combined Sort Code/Account Number."}, {"outcome_code": "Y", "characteristic_code": "FBC2", "outcome_description": "Passed Validation.", "characteristic_description": "FraudScan Bank Group - Account Number Check."}, {"outcome_code": "Y", "characteristic_code": "FBC1", "outcome_description": "Passed Validation.", "characteristic_description": "FraudScan Bank Group - Sort Code Check."}, {"outcome_code": "H", "characteristic_code": "QSP042", "outcome_description": "SortCode/AccountNumber not available.", "characteristic_description": "Company name check rather than sortcode"}, {"outcome_code": "M", "characteristic_code": "QSP074", "outcome_description": "No data found at the supplied address.", "characteristic_description": "Account number verification(Previous Address)."}, {"outcome_code": "M", "characteristic_code": "QSP070", "outcome_description": "No data found at the supplied address.", "characteristic_description": "Sort code verification (Previous Address)."}, {"outcome_code": "H", "characteristic_code": "QSC042", "outcome_description": "SortCode/AccountNumber not available.", "characteristic_description": "Company name check rather than sortcode"}, {"outcome_code": "1", "characteristic_code": "QSC074", "outcome_description": "SortCode/AccountNumber valid.", "characteristic_description": "Account number verification(Current Address)."}, {"outcome_code": "1", "characteristic_code": "QSC070", "outcome_description": "SortCode/AccountNumber valid.", "characteristic_description": "Sort code verification (Current Address)."}]}},"event_type_application_code":"FRAUD_DECISION"}]')
AS e (event_id int, aggregate_version text, c text);

SELECT uv.*,
       e.*
--        e.body,
--        e.body::jsonb -> 'aggregate_version'
FROM realtime.unresolved_view uv
         CROSS JOIN LATERAL JSONB_TO_RECORDSET(uv.aggregate_history::jsonb) e (event_id int, aggregate_version text, c text)
WHERE uv.aggregate_uuid = 'da8d0ffd-a963-4646-8beb-c769dc9c77f2' --p_aggregate_uuid
  AND uv.resolution_event_type_id = 3                            --v_event_type_id
  AND uv.cause_event_id = e.event_id;

--JSONB_ARRAY_ELEMENTS
SELECT *
FROM realtime.unresolved u
WHERE u.cause_event_id IN (
    SELECT uv.cause_event_id
    FROM realtime.unresolved_view uv
    WHERE uv.aggregate_uuid = 'da8d0ffd-a963-4646-8beb-c769dc9c77f2' --p_aggregate_uuid
      AND uv.resolution_event_type_id = 3                            --v_event_type_id
      AND EXISTS(
            SELECT *
            FROM JSONB_ARRAY_ELEMENTS(uv.aggregate_history::jsonb) e (vals)
            WHERE CAST(e.vals::jsonb -> 'event_id' AS integer) = uv.cause_event_id
              AND CAST(e.vals::jsonb -> 'aggregate_version' AS integer) = 3 --p_old_version
        )
);



DO
$BODY$
    DECLARE
        p_resolution_event_type_application_code realtime.event_type.event_type_application_code%type = 'FRAUD_OVERRIDE';
        p_aggregate_uuid                         realtime.event.aggregate_uuid%TYPE                   = 'da8d0ffd-a963-4646-8beb-c769dc9c77f2';
        v_event_type_id                          realtime.event_type.event_type_id%type               = 3;
        p_old_version                            realtime.event.aggregate_version%TYPE                = 3;
        v_cause_event_id                         integer;
    BEGIN

        SELECT event_type_id
        INTO v_event_type_id
        FROM realtime.event_type
        WHERE event_type_application_code = p_resolution_event_type_application_code;

        SELECT *
        INTO v_cause_event_id
        FROM realtime.unresolved u
        WHERE u.cause_event_id IN (
            SELECT uv.cause_event_id
            FROM realtime.unresolved_view uv
            WHERE uv.aggregate_uuid = p_aggregate_uuid
              AND uv.resolution_event_type_id = v_event_type_id
              AND EXISTS(
                    SELECT *
                    FROM JSONB_TO_RECORDSET(uv.aggregate_history::jsonb) e (event_id int, aggregate_version int)
                    WHERE e.event_id = uv.cause_event_id
                      AND e.aggregate_version = p_old_version)
        );

        RAISE INFO 'INFO %', v_cause_event_id;
        --RAISE WARNING 'WARNING %', v_cause_event_id;

    END
$BODY$;

SELECT *
FROM changelog.changelog
ORDER BY changelog_id DESC
LIMIT 4;

select coalesce(max(version_number::int), -1) from changelog.changelog where change_type = 'FEATURE';

-- GRANT SELECT ON ALL TABLES IN SCHEMA realtime TO qs_pavel_staff;

-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA realtime TO qs_pavel_staff;


  select
    cast(event_payload->>'person_id' as int) as person_id,
    event_payload#>>'{decisions,primary_ebav_decision}' as bank_account_verification_outcome,
    event_payload#>>'{decisions,primary_aml_fraud_decision}' as bank_account_fraud_check_outcome,
    event_payload#>>'{decisions,primary_sira_decision}' as fraud_check_outcome,
    e.*,
    event_payload#>>'{primary_decision}' as primary_decision,
    event_payload#>'{integrations_payload,bankaccount_verification_attributes}' as verification_attributes,
    event_payload#>>'{integrations_payload,url}' as integrations_url,
    event_payload#>>'{integrations_payload,account_number}' as bank_account_number,
    event_payload#>>'{integrations_payload,sort_code}' as sort_code,
    COALESCE(event_payload->>'primary_decision_type', 'SIRA') AS fraud_check_type
  from realtime.event_view e
  where event_type_is_bank_account_check is true

  AND event_type_application_code = 'FRAUD_DECISION';


 select * from reporting.fraud_override_get_report(true, false, null, 'LENA');)
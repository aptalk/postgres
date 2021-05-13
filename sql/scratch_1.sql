--core.identifier_key
SELECT *
FROM core.identifier_key
WHERE identifier_key_application_code = 'INTEGRATIONSACCOUNT';
--Nothing new inserted (no need to check)

--core.service_provider_system
SELECT *
FROM core.service_provider_system
WHERE service_provider_system_application_code = 'ROBERTEBAVEWC';

--core.service_provider_system_type
SELECT *
FROM core.service_provider_system_type
WHERE service_provider_system_type_application_code = 'PERSONEBAVEWC';

--core.service_provider_system_service_provider_system_type_link
SELECT l.*
FROM core.service_provider_system_service_provider_system_type_link l
         INNER JOIN core.service_provider_system s USING (service_provider_system_id)
WHERE s.service_provider_system_application_code = 'ROBERTEBAVEWC';

--core.service_provider_identifier_key_link
SELECT l.*
FROM core.service_provider_identifier_key_link l
         INNER JOIN core.identifier_key i ON l.identifier_key_id = i.identifier_key_id
         INNER JOIN core.service_provider s ON l.service_provider_id = s.service_provider_id
WHERE i.identifier_key_application_code = 'INTEGRATIONSACCOUNT'
  AND s.service_provider_application_code = 'CHETWOOD';
--Nothing new inserted (no need to check)

--core.service_provider_identifier_key_value_set
SELECT s.*
FROM core.service_provider_identifier_key_value_set s
         INNER JOIN core.service_provider_identifier_key_value_set_detail d
                    ON s.service_provider_identifier_key_value_set_id =
                       d.service_provider_identifier_key_value_set_id
WHERE service_provider_identifier_key_value = 'robert_1';

--core.service_provider_identifier_key_value_set_detail
SELECT *
FROM core.service_provider_identifier_key_value_set_detail
WHERE service_provider_identifier_key_value = 'robert_1';

--core.host_organisation_service_provider_key_value_set_link
SELECT h.host_organisation_application_code, sl.*
FROM core.host_organisation_service_provider_key_value_set_link sl
         INNER JOIN core.service_provider_system_service_provider_system_type_link l
                    ON sl.service_provider_system_service_provider_system_type_link_id =
                       l.service_provider_system_service_provider_system_type_link_id
         INNER JOIN core.service_provider_system s USING (service_provider_system_id)
         INNER JOIN core.host_organisation h ON sl.host_organisation_id = h.host_organisation_id
WHERE s.service_provider_system_application_code = 'ROBERTEBAVEWC';

--core.decisioning_system
SELECT d.*
FROM core.decisioning_system d
         INNER JOIN core.service_provider_system s ON d.decisioning_system_id = s.service_provider_system_id
WHERE service_provider_system_application_code = 'ROBERTEBAVEWC';


--Test audit tables:

--audit.service_provider_system
SELECT a.*
FROM audit.service_provider_system a
         INNER JOIN core.service_provider_system s ON a.audit_key_id = s.service_provider_system_id
WHERE service_provider_system_application_code = 'ROBERTEBAVEWC';

--audit.service_provider_system_type
SELECT a.*
FROM audit.service_provider_system_type a
         INNER JOIN core.service_provider_system_type s ON a.audit_key_id = s.service_provider_system_type_id
WHERE service_provider_system_type_application_code = 'PERSONEBAVEWC';

--audit.service_provider_system_service_provider_system_type_link
SELECT a.*
FROM audit.service_provider_system_service_provider_system_type_link a
         INNER JOIN core.service_provider_system_service_provider_system_type_link l
                    ON a.audit_key_id = l.service_provider_system_service_provider_system_type_link_id
         INNER JOIN core.service_provider_system s USING (service_provider_system_id)
WHERE s.service_provider_system_application_code = 'ROBERTEBAVEWC';

--audit.service_provider_identifier_key_value_set
SELECT a.*
FROM audit.service_provider_identifier_key_value_set a
         INNER JOIN core.service_provider_identifier_key_value_set s
                    ON s.service_provider_identifier_key_value_set_id = a.audit_key_id
         INNER JOIN core.service_provider_identifier_key_value_set_detail d
                    ON s.service_provider_identifier_key_value_set_id =
                       d.service_provider_identifier_key_value_set_id
WHERE service_provider_identifier_key_value = 'robert_1';

--audit.service_provider_identifier_key_value_set_detail
SELECT a.*
FROM audit.service_provider_identifier_key_value_set_detail a
         INNER JOIN core.service_provider_identifier_key_value_set_detail d
                    ON a.audit_key_id = d.service_provider_identifier_key_value_set_detail_id
WHERE d.service_provider_identifier_key_value = 'robert_1';

--audit.host_organisation_service_provider_key_value_set_link
SELECT a.*
FROM audit.host_organisation_service_provider_key_value_set_link a
         INNER JOIN core.host_organisation_service_provider_key_value_set_link sl
                    ON a.audit_key_id = sl.host_organisation_service_provider_key_value_set_link_id
         INNER JOIN core.service_provider_system_service_provider_system_type_link l
                    ON sl.service_provider_system_service_provider_system_type_link_id =
                       l.service_provider_system_service_provider_system_type_link_id
         INNER JOIN core.service_provider_system s USING (service_provider_system_id)
         INNER JOIN core.host_organisation h ON sl.host_organisation_id = h.host_organisation_id
WHERE s.service_provider_system_application_code = 'ROBERTEBAVEWC';

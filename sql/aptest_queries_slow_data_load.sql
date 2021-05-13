-- SELECT uv.cause_event_id,
--        *,
--        e.json,
--        e.json::jsonb -> 'aggregate_version'
-- FROM realtime.unresolved_view uv
--          CROSS JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(uv.aggregate_history::jsonb) e (json)
-- WHERE uv.aggregate_uuid = '45763f73-95dc-4110-b60d-97a89122e734' --p_aggregate_uuid
--   AND uv.resolution_event_type_id = 3                            --v_event_type_id
--   AND CAST(e.json::jsonb -> 'event_id' AS integer) = uv.cause_event_id
-- --  AND CAST(e.json::jsonb -> 'aggregate_version' AS integer) = 2; --p_old_version

CREATE TABLE IF NOT EXISTS realtime.andrew_person(data jsonb);

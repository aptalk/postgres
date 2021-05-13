-- DROP TABLE IF EXISTS realtime.ap_test;
CREATE TABLE IF NOT EXISTS realtime.ap_test(data jsonb);

-- NOTE: Open file quote-store_scratch_1_slow_dataload.sql
-- NOTE: Open file quote-store_scratch_1_slow_dataload.sql
-- NOTE: Open file quote-store_scratch_1_slow_dataload.sql

--1. Display all users’s details

SELECT JSONB_EACH_TEXT(t.data)
FROM realtime.ap_test t;

-- --Output will be like this. It contains two column key and value.
--
-- (0,"{""name"":""Kiera Halvorson"",""email"":""keegan.bashirian@legros.name"",""interest"":[""memes"",""agriculture""],""age"":25}")
-- (1,"{""name"":""Golden Lynch"",""email"":""brandon.kautzer@boehm.org"",""interest"":[""DIY home"",""electronics""],""age"":43}")
-- ...

-- Now Lets take each persons interest. In the below query we are taking key(person’s Id) and navigating to next level to get person’s interest.

SELECT person_data.key                              ID,
       data -> person_data.key::text ->> 'interest' Interest
FROM realtime.ap_test t
         CROSS JOIN LATERAL JSONB_EACH_TEXT(t.data) AS person_data;

-- Output will be

-- id  |interest                          |
-- ----|----------------------------------|
-- 0   |["memes","agriculture"]           |
-- 1   |["DIY home","electronics"]        |
-- 2   |["garden design","DIY home"]      |
-- ...

--Now lets take only primary interest of a person.

SELECT person_data.key                                            ID,
       (data -> person_data.key::text ->> 'interest')::jsonb -> 0 Interest
FROM realtime.ap_test t
         CROSS JOIN LATERAL JSONB_EACH_TEXT(t.data) AS person_data;

-- -- Output will be
-- id  |interest        |
-- ----|----------------|
-- 0   |"memes"         |
-- 1   |"DIY home"      |
-- 2   |"garden design" |
-- ...

-- Note the selection option “(data -> person_data.key::text ->> ‘interest’)::jsonb -> 0”.
-- Similarly to display person’s secondary interest use the index 1

SELECT person_data.key                                            ID,
       (data -> person_data.key::text ->> 'interest')::jsonb -> 1 Interest
FROM realtime.ap_test t
         CROSS JOIN LATERAL JSONB_EACH_TEXT(t.data) AS person_data;

-- -- Output will be

-- id  |interest        |
-- ----|----------------|
-- 0   |"agriculture"   |
-- 1   |"electronics"   |
-- 2   |"DIY home"      |
-- ...

-- 2. User who are interested it “DIY home”

--CREATE INDEX ix_ap_test ON realtime.ap_test USING gin (data);
--DROP INDEX IF EXISTS realtime.ix_ap_test;
--CREATE INDEX ix_ap_test_2 ON realtime.ap_test USING gin (data jsonb_path_ops);
--DROP INDEX IF EXISTS realtime.ix_ap_test_2;
--CREATE INDEX ix_ap_test_interest ON realtime.ap_test USING btree ((data->'interest'));
--DROP INDEX IF EXISTS realtime.ix_ap_test_interest;

SELECT (data -> person_data.key::text ->> 'name')     AS Name,
       (data -> person_data.key::text ->> 'email')    AS Email,
       (data -> person_data.key::text ->> 'interest') AS Interest
FROM realtime.ap_test t
         CROSS JOIN LATERAL JSONB_EACH_TEXT(t.data) AS person_data
WHERE (data -> person_data.key::text ->> 'interest')::jsonb ? 'DIY home';

-- Above query will return person’s name, email and interest who are all interested in “DIY home”

-- -- Output will be :
-- name                     |email                                    |interest                     |
-- -------------------------|-----------------------------------------|-----------------------------|
-- Golden Lynch             |brandon.kautzer@boehm.org                |["DIY home","electronics"]   |
-- Alex Zemlak              |braulio_kirlin@hane.biz                  |["garden design","DIY home"] |

-- 3. Users who are interested it “nature” and their age is less than 25

SELECT (data -> person_data.key::text ->> 'name')     AS Name,
       (data -> person_data.key::text ->> 'age')      AS Age,
       (data -> person_data.key::text ->> 'interest') AS Interest
FROM realtime.ap_test t
         CROSS JOIN LATERAL JSONB_EACH_TEXT(t.data) AS person_data
WHERE (data -> person_data.key::text ->> 'age')::integer < 25
  AND (data -> person_data.key::text ->> 'interest')::jsonb ? 'nature';

--4. User who has same primary and secondary interest

SELECT (data -> person_data.key::text ->> 'name')     AS Name,
       (data -> person_data.key::text ->> 'email')    AS Email,
       (data -> person_data.key::text ->> 'interest') AS Interest
FROM realtime.ap_test t
         CROSS JOIN LATERAL JSONB_EACH_TEXT(t.data) AS person_data
WHERE (data -> person_data.key::text ->> 'interest')::jsonb -> 0 =
      (data -> person_data.key::text ->> 'interest')::jsonb -> 1;

-- I am comparing the Primary interest with Primary and Secondary interest.
-- Primary interest (data -> person_data.key::text ->> ‘interest’)::jsonb -> 0
-- Secondary interest (data -> person_data.key::text ->> ‘interest’)::jsonb -> 1

-- 5. User who are interested in “web design” and “ai”

SELECT (data -> person_data.key::text ->> 'name')     AS Name,
       (data -> person_data.key::text ->> 'email')    AS Email,
       (data -> person_data.key::text ->> 'interest') AS Interest
FROM realtime.ap_test t
         CROSS JOIN LATERAL JSONB_EACH_TEXT(t.data) AS person_data
WHERE (data -> person_data.key::text ->> 'interest')::jsonb ? 'web design'
  AND (data -> person_data.key::text ->> 'interest')::jsonb ? 'ai';

--Optimization for above queries are welcome. :)

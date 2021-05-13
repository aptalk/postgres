-- CREATE TABLE customers(name varchar(256),contacts jsonb);
--
-- INSERT INTO customers (name, contacts)
-- VALUES ('Jimi','[{"type": "phone","value": "+1-202-555-0105"},{"type": "email","value": "jimi@gmail.com"}]')
--     ,('Janis','[{"type": "email","value": "janis@gmail.com"}]');

select * from customers;

select jsonb_set(
  '[{"type": "phone", "value": "+1-202-555-0105"},{"type": "email", "value": "jimi@gmail.com"}]',
  '{1,value}',
  '"jimi.hendrix@gmail.com"',
  false
);

select jsonb_set(
  '[{"type": "email", "value": "janis@gmail.com"}]',
  '{0,value}',
  '"janis.joplin@gmail.com"',
  false
);

select index-1 as index
  from customers
      ,jsonb_array_elements(contacts) with ordinality arr(contact, index)
 where contact->>'type' = 'email'
   and name = 'Jimi';

with contact_email as (
  select ('{'||index-1||',value}')::text[] as path
    from customers
        ,jsonb_array_elements(contacts) with ordinality arr(contact, index)
   where contact->>'type' = 'email'
     and name = 'Jimi'
)
update customers
   set contacts = jsonb_set(contacts, contact_email.path, '"jimi.hendrix@gmail.com"', false)
  from contact_email
 where name = 'Jimi';

 select * from customers;
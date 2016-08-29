-- This code requires the pg-distance plugin:
-- 

-- select * from
-- record_link(
--   '{"address":"123 Main St"}'::jsonb,
--   '{"address":"123 Secondary St"}'::jsonb,
--   '{"address":0.91}'::jsonb);

create or replace function
  record_link (record1 jsonb, record2 jsonb, weights jsonb)
    returns float as
$f$

  declare
    keys text[]; -- e.g. array['address', 'city', 'state', 'zip_code', 'store_number']
    key text;
    link_strength float := 0;
    effective_weight float := 0.0;
  begin
    select
      array_agg(k)
    into
      keys
    from
      jsonb_object_keys(weights) as k
    ;

    foreach key in array keys loop
      if  coalesce(record1->>key, '') <> ''
      and coalesce(record2->>key, '') <> '' then
        link_strength    := link_strength + (jaro(record1->>key, record2->>key) * (weights->>key)::float);
        effective_weight := effective_weight + (weights->>key)::float;
      end if;
    end loop;

    return link_strength / effective_weight;
  end;

$f$
language plpgsql;
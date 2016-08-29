-- 397662.438 ms

explain analyze

select distinct
  a1.stub
  ,a1.version
  ,a1.serialno
from
  (
    select
      a1.stub
      ,a1.version
      ,a1.serialno
      ,a1.record
    from
      atom as a1
    where
      a1.stub = 'panera_bread'
    and
      a1.version = '2015-06-24'
  ) as a1
inner join
  (
    select
      a2.stub
      ,a2.version
      ,a2.serialno
      ,a2.record
    from
      atom as a2
    where
      a2.stub = 'panera_bread'
    and
      a2.version = '2015-06-24'
  ) as a2
on
  a1.serialno <> a2.serialno
and
  record_link(a1.record, a2.record, $${"address":0.96, "city":0.94, "state":0.99, "zip_code":0.94, "phone_number":0.98, "store_number":0.6, "store_name":0.2}$$::jsonb) between 0.91 and 0.9999
;
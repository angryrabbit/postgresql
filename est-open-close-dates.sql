-- explain analyze

with
  list_tl as
    (
      select
        lag(t1.version) over (order by t1.version asc)
        ,t1.version
        ,lead(t1.version) over (order by t1.version asc)
      from
        (
          select distinct
            atom.version
          from
            stubs
          left join
            atom
          on
            stubs.stub = atom.stub
          and
            stubs.during @> atom.version
          where
            stubs.list_id = 326
          order by
            atom.version
        ) as t1
    )
  ,loc_tl as
    (
      select
        lists.short_name
        ,graph.oversion
        ,graph.oserialno
        ,graph.ostub
        ,min(graph.version) as minima
        ,max(graph.version) as maxima
      from
        lists
      left join
        stubs
      on
        lists.id = stubs.list_id
      left join
        graph
      on
        stubs.stub = graph.ostub
      and
        stubs.during @> graph.oversion
      where
        lists.id = 326
      group by
        lists.short_name
        ,graph.ostub
        ,graph.oversion
        ,graph.oserialno
    )
  ,latest_vsn as
    (
      select
        t1.oversion
        ,t1.ostub
        ,t1.oserialno
        ,graph.version
        ,graph.stub
        ,graph.serialno
      from
        (
          select
            short_name
            ,oversion
            ,ostub
            ,oserialno
            ,max(version) as maxima
          from
            lists
          left join
            stubs
          on
            lists.id = stubs.list_id
          left join
            graph
          on
            stubs.stub = graph.ostub
          and
            stubs.during @> graph.oversion
          where
            lists.id = 326
          group by
            short_name
            ,oversion
            ,ostub
            ,oserialno
        ) as t1
      left join
        graph
      on
        t1.oversion = graph.oversion
      and
        t1.ostub = graph.ostub
      and
        t1.oserialno = graph.oserialno
      and
        t1.maxima = graph.version
    )

select
  loc_tl.short_name as "List Name"
  ,record ->> 'address' as "Address"
  ,record ->> 'address_line_2' as "Address Line 2"
  ,record ->> 'city' as "City"
  ,record ->> 'state' as "State"
  ,record ->> 'zip_code' as "Zip Code"
  ,record ->> 'county' as "County"
  ,record ->> 'country' as "Country"
  ,record ->> 'latitude' as "Latitude"
  ,record ->> 'longitude' as "Longitude"
  ,case when list_tl_1.lag is null then null
        else loc_tl.minima end as "Open Date"
  ,loc_tl.minima - list_tl_1.lag as "Open Accuracy"
  ,list_tl_2.lead as "Close Date"
  ,list_tl_2.lead - loc_tl.maxima as "Close Accuracy"
from
  loc_tl
left join
  list_tl as list_tl_1
on
  list_tl_1.version = loc_tl.minima
left join
  list_tl as list_tl_2
on
  list_tl_2.version = loc_tl.maxima
left join
  latest_vsn
on
  loc_tl.oversion = latest_vsn.oversion
and
  loc_tl.ostub = latest_vsn.ostub
and
  loc_tl.oserialno = latest_vsn.oserialno
left join
  atom
on
  latest_vsn.version = atom.version
and
  latest_vsn.stub = atom.stub
and
  latest_vsn.serialno = atom.serialno
;
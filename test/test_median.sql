begin;
create extension lostgis;

select plan(1);


select
    is(median(s.v), 5::float)
from
    (select unnest(array[1, 2, 3, 4, 5, 6, 7, 8, 9]) as v order by random()) as s;

rollback;

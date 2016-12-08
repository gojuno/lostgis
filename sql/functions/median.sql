create or replace function _final_median(anyarray)
    returns float8 as $$

select
    percentile_cont(0.5) within group (order by v)
from
    (select unnest($1) as v) as s;
$$ language sql immutable parallel safe;

drop aggregate if exists median (anyelement);
create aggregate median( anyelement ) (
    sfunc = array_append,
    stype = anyarray,
    finalfunc = _final_median,
    initcond = '{}',
    combinefunc = array_cat,
    parallel = safe
);

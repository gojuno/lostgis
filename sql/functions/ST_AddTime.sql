create or replace function ST_AddTime(
    tpvarray             tpv [],
    start_time           timestamptz,
    end_time             timestamptz,
    interpolation_method text default 'length' -- 'length', 'count'
)
    returns tpv []
as $$
declare
    tpvarray_out    tpv [];
    tpvarray_length float;
    invspeed        interval; -- seconds per meter
    prev_tpv        tpv;
    cur_tpv         tpv;
begin
    if array_length(tpvarray, 1) = 0
    then
        return tpvarray;
    end if;

    if array_length(tpvarray, 1) in (1, 2)
    then
        prev_tpv = tpvarray [1];
        prev_tpv.ts = start_time;
        cur_tpv = tpvarray [-1];
        cur_tpv.ts = end_time;
        return array [prev_tpv, cur_tpv];
    end if;

    if interpolation_method = 'length'
    then
        tpvarray_length = ST_Length(tpvarray :: geography);
        if tpvarray_length < 0.001
        then
            interpolation_method = 'count';
            raise notice 'Length is too small, switching to "count" interpolation';
        end if;
    end if;
    if interpolation_method = 'length'
    then
        invspeed = (end_time - start_time) / tpvarray_length;
    elseif interpolation_method = 'count'
        then
            invspeed = (end_time - start_time) / (array_length(tpvarray, 1) - 1);
    else
        raise 'Unknown interpolation method: %', interpolation_method;
    end if;

    prev_tpv = tpvarray [1];

    prev_tpv.ts = start_time;
    if interpolation_method = 'count'
    then
        prev_tpv.ts = start_time - invspeed;
    end if;

    tpvarray_out = array [] :: tpv [];
    for cur_tpv in (
        select *
        from unnest(tpvarray)
    ) loop
        if interpolation_method = 'length'
        then
            cur_tpv.ts = prev_tpv.ts + invspeed * ST_Distance(prev_tpv, cur_tpv);
        else
            cur_tpv.ts = prev_tpv.ts + invspeed;
        end if;
        tpvarray_out = array_append(tpvarray_out, cur_tpv);
        prev_tpv = cur_tpv;
    end loop;
    return tpvarray_out;
end;
$$ language 'plpgsql' immutable strict parallel safe;

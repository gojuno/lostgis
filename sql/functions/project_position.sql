create or replace function project_position(
    p_tpv    TPV,
    new_time timestamptz
)
    returns TPV
as $$
declare
    timedelta        float;
    merc_path_length float;
begin
    timedelta = extract(epoch from new_time - p_tpv.ts);
    merc_path_length = coalesce(p_tpv.speed * timedelta * icoslat(p_tpv), 0);

    -- project geometry along line
    p_tpv.geom = ST_Translate(
        p_tpv.geom,

        sind(p_tpv.heading) *
        merc_path_length,

        cosd(p_tpv.heading) *
        merc_path_length
    );

    -- 8.3 is average speed measured among moving drivers
    p_tpv.accuracy = round(p_tpv.accuracy + abs(greatest(p_tpv.speed, 8.3) * abs(timedelta)));
    p_tpv.ts = new_time;
    return p_tpv;
end;
$$
language 'plpgsql' immutable strict parallel safe;
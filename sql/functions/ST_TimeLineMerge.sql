create or replace function ST_TimeLineMerge(
    geoms geometry(linestringz) []
)
    returns setof geometry(linestringz) as
$$
declare
    accum   geometry;
    current geometry;
begin
    accum = null;
    -- sort geometries by Z axis
    geoms = (
        select array_agg(
            case when ST_Z(ST_StartPoint(geom)) <= ST_Z(ST_EndPoint(geom))
                then
                    geom
            else
                ST_Reverse(geom)
            end
        order by ST_Z(ST_EndPoint(geom)) + ST_Z(ST_StartPoint(geom))
        )
        from (
                 select (ST_Dump(geom)).geom as geom
                 from unnest(geoms) geom
             ) g
        where
            not ST_IsEmpty(geom)
            and ST_StartPoint(geom) is not null
    );
    for current in (select unnest(geoms)) loop
        if abs(ST_Z(ST_EndPoint(accum)) - ST_Z(ST_StartPoint(current))) > 0.001
        then
            return next accum;
            accum = null;
        end if;
        if accum is null
        then
            accum = current;
        else
            accum = ST_MakeLine(accum, current);
        end if;
    end loop;
    return next accum;
    return;
end
$$
language 'plpgsql' immutable strict parallel safe;

create or replace function ST_FilterSmallRings(
    geom     geometry,
    min_area float default 0
)
    returns geometry as
$$
begin
    if ST_Dimension(geom) != 2
    then
        return ST_SetSRID('POLYGON EMPTY' :: geometry, ST_SRID(geom));
    end if;

    if ST_NRings(geom) = 1
    then
        if ST_Area(geom) > min_area
        then
            return geom;
        else
            return ST_SetSRID('POLYGON EMPTY' :: geometry, ST_SRID(geom));
        end if;
    end if;

    return (
        select ST_BuildArea(
            ST_Collect(
                (ring).geom
            )
        )
        from
            (
                select ST_DumpRings(p.geom) as ring
                from
                    (select (ST_Dump(geom)).geom as geom) p
            ) p
        where
            ST_Area((ring).geom) > min_area
    );
end
$$
language 'plpgsql' immutable strict parallel safe;
create or replace function ST_RealOffsetCurve(
    geom geometry,
    radius float,
    buffer_style_parameters text default ''
) returns geometry
language plpgsql
immutable strict parallel safe
as $function$
begin
    if ST_SRID(geom) in (3857, 900913, 3395)
    then
        return ST_OffsetCurve(
            geom,
            radius / coslat(geom),
            buffer_style_parameters
        );
    end if;
end
$function$;
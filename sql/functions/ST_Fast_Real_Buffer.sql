create or replace function ST_Fast_Real_Buffer(
    geom geometry, radius float,
    buffer_style_parameters text default ''
)
    returns geometry
language plpgsql
immutable strict parallel safe
as $function$
begin
    if ST_SRID(geom) in (3857, 900913, 3395)
    then
        return ST_Buffer(
            geom,
            radius / coslat(geom),
            buffer_style_parameters
        );
    elsif ST_SRID(geom) = 4326
        then
            return ST_SetSRID(
                ST_Buffer(geom :: geography, radius) :: geometry,
                4326,
                buffer_style_parameters
            );
    else
        return ST_Buffer(geom, radius, buffer_style_parameters) :: geometry;
    end if;
end
$function$;
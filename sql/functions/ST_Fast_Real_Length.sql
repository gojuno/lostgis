create or replace function ST_Fast_Real_Length(
    geom geometry
)
    returns double precision
language plpgsql
immutable strict parallel safe
as $function$
begin
    if ST_SRID(geom) in (3857, 900913, 3395) then
        return ST_Length(geom) * coslat(geom);
    elsif ST_SRID(geom) = 4326 then
        return ST_Length(geom::geography);
    end if;
end
$function$;
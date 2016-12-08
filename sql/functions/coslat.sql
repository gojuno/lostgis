create or replace function coslat(p_geom geometry)
    returns float
language sql
immutable strict parallel safe
as $function$
select cosd(
    ST_Y(
        ST_Transform(
            ST_Centroid(
                ST_Expand(
                    p_geom,
                    0
                )
            ),
            4326
        )
    )
)
$function$;

create or replace function tanh(x float)
    returns float
language sql
immutable strict parallel safe
as $function$
select -1 + (2 / (1 + exp(-2 * x)))
$function$;

-- direct calculation of cos(lat) in 3857 without reprojecting it to 4326
-- coslat = cos(asin(tanh(Y / 6378137)))
create or replace function coslat(p_tpv tpv)
    returns float
language sql
immutable strict parallel safe
as $function$
select cos(asin(tanh(ST_Y(p_tpv.geom) / 6378137)))
$function$;

create or replace function icoslat(p_tpv tpv)
    returns float
language sql
immutable strict parallel safe
as $function$
select 1 / sqrt(1 - tanh(ST_Y(p_tpv.geom) / 6378137) ^ 2)
$function$;
create or replace function ST_GridCell(
    point geometry,
    grid_size float default 500
)
    returns geometry
language sql
immutable strict parallel safe
as $function$
select ST_Expand(
    ST_SnapToGrid(
        ST_Transform(
            ST_PointOnSurface(point),
            3857
        ),
        grid_size
    ),
    grid_size / 2
)
$function$;

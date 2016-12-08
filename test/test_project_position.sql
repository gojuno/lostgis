begin;
create extension lostgis;

select plan(1);

select
    is(
        ST_SnapToGrid(
            (project_position(
                jsonb_build_object(
                    'lon', 0,
                    'lat', 0,
                    'hdg', 0,
                    'spd', 10,
                    'ts', 1481027328.5273489 * 1000
                )::tpv,
                to_timestamp(1481027328.5273489 + 10)
            )::geometry),
            0.000001
        ),
        GeomFromEWKT('SRID=3857;POINT(0 100)')
    );

rollback;

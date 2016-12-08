begin;
create extension lostgis;

select plan(2);

select
    is(
        round(
            (ST_Fast_Real_Length(
                -- minsk - moscow
                GeomFromEWKT('SRID=4326;LINESTRING(27.561831 53.902257, 37.620393 55.75396)')
            ))::numeric, 6),
        677789.531233
    );

select
    is(
        round(
            (ST_Fast_Real_Length(
                -- minsk - moscow
                ST_Transform(
                    GeomFromEWKT('SRID=4326;LINESTRING(27.561831 53.902257, 37.620393 55.75396)'),
                    3857
                )
            ))::numeric, 6),
        676963.732126
    );

rollback;

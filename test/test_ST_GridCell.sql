begin;
create extension lostgis;

select plan(1);

select is(
    ST_GridCell('SRID=3857;POINT(11 5)'::geometry, 5),
    GeomFromEWKT(
        'SRID=3857;POLYGON(
            (7.5 2.5,
            7.5 7.5,
            12.5 7.5,
            12.5 2.5,
            7.5 2.5))'
    )
);

rollback;

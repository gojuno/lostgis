begin;
create extension lostgis;

select plan(1);

select is(
    ST_RealOffsetCurve(
        GeomFromEWKT('SRID=3857;LINESTRING(20 40, 20 20, 40 20)'),
        5.0, 'quad_segs=4 join=round'
    ),
    GeomFromEWKT('SRID=3857;LINESTRING(25 40,25 25,40 25)')
);

rollback;

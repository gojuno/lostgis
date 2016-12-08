begin;
create extension lostgis;

select plan(1);

select is(
    round((coslat('SRID=3857;POINT(11 5)'::geometry))::numeric, 6),
    1.0);

rollback;

begin;
create extension lostgis;

select plan(2);

select is(
    '{"lon": -73.9, "lat": 40.7}' :: jsonb :: tpv,
    (
        ST_Transform(GeomFromEWKT('SRID=4326;POINT(-73.9 40.7)'), 3857),
        null, null, null, null, null, null
    )::tpv
);

select is(
    '[
        {"lon": -73.9, "lat": 40.7},
        {"lon": -73.9, "lat": 40.6},
        {"lon": -73.9, "lat": 40.5}
    ]' :: jsonb :: tpv [],
    array[
        (
            ST_Transform(GeomFromEWKT('SRID=4326;POINT(-73.9 40.7)'), 3857),
            null, null, null, null, null, null
        )::tpv,
        (
            ST_Transform(GeomFromEWKT('SRID=4326;POINT(-73.9 40.6)'), 3857),
            null, null, null, null, null, null
        )::tpv,
        (
            ST_Transform(GeomFromEWKT('SRID=4326;POINT(-73.9 40.5)'), 3857),
            null, null, null, null, null, null
        )::tpv
    ]);

rollback;
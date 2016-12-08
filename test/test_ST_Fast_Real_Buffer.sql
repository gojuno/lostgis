begin;
create extension lostgis;

select plan(1);

select
    is(
        ST_SnapToGrid(
            ST_Fast_Real_Buffer(
                GeomFromEWKT('SRID=3857;LINESTRING(20 20, 40 40, 60 20)'),
                10, 'endcap=square join=bevel'
            ),
            0.1
        ),
        GeomFromEWKT(
            'SRID=3857;POLYGON((
                32.9 47.1,
                47.1 47.1,
                67.1 27.1,
                74.1 20,
                60 5.9,
                40 25.9,
                27.1 12.9,
                20 5.9,
                5.9 20,
                32.9 47.1
            ))'
        )
    );

rollback;

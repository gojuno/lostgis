begin;
create extension lostgis;

select plan(3);

select
    is(
        ST_Collect(g),
        'MULTILINESTRING Z ((0 0 0,10 10 10,100 100 100))'
    )
from
    ST_TimeLineMerge(
        array[
            'LINESTRING Z (  0   0  0, 10 10 10)',
            'LINESTRING Z (100 100 100, 10 10 10)'
        ]
    ) as g;


select
    is(
        ST_Collect(g),
        'MULTILINESTRING Z ((0 0 0,10 10 10),(0 10 0,10 10 10))'::geometry
    )
from
    ST_TimeLineMerge(
        array[
            'LINESTRING Z(0  0 0, 10 10 10)',
            'LINESTRING Z(0 10 0, 10 10 10)'
        ]
    ) as g;


select
    is(
        ST_Collect(g),
        'MULTILINESTRING Z ((0 10 0,10 10 10))'::geometry
    )
from
    ST_TimeLineMerge(
        array[
            'LINESTRING Z(0 10 0, 10 10 10)'
        ]
    ) as g;

rollback;

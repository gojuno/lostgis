begin;
create extension lostgis;

select plan(1);

select
    is(
        ST_LargestSubPolygon(
            GeomFromEWKT('MULTIPOLYGON(
                ((
                    10 10,
                    20 10,
                    20 20,
                    10 20,
                    10 10
                )),
                ((
                    10 10,
                    40 10,
                    40 40,
                    10 40,
                    10 10
                ))
            )')
        ),
        GeomFromEWKT('POLYGON((
            10 10,
            40 10,
            40 40,
            10 40,
            10 10
        ))')
    );

rollback;

begin;
create extension lostgis;

select plan(2);

select
    is(
        ST_FilterSmallRings(
            GeomFromEWKT('POLYGON((
                10 10,
                40 10,
                40 40,
                10 40,
                10 25,
                20 25,
                20 30,
                30 30,
                30 20,
                20 20,
                10 20,
                10 10
            ))'),
            1000
        ),
        GeomFromEWKT('POLYGON EMPTY')
    );

select
    is(
        ST_FilterSmallRings(
            GeomFromEWKT('POLYGON((
                10 10,
                40 10,
                40 40,
                10 40,
                10 25,
                20 25,
                20 30,
                30 30,
                30 20,
                20 20,
                10 20,
                10 10
            ))'),
            100
        ),
        GeomFromEWKT('POLYGON((
                10 10,
                40 10,
                40 40,
                10 40,
                10 25,
                20 25,
                20 30,
                30 30,
                30 20,
                20 20,
                10 20,
                10 10
            ))')
    );

rollback;

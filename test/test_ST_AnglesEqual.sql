begin;
create extension lostgis;

select plan(4);

select is(
    ST_AnglesEqual(radians(30), radians(380), true, radians(10)),
    true);

select is(
    ST_AnglesEqual(radians(30), radians(380), true, radians(5)),
    false);

select is(
    ST_AnglesEqualD(30, 380, true, 10),
    true);

select is(
    ST_AnglesEqualD(30, 380, true, 5),
    false);
rollback;

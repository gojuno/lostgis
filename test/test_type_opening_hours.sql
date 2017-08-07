begin;
create extension lostgis;

select plan(4);

select is(('24/7' :: text :: opening_hours).is_24, true);

select is(('invalid' :: text :: opening_hours).is_valid, false);

select is(
    overlaps( '2017-08-13 13:00':: timestamp,
              'Mo-Fr 05:00-15:00,19:00-21:00; Sa 05:00-12:00,14:00-21:00; Su 05:00-14:00,17:00-21:00' :: text ::
              opening_hours),
    true
);

select is(
    overlaps( '2017-08-13 14:00':: timestamp,
              'Mo-Fr 05:00-15:00,19:00-21:00; Sa 05:00-12:00,14:00-21:00; Su 05:00-14:00,17:00-21:00' :: text ::
              opening_hours),
    false
);

rollback;

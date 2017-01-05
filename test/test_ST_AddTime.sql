begin;
create extension lostgis;

select plan(1);

select is(
    ST_AddTime(
    '[
      {
        "lon": 0,
        "lat": 0
      },
      {
        "lon": 0,
        "lat": 0
      },
      {
        "lon": 0,
        "lat": 0
      }
    ]' :: jsonb :: tpv [],
    '2016-01-01T00:00:00Z',
    '2016-01-01T06:00:00Z'
) :: jsonb,
'[{"ts": 1451606400000, "lat": 0, "lon": 0}, {"ts": 1451617200000, "lat": 0, "lon": 0}, {"ts": 1451628000000, "lat": 0, "lon": 0}]'::jsonb);

rollback;

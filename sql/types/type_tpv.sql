drop type if exists tpv cascade;
-- TPV = time, position, velocity
create type TPV as (
    -- position
    geom     geometry(point, 3857),
    accuracy float,

    -- velocity
    heading  float,
    speed    float,

    -- time
    ts       timestamptz,

    -- helpers
    source   text,
    osm_id   bigint
);

-- convenience functions
create or replace function _tpv_from_json(
    p_tpv jsonb
)
    returns tpv
as $$
select (
    ST_Transform(
        ST_SetSRID(
            ST_MakePoint(
                (p_tpv ->> 'lon') :: float,
                (p_tpv ->> 'lat') :: float
            ),
            4326
        ),
        3857
    ),
    p_tpv ->> 'acc',
    p_tpv ->> 'hdg',
    p_tpv ->> 'spd',
    to_timestamp((p_tpv ->> 'ts') :: float / 1000),
    p_tpv ->> 'src',
    p_tpv ->> 'osm_id'
) :: tpv
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( jsonb as tpv );
create cast ( jsonb as tpv )
with function _tpv_from_json(jsonb);

create or replace function _tpv_from_geometry(
    p_geom geometry
)
    returns tpv
as $$
select (
    ST_Force2D(
        ST_Transform(
            p_geom,
            3857
        )
    ),
    0,
    0,
    0,
    to_timestamp(0),
    null,
    null
) :: tpv
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( geometry as tpv );
create cast ( geometry as tpv )
with function _tpv_from_geometry(geometry);

create or replace function _tpvarray_from_geometry(
    p_geom geometry
)
    returns tpv []
as $$
select array_agg(
    (
        ST_Force2D(z.geom),
        0,
        0,
        0,
        to_timestamp(ST_Z(z.geom)),
        null,
        null
    ) :: tpv
)
from ST_DumpPoints(
         ST_Transform(
             p_geom,
             3857
         )
     ) z
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( geometry as tpv [] );
create cast ( geometry as tpv [] )
with function _tpvarray_from_geometry(geometry);


create or replace function _tpv_from_geography(
    p_geom geography
)
    returns tpv
as $$
select (
    ST_Force2D(
        ST_Transform(
            p_geom :: geometry,
            3857
        )
    ),
    0,
    0,
    0,
    to_timestamp(0),
    null,
    null
) :: tpv
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( geography as tpv );
create cast ( geography as tpv )
with function _tpv_from_geography(geography);


create or replace function _geometry_from_tpv(
    p_tpv tpv
)
    returns geometry
as $$
select p_tpv.geom
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( tpv as geometry );
create cast ( tpv as geometry )
with function _geometry_from_tpv(tpv);


create or replace function _geography_from_tpv(
    p_tpv tpv
)
    returns geography
as $$
select ST_Transform(p_tpv.geom, 4326) :: geography
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( tpv as geography );
create cast ( tpv as geography )
with function _geography_from_tpv(tpv);


create or replace function _geometry_from_tpvarray(
    p_tpv tpv []
)
    returns geometry
as $$
select ST_MakeLine(
    geom
order by ts
)
from unnest(p_tpv) as t
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( tpv [] as geometry );
create cast ( tpv [] as geometry )
with function _geometry_from_tpvarray(tpv []);


create or replace function _geography_from_tpvarray(
    p_tpv tpv []
)
    returns geography
as $$
select ST_Transform(
    ST_MakeLine(
        geom
    order by ts
    ),
    4326
) :: geography
from unnest(p_tpv) as t
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( tpv [] as geography );
create cast ( tpv [] as geography )
with function _geography_from_tpvarray(tpv []);


create or replace function _tpvarray_from_jsonb(
    p_jsonb jsonb
)
    returns tpv []
as $$
select
    array((select
        (
            ST_Transform(
                ST_SetSRID(
                    ST_MakePoint(
                        (p_tpv ->> 'lon') :: float,
                        (p_tpv ->> 'lat') :: float
                    ),
                    4326
                ),
                3857
            ),
            p_tpv ->> 'acc',
            p_tpv ->> 'hdg',
            p_tpv ->> 'spd',
            to_timestamp((p_tpv ->> 'ts') :: float / 1000),
            p_tpv ->> 'src',
            p_tpv ->> 'osm_id'
        ) :: tpv
        from
            jsonb_array_elements(p_jsonb) as p_tpv
    )) :: tpv []
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( jsonb as tpv [] );
create cast ( jsonb as tpv [] )
with function _tpvarray_from_jsonb(jsonb);


create or replace function _jsonb_from_tpv(
    p_tpv tpv
)
    returns jsonb
as $$
select jsonb_build_object(
    'lon', ST_X(p_tpv :: geography :: geometry),
    'lat', ST_Y(p_tpv :: geography :: geometry),
    'acc', p_tpv.accuracy,
    'hdg', p_tpv.heading,
    'spd', p_tpv.speed,
    'ts', extract(epoch from p_tpv.ts) * 1000.,
    'src', p_tpv.source,
    'osm_id', p_tpv.osm_id
)
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( tpv as jsonb );
create cast ( tpv as jsonb )
with function _jsonb_from_tpv(tpv);

create or replace function ST_Distance(
    p_tpv_1 tpv,
    p_tpv_2 tpv
)
    returns float
as $$
select ST_Distance(
    p_tpv_1 :: geography,
    p_tpv_2 :: geography
)
$$ language 'sql' immutable strict parallel safe;

create or replace function _jsonb_from_tpvarray(
    p_tpvarray tpv []
)
    returns jsonb
as $$
select jsonb_agg(
    jsonb_build_object(
        'lon', ST_X(p_tpv :: geography :: geometry),
        'lat', ST_Y(p_tpv :: geography :: geometry),
        'acc', p_tpv.accuracy,
        'hdg', p_tpv.heading,
        'spd', p_tpv.speed,
        'ts', extract(epoch from p_tpv.ts) * 1000.,
        'src', p_tpv.source,
        'osm_id', p_tpv.osm_id
    )
)
from unnest(p_tpvarray) p_tpv
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( tpv [] as jsonb );
create cast ( tpv [] as jsonb )
with function _jsonb_from_tpvarray(tpv []);

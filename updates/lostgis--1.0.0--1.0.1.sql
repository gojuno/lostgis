
create or replace function _jsonb_from_tpvarray(
    p_tpvarray tpv []
)
    returns jsonb
as $$
select jsonb_strip_nulls(
    jsonb_agg(
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
)
from unnest(p_tpvarray) p_tpv
$$ language 'sql' immutable strict parallel safe;

drop cast if exists ( tpv [] as jsonb );
create cast ( tpv [] as jsonb )
with function _jsonb_from_tpvarray(tpv []);

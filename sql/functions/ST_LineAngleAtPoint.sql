create or replace function ST_LineAngleAtPoint(
    point geometry,
    line  geometry,
    delta float default 1
)
    returns float
as $$
declare
    posititon float;
    length    float;
begin
    posititon = ST_LineLocatePoint(line, point);
    length = ST_Length(line);
    return ST_Azimuth(
        ST_LineInterpolatePoint(line, greatest(posititon - delta / 2 / length, 0)),
        ST_LineInterpolatePoint(line, least(posititon + delta / 2 / length, 1))
    );
end
$$ language 'plpgsql' immutable strict parallel safe;

create or replace function ST_LineAngleAtPointD(
    point geometry,
    line  geometry,
    delta float default 1
)
    returns float
as $$
select degrees(ST_LineAngleAtPoint(point, line, delta));
$$ language 'sql' immutable strict parallel safe;

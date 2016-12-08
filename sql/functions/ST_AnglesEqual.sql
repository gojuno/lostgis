create or replace function angle_delta(
    angle1 float,
    angle2 float
)
    returns float
as $$
select acos(least(greatest((cos(angle1) * cos(angle2) + sin(angle1) * sin(angle2)), -1), 1));
$$ language 'sql' immutable strict parallel safe;

create or replace function angle_deltad(
    angle1 float,
    angle2 float
)
    returns float
as $$
select acosd(least(greatest((cosd(angle1) * cosd(angle2) + sind(angle1) * sind(angle2)), -1), 1));
$$ language 'sql' immutable strict parallel safe;

create or replace function ST_AnglesEqual(
    angle1 float,
    angle2 float,
    oneway boolean,
    delta  float default pi() / 4
)
    returns boolean
as $$
begin
    angle1 = angle_delta(angle1, angle2);

    if not oneway
    then
        if angle1 > (pi() / 2)
        then
            angle1 = pi() - angle1;
        end if;
    end if;
    return angle1 < delta;
end;
$$ language 'plpgsql' immutable strict parallel safe;

create or replace function ST_AnglesEqualD(
    angle1 float,
    angle2 float,
    oneway boolean,
    delta  float default 45
)
    returns boolean
as $$
begin
    angle1 = angle_deltad(angle1, angle2);

    if not oneway
    then
        if angle1 > 90
        then
            angle1 = 180 - angle1;
        end if;
    end if;
    return angle1 < delta;
end;
$$ language 'plpgsql' immutable strict parallel safe;
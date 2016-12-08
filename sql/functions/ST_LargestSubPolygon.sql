create or replace function ST_LargestSubPolygon(geom geometry)
returns geometry as
$$
begin
    if not ST_IsCollection(geom) then
        return geom;
    end if;
    return (select * from (select (ST_Dump(geom)).geom g) p order by ST_Area(g) desc limit 1);
end
$$
language 'plpgsql' immutable strict;
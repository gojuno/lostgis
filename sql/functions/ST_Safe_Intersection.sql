create or replace function ST_Safe_Intersection(
    geom_a           geometry,
    geom_b           geometry default null,
    message          text default '[unspecified]',
    grid_granularity double precision default 1
)
    returns geometry as
$$
begin
    if geom_b is null
    then
        raise notice 'ST_Safe_Intersection: second geometry is NULL (%)', message;
        return geom_b;
    end if;
    return
    ST_Safe_Repair(
        ST_Intersection(
            geom_a,
            geom_b
        )
    );
    exception
    when others
        then
            begin
                raise notice 'ST_Safe_Intersection: making everything valid (%)', message;
                return
                ST_Translate(
                    ST_Safe_Repair(
                        ST_Intersection(
                            ST_Safe_Repair(ST_Translate(geom_a, -ST_XMin(geom_a), -ST_YMin(geom_a))),
                            ST_Safe_Repair(ST_Translate(geom_b, -ST_XMin(geom_a), -ST_YMin(geom_a)))
                        )
                    ),
                    ST_XMin(geom_a),
                    ST_YMin(geom_a)
                );
                exception
                when others
                    then
                        begin
                            raise notice 'ST_Safe_Intersection: buffering everything (%)', message;
                            return
                            ST_Safe_Repair(
                                ST_Intersection(
                                    ST_Buffer(
                                        geom_a,
                                        0.4 * grid_granularity
                                    ),
                                    ST_Buffer(
                                        geom_b,
                                        -0.4 * grid_granularity
                                    )
                                )
                            );
                            exception
                            when others
                                then
                                    raise exception 'ST_Safe_Intersection: everything failed (%)', message;
                        end;
            end;
end
$$
language 'plpgsql' immutable parallel safe;

-- optimized version of this cast exists in commercially supported build by Postgres Professional (http://pgostgrespro.ru/)
do $$
begin
    create cast ( jsonb as float )
    with inout as implicit;
    exception when others
    then
end;
$$;

-- optimized version of this cast exists in commercially supported build by Postgres Professional (http://pgostgrespro.ru/)
do $$
begin
    create cast ( jsonb as numeric )
    with inout as implicit;
    exception when others
    then
end;
$$;

do $$
begin
    create cast ( jsonb as bigint )
    with inout as implicit;
    exception when others
    then
end;
$$;

do $$
begin
    create cast ( jsonb as real )
    with inout as implicit;
    exception when others
    then
end;
$$;
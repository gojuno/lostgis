drop type if exists opening_hours cascade;
create type opening_hours as (
    human_readable text,
    is_24          boolean,
    is_valid       boolean,
    week_mask      bit(10080)
);

create or replace function _opening_hours_from_text(
    txt text
)
    returns opening_hours
as $$
declare
    oh           opening_hours;
    tmp_oh       opening_hours;
    token        text;
    arr          text [];
    minute       int;
    weekday      int;
    day_mask     bit(10080);
    weekday_mask bit(8);
begin
    txt = trim(txt);
    oh.human_readable = txt;
    oh.is_24 = false;
    oh.is_valid = false;
    begin
        if txt = '24/7'
        then -- 24/7 simplest case ever
            oh.is_24 = true;
            oh.is_valid = true;
        elseif txt not like '%;%'
            then -- single interval set
                oh.week_mask = '0' :: bit(10080);
                day_mask = '0' :: bit(10080);
                weekday_mask = '0' :: bit(8);
                for token in (select regexp_split_to_table(txt, '[\s|,]')) loop
                    if token ~ '\d.*'
                    then -- if it starts from digit, it's a time intervals group
                        if token like '%-%'
                        then
                            arr = regexp_split_to_array(token, '[-|:]');
                            for minute in (
                                select generate_series(
                                    60 * arr [1] :: int + arr [2] :: int,
                                    greatest(-- 14:00-15:00 shouldn't include 15:00 but 14:00-14:00 should include 14:00
                                        (60 * arr [3] :: int + arr [4] :: int) - 1,
                                        60 * arr [1] :: int + arr [2] :: int
                                    )
                                )
                            ) loop
                                day_mask = set_bit(day_mask, minute, 1);
                            end loop;
                        else
                            raise exception 'not implemented';
                        end if;
                    else -- it's weekday
                        token = replace(
                            replace(replace(replace(replace(replace(replace(token, 'Mo', '1'), 'Tu', '2'), 'We', '3'),
                                                    'Th', '4'), 'Fr', '5'), 'Sa', '6'), 'Su', '7');
                        if token like '%-%'
                        then
                            arr = regexp_split_to_array(token, '[-]');
                            for weekday in (select generate_series(arr [1] :: char :: int, arr [2] :: char :: int)) loop
                                weekday_mask = set_bit(weekday_mask, weekday, 1);
                            end loop;
                        else
                            weekday_mask = set_bit(weekday_mask, token :: char :: int, 1);
                        end if;
                    end if;
                end loop;

                for weekday in (select generate_series(1, 7)) loop
                    if get_bit(weekday_mask, weekday)
                    then
                        oh.week_mask = oh.week_mask | (day_mask >> (1440 * (weekday - 1)));
                    end if;
                end loop;

                oh.is_valid = true;
        else -- multiple interval set - a combination of singles
            oh.week_mask = '0' :: bit(10080);
            oh.is_valid = true;
            oh.is_24 = false;
            for token in (select regexp_split_to_table(txt, '[;]')) loop
                tmp_oh = _opening_hours_from_text(token);
                oh.is_valid = oh.is_valid and tmp_oh.is_valid;
                oh.week_mask = oh.week_mask | tmp_oh.week_mask;
            end loop;
        end if;
        exception when others
        then end;
    return oh;
end;
$$ language plpgsql immutable strict parallel safe;

drop cast if exists ( text as opening_hours );
create cast ( text as opening_hours )
with function _opening_hours_from_text(text);


create function _opening_hours_from_timestamp(
    ts timestamp
)
    returns opening_hours as $$
select to_char(ts, 'Dy HH24:MM-HH24:MM') :: text :: opening_hours;
$$ language sql immutable strict parallel safe;

drop cast if exists ( timestamp as opening_hours );
create cast ( timestamp as opening_hours )
with function _opening_hours_from_timestamp(timestamp);

create or replace function overlaps(oh1 opening_hours, oh2 opening_hours)
    returns boolean as $$
begin
    if not (oh1.is_valid or oh2.is_valid)
    then
        return false;
    end if;

    if oh1.is_24 or oh2.is_24
    then
        return true;
    end if;

    if (oh1.week_mask & oh2.week_mask) != ('0' :: bit(10080))
    then
        return true;
    end if;

    return false;
end;
$$ language plpgsql immutable strict parallel safe;

create or replace function overlaps(oh1 opening_hours, ts timestamp)
    returns boolean as $$
select oh1.is_24 or overlaps (oh1, ts :: opening_hours);
$$ language sql immutable strict parallel safe;

create or replace function overlaps(ts timestamp, oh1 opening_hours)
    returns boolean as $$
select oh1.is_24 or overlaps (oh1, ts :: opening_hours);
$$ language sql immutable strict parallel safe;

create or replace function contains(oh1 opening_hours, ts timestamp)
    returns boolean as $$
select oh1.is_24 or overlaps (oh1, ts :: opening_hours);
$$ language sql immutable strict parallel safe;

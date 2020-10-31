set nocount on
use aoc2015
go
/*
use aoc2015
go

-- */

drop table if exists #raw
create table #raw (s varchar(100))

-- test data
/*
insert into #raw 
values
('.#.#.#'),
('...##.'),
('#....#'),
('..#...'),
('#.#..#'),
('####..')
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day18.txt'

declare @c int
select @c = count(*) from #raw

drop table if exists #data

;with 
	cte_n0 as (select item n from dbo.fn_split('0,1,2,3,4,5,6,7,8,9',',')),
	cte_n as (select 10 * x1.n + x0.n n from cte_n0 x0, cte_n0 x1)
select 0 as step, n x, y, case when xy = '#' then 1 else 0 end as isOn, 
	cast(null as int) as prev_nOn,
	cast(null as int) as prev_On
into #data 
from (select row_number() over (order by (select null)) -1 y, s from #raw) as r 
join cte_n n
	on n < @c
outer apply (select substring(r.s,n+1,1) xy ) x

update d
set ison = 1
from #data d
where 
	(x=0 and y=0)
or	(x=0 and y=@c-1)
or	(x=@c-1 and y=0)
or	(x=@c-1 and y=@c-1)

set @c = 0
while @c < 100
begin

	raiserror ('working on pass %d',0,0,@c) with nowait
	
/*
A light which is on stays on when 2 or 3 neighbors are on, and turns off otherwise.
A light which is off turns on if exactly 3 neighbors are on, and stays off otherwise.	
*or*
	3 neighbours on -> ON
	2 neighbours on -> State Unchanged
	-> OFF
A light in the corner (has 3 neighbours) always ON
*/
	insert into #data
	select @c + 1, d.x, d.y,
		case isCorner 
			when 1
				then 1
			else case n.nOn
				when 3 then 1
				when 2 then d.isOn
				else 0 end
			end,
				d.isOn,
			n.non
	from #data d
	outer apply (
		select	sum (isOn) nOn, 
				case when count(*) = 3 then 1 else 0 end as isCorner  -- only the Corners have 3 neighbours
		from #data n 
		where 
			n.step = @c
		    and n.y between d.y - 1  and d.y + 1
			and n.x between d.x - 1  and d.x + 1
			and not (n.x = d.x and n.y = d.y) ) as n
	where step = @c	

	set @c = @c + 1

end

-- test data result
select count(*) from #data 
where isOn = 1
and step = 5

select count(*) from #data 
where step = 100 
and isOn = 1


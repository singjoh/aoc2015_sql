set nocount on
use aoc2015
go
/*
use aoc2015
go

-- */

drop table if exists #raw
create table #raw (s varchar(max))

-- test data
/*
insert into #raw 
values 
('Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.'),
('Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.')
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day14.txt'

drop table if exists #data
select s, 
		max(case when id = 1 then item else null end) as name,
		max(case when id = 4 then cast(item as int) else null end) as speed,
		max(case when id = 7 then cast(item as int) else null end) as travel,
		max(case when id = 14 then caST(item as int) else null end) as rest
into #data
from #raw
cross apply dbo.fn_split(s,' ')
group by s

declare @time int = 2503

-- part 1
/*
select name, 
		speed * travel * full_cycles +
		speed * case when time_left > travel then travel else time_left end
from
  (select name, speed, travel, rest,  @time / (travel + rest) full_cycles, @time % (travel + rest) time_left
  from #data) as x
order by 2 desc
-- */

-- part2
drop table if exists #breakdown

;with cte_0 as (select item n from dbo.fn_split('0,1,2,3,4,5,6,7,8,9',',')),
 cte_numbers as (
	select cast(a0.n + a1.n * 10 + a2.n * 100 + a3.n * 1e3 + a4.n * 1e4 as int) n from cte_0 a0,cte_0 a1,cte_0 a2,cte_0 a3,cte_0 a4
 )
select name, n, speed * travel * full_cycles + speed * case when time_left > travel then travel else time_left end dist
into #breakdown
from cte_numbers n
outer apply (
	select name, speed, travel, rest,  n / (travel + rest) full_cycles, cast(n as int) % (travel + rest) time_left from #data
	) as x
where n between 1 and 2503
order by n

select name, count(*) 
from (select n, max(dist) dist from #breakdown group by n) as mx
join #breakdown b
	on b.n = mx.n
	and b.dist = mx.dist
group by name
order by 2 desc
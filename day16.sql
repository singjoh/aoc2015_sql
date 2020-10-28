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
('Sue 1: goldfish: 6, trees: 9, akitas: 0'),
('Sue 2: goldfish: 7, trees: 1, akitas: 0'),
('Sue 3: cars: 10, akitas: 6, perfumes: 7')
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day16.txt'

drop table if exists #data
select s, 
		max(case when id = 2 then cast(substring(item,1,len(item)-1) as int) else null end) as sid,
		max(case when id = 3 then substring(item,1,len(item)-1) else null end) as item1,
		max(case when id = 4 then cast(substring(item,1,len(item)-1) as int) else null end) as val1,
		max(case when id = 5 then substring(item,1,len(item)-1) else null end) as item2,
		max(case when id = 6 then cast(substring(item,1,len(item)-1) as int) else null end) as val2,
		max(case when id = 7 then substring(item,1,len(item)-1) else null end) as item3,
		max(case when id = 8 then cast(item as int) else null end) as val3
into #data
from #raw
cross apply dbo.fn_split(s,' ')
group by s

drop table if exists #list
select * into #list
from 
(
	select sid, item1 item, val1 val from #data
	union
	select sid, item2, val2 from #data
	union
	select sid, item3, val3 from #data
) as x

drop table if exists #req
create table #req (item varchar(32), val int)
insert into #req	
values
	('children',3),
	('cats',7),
	('samoyeds',2),
	('pomeranians',3),
	('akitas',0),
	('vizslas',0),
	('goldfish',5),
	('trees',3),
	('cars',2),
	('perfumes',1)

-- part 1
select top 10 sid, count(*)
from #req r
join #list l
	on l.item = r.item
	and l.val = r.val
group by sid
order by 2 desc

-- part  2
select top 10 sid, count(*)
from #req r
join #list l
	on l.item = r.item
	and 1 = 
		case when l.item in ('cats','trees')
				then case when l.val > r.val then 1 else 0 end
			 when l.item in ('pomeranians','goldfish')
				then case when l.val < r.val then 1 else 0 end
			 else case when l.val = r.val then 1 else 0 end
		end
group by sid
order by 2 desc

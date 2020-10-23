set nocount on
use aoc2015
go
/*
use aoc2015
go

-- */

drop table if exists #raw
create table #raw (s varchar(max))

/*
-- test data
insert into #raw 
values 
('London to Dublin = 464'),
('London to Belfast = 518'),
('Dublin to Belfast = 141')
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day9.txt'

drop table if exists #data
select s, 
		max(case when id = 1 then item else null end) as startlocn,
		max(case when id = 3 then item else null end) as endlocn,
		max(case when id = 5 then cast(item as int) else null end) as dist
into #data
from #raw
cross apply dbo.fn_split(s,' ')
group by s

drop table if exists #locn
select * into #locn
from ( 
	select distinct startlocn as locn from #data
	union 
	select distinct endlocn from #data
	) as x

drop table if exists #paths
create table #paths (pathlen int, lastlocn varchar(64), locns varchar(max), dist int)

-- start locations
insert into #paths 
select 0, locn, locn,  0
from #locn 

declare @pathlen int, @locns int
set @pathlen = (select max(pathlen) from #paths)
set @locns = (select count(*) from #locn) - 1
while @pathlen < @locns
begin
	insert into #paths
	select @pathlen + 1, l.locn, p.locns + ',' + l.locn, p.dist + d.dist
	from #paths p
	join #locn l
		on p.locns not like '%' + l.locn + '%'
	outer apply (
		select top 1 * from #data
		where (startlocn = p.lastlocn and endlocn = l.locn)
			or (endlocn = p.lastlocn and startlocn = l.locn)
	) as d
	where pathlen = @pathlen

	set @pathlen = @pathlen + 1
end

select * from #paths

select min(dist) from #paths where pathlen = @pathlen

select max(dist) from #paths where pathlen = 7


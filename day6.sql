set nocount on

drop table if exists #raw
create table #raw (s varchar(max))

/*
-- part 1 test dta
insert into #raw 
values 
('turn on 0,0 through 999,999'),
('toggle 0,0 through 999,0'),
('turn off 499,499 through 500,500')
-- */
/*
-- part 2 test data
insert into #raw 
values 
('turn on 0,0 through 0,0'),
('toggle 0,0 through 999,999')
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day6.txt'


-- parse the instructions
drop table if exists #op
create table #op (opid int identity (1,1), op varchar(3), x0 int, y0 int, x1 int, y1 int)

insert into #op (op, x0,y0,x1,y1)
select op, xy0.x, xy0.y, xy1.x, xy1.y 
from #raw
outer apply (select case SUBSTRING(s,1,7) when 'toggle ' then 'TOG' when 'turn on' then 'TON' else 'TOF' end as op) as op
outer apply (select case op when 'TOG' then 8 when 'TON' then 9 else 10 end as c) as r0_start
outer apply (select SUBSTRING(s,r0_start.c,CHARINDEX('through',s) - r0_start.c - 1) as r0 ) as r0
outer apply (select SUBSTRING(s,CHARINDEX('through',s) + 8,8) as r1) as r1
outer apply (select SUBSTRING(r0.r0,1,CHARINDEX(',',r0.r0)-1) as x,SUBSTRING(r0.r0,CHARINDEX(',',r0.r0)+1,3) as y ) as xy0 
outer apply (select SUBSTRING(r1.r1,1,CHARINDEX(',',r1.r1)-1) as x,SUBSTRING(r1.r1,CHARINDEX(',',r1.r1)+1,3) as y ) as xy1

-- build the start table
/*
drop table if exists #data
create table #data (x int, y int, isOn int)
create index i_xy on #data (x,y)

drop table if exists #pivot
select n into #pivot from (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as d(n)

insert into #data
select  x0.n + 10 * x1.n + 100 * x2.n, y0.n + 10 * y1.n + 100 * y2.n, 0
from #pivot x0
cross join #pivot x1
cross join #pivot x2
cross join #pivot y0
cross join #pivot y1
cross join #pivot y2 
-- */

declare @opid int, @maxopid int
select @opid = 0, @maxopid = max(opid) from #op

/*
-- part 1
while @opid < @maxopid
begin
	set @opid = @opid + 1
	raiserror(N'Working on Op %d',0,0,@opid) with nowait

	update d
	set isOn = case op.op
				when 'TON' then 1
				when 'TOF' then 0
				else 1 - isOn
				end
	from #op op
	join #data d
		on d.x between op.x0 and op.x1
		and d.y between op.y0 and op.y1
	where opid = @opid

end

select count(*) from #data where ison = 1
 --*/

-- part 2
update #data set IsOn = 0

while @opid < @maxopid
begin
	set @opid = @opid + 1
	raiserror(N'Working on Op %d',0,0,@opid) with nowait

	update d
	set isOn = case op.op
				when 'TON' then isOn + 1
				when 'TOF' then 
					case when isOn > 0 then isOn - 1 else 0 end
				else isOn + 2
				end
	from #op op
	join #data d
		on d.x between op.x0 and op.x1
		and d.y between op.y0 and op.y1
	where opid = @opid

end

select sum(ison) from #data




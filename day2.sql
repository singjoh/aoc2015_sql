drop table if exists #raw
create table #raw (dim varchar(256))

drop table if exists #data
create table #data (rownum int identity(1,1), h int, w int, l int, longside varchar(1))

bulk insert #raw from 'C:\Users\John\Documents\SQL Server Management Studio\Aoc2015\day2.txt'

/*
-- test data
insert into #raw
values ('2x3x4'),('1x1x10') 
-- */

insert into #data (h,w,l,longside)
select d.*, case when h = long.l then 'h' when w = long.l then 'w' else 'l' end
from #raw r
outer apply (select CHARINDEX('x',dim) c) x0
outer apply (select CHARINDEX('x',dim,x0.c+1) c) x1
outer apply (select cast(SUBSTRING(dim,1,x0.c-1) as int) h, cast(SUBSTRING(dim,x0.c+1,x1.c-x0.c-1) as int) w , cast(SUBSTRING(dim,x1.c+1,100) as int) l) d
outer apply (select max(x) l from (values (h),(w),(l)) as d(x)) as long

select sum(paper), sum(ribbon)
from (
	select *,
		2 * h * w + 2 * h * l + 2 * w * l +
		case longside
			when 'h' then l * w
			when 'l' then h * w
			else l * h
		end as paper,
		h * w * l + 
		case longside
			when 'h' then 2 * (l + w)
			when 'l' then 2 * (h + w)
			else 2 * (l + h)
		end as ribbon
	from #data 
	) as x
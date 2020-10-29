set nocount on
use aoc2015
go
/*
use aoc2015
go

-- */

drop table if exists #raw
create table #raw (sz int)

-- test data
/*
insert into #raw 
values
(20), (15), (10), (5), (5)
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day17.txt'

drop table if exists #jugs
select char( ASCII('a') -1 + ROW_NUMBER() over (order by sz)) id,
	   sz vol
into #jugs
from #raw

select * from #jugs

drop table if exists #comb
create table #comb
	(lvl int, comb varchar(32), vol int)

declare @lvl int = 1, @rowcnt int, @jugs int , @target int
select @jugs = count(*) from #jugs
set @target =150


-- first set
insert into #comb
select 1, id, vol
from #jugs

set @rowcnt = @@ROWCOUNT

while @lvl < @jugs and @rowcnt > 0
begin
	set @lvl = @lvl + 1

	raiserror('working on lvl %d',0,0,@lvl) with nowait

	insert into #comb
	select @lvl, comb + id, c.vol + j.vol 
	from #comb c
	join #jugs j	
		on charindex(j.id, c.comb) = 0 
		and j.id > right(c.comb,1) -- only one pattern, incrementing sizes 
		and j.vol <= @target - c.vol
	where c.lvl = @lvl - 1

	set @rowcnt = @@ROWCOUNT	
end

-- part 1
select count(*) from #comb
where vol = @target

-- part2
select count(*) 
from #comb c
join (select min(len(comb)) mn from #comb where vol = @target) as x
	on len(comb) = x.mn
where vol = @target



set nocount on

use aoc2015
go
/*
use aoc2015
go


alter function day24_qefromwlist
	(@input varchar(max))
returns float
as
begin
	-- declare @input varchar(max) = '_1_,_8_,_11_'

	declare @ptotal float = 1

	select @ptotal =
		case
		   WHEN MinVal = 0 THEN 0
		   WHEN Neg % 2 = 1 THEN -1 * EXP(ABSMult)
		   ELSE EXP(ABSMult)
		end
	from
		(   select
			   --log of +ve row values
			   SUM(LOG(ABS(NULLIF(n, 0)))) AS ABSMult,
			   --count of -ve values. Even = +ve result.
			   SUM(SIGN(CASE WHEN n < 0 THEN 1 ELSE 0 END)) AS Neg,
			   --anything * zero = zero
			   MIN(ABS(n)) AS MinVal
			from dbo.fn_split(@input,',') x
			outer apply (select SUBSTRING(item,2,len(item)-2) n) y
		) foo

	return @ptotal
end

-- */

drop table if exists #raw
create table #raw (s varchar(100))

--test data
/*
insert into #raw 
select item from dbo.fn_split('1,2,3,4,5,7,8,9,10,11',',') 
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day24.txt'

drop table if exists #data

select cast(s as int) w, '_' + cast(s as varchar(max)) + '_' wid
into #data
from #raw

declare @target int
declare @items int

declare @locs int = 4 -- part1 = 3

select @target = sum(w) / @locs, @items = count(*) from #data

drop table if exists #results
create table #results
	(c int, wlist varchar(max), wtotal int, lastw int)

insert into #results
select 1, wid , w, w from #data

declare @c int = 1


-- rather than check *all* groups combinations (n^3, where n ~ 200K), just assume that smallset groups that add to target will have some combination of  balanced remains
-- then choose the minimum qe for anything with minimun group size
-- (and then we'll check that other groups exists, maybe another day)

while 1=1
begin
	set @c = @c + 1

	raiserror('Building baskets of size %d',0,0,@c) with nowait

	insert into #results
	select @c, r.wlist + ',' + wid, r.wtotal + d.w, d.w
	from #results r
	join #data d
		on CHARINDEX(wid, r.wlist) = 0
		and d.w > r.lastw
	where r.wtotal + d.w <= @target
	and r.c = @c -1

	if @@ROWCOUNT = 0 break

	if exists (select 1 from #results where c = @c and wtotal = @target) break

end

delete from #results where wtotal <> @target

declare @cmin int
select @cmin = min(c) from #results

select top 10 r0.c, r0.wlist wlist,  dbo.day24_qefromwlist(wlist)
from #results r0
where r0.c = @cmin
order by 3 asc


/*
-- result checker ... maybe another day
declare @wlist varchar(max) = '_1_,_83_,_101_,_103_,_107_,_113_'
select top 1 * 
from #results r
join #results r2
	on r2.c = @items - r.c + @cmin
where not exists (select 1 from dbo.fn_split( @wlist,',') where charindex(item,r2.wlist) > 0 )
and not exists (select 1 from dbo.fn_split( @wlist,',') where charindex(item,r2.wlist) > 0 )
*/

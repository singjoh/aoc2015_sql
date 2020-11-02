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
('H => HO'),
('H => OH'),
('O => HH'),
('e => H'),
('e => O')
--*/

-- real data
 bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day19.txt'

drop table if exists #data

select	rown id, 
		max(case when x.id = 1 then x.item else null end) a,
		max(case when x.id = 3 then x.item else null end) b
into #data
from (
	select row_number() over (order by (select null)) as rown, s 
	from #raw
	) as r
outer apply dbo.fn_split(r.s,' ') x
group by r.rown

--declare @orig varchar(max) = 'HOHOHO' 
 declare @orig varchar(max) = 
	'CRnSiRnCaPTiMgYCaPTiRnFArSiThFArCaSiThSiThPBCaCaSiRnSiRnTiTiMgArPBCaPMgYPTiRnFArFArCaSiRnBPMgArPRnCaPTiRnFArCaSiThCaCaFArPBCaCaPTiTiRnFArCaSiRnSiAlYSiThRnFArArCaSiRnBFArCaCaSiRnSiThCaCaCaFYCaPTiBCaSiThCaSiThPMgArSiRnCaPBFYCaCaFArCaCaCaCaSiThCaSiRnPRnFArPBSiThPRnFArSiRnMgArCaFYFArCaSiRnSiAlArTiTiTiTiTiTiTiRnPMgArPTiTiTiBSiRnSiAlArTiTiRnPMgArCaFYBPBPTiRnSiRnMgArSiThCaFArCaSiThFArPRnFArCaSiRnTiBSiThSiRnSiAlYCaFArPRnFArSiThCaFArCaCaSiThCaCaCaSiRnPRnCaFArFYPMgArCaPBCaPBSiRnFYPBCaFArCaSiAl'
--	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
--  0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7


-- part 1
drop table if exists #results
;with 
	cte_n0 as (select item n from dbo.fn_split('0,1,2,3,4,5,6,7,8,9',',')),
	cte_n as (select 100 * x2.n + 10 * x1.n + x0.n n from cte_n0 x0, cte_n0 x1, cte_n0 x2)
select a,b, substring(@orig,1,n) + b + substring(@orig,n+1+len(a),1000) as ns
into #results
from cte_n n
cross join #data d
outer apply (select case when n.n + len(d.a) <= len(@orig) then n.n else null end c ) c -- does orig have enough for a substring starting at n
outer apply (select substring(@orig,n+1,len(a)) as snippit) x
where n.n <= len(@orig) 
and c.c is not null
and snippit = d.a COLLATE Latin1_General_CS_AS -- CASE SENSITIVE !!
order by n, d.a

select count(distinct ns) from #results


-- part 2

-- took waaayyy too long on a brute force method, trying to build the molecule up from scratch
-- so switched to a split the molecle down, using the largest chunks first
-- (possible that may not result in the answer and then need to choose the chunks in a more random way) 
-- ... but the simple solution actually produced an answer

declare @c int = 0
declare @s varchar(max) = @orig
while @c < 500
begin

	set @c = @c + 1

	-- try a greedy removal, take out the biggest chunks first ...
	-- 
	select top 1 @s = substring(@s,1,n-1) + a + substring(@s,n+len(d.b),1000)
	from #data d
	outer apply (select CHARINDEX(b, @s COLLATE Latin1_General_CS_AS) n) as x
	where n > 0
	order by len(b) desc

	if @@ROWCOUNT = 0 break

	raiserror('pass %d, molecule now %s',0,0,@c,@s) with nowait

end


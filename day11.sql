set nocount on
use aoc2015
go
/*
use aoc2015
go



-- */
declare @nextcharstr varchar(30) = 'abcdefghjklmnpqrstuvwxyza'

declare @input varchar(8) = 'cqjxxyzz'

declare @cnt int = 0
declare @pos int = 8
declare @nextc varchar

drop table if exists #triplet;
with cte_0 as (select item n from dbo.fn_split('0,1,2,3,4,5,6,7,8,9',',')),
	 cte_10 as (select 0 n union select 1 union select 2),
	 cte_25 as (select cte_0.n + cte_10.n * 10 as n from cte_0, cte_10 )
select CHAR(ASCII('a') + x.n) + CHAR(ASCII('a') + x.n + 1) + CHAR(ASCII('a') + x.n + 2)  
	triplet 
into #triplet
from cte_25 x
where n <= 23 -- ('x')

drop table if exists #pair;
with cte_0 as (select item n from dbo.fn_split('0,1,2,3,4,5,6,7,8,9',',')),
	 cte_10 as (select 0 n union select 1 union select 2),
	 cte_25 as (select cte_0.n + cte_10.n * 10 as n from cte_0, cte_10 )
select CHAR(ASCII('a') + x.n) + CHAR(ASCII('a') + x.n)  
	pair 
into #pair
from cte_25 x
where n <= 25 -- ('x')

delete from #pair where pair like '%i%' or pair like '%l%' or pair like '%o%'

declare @found bit = 0

while @found = 0
begin
	set @cnt = @cnt + 1

	set @nextc = substring(@nextcharstr,CHARINDEX(substring(@input,@pos,1),@nextcharstr)+1,1)
	set @input = stuff(@input,@pos,1,@nextc)
	while @nextc = 'a'
	begin
		set @pos = @pos - 1
		set @nextc = substring(@nextcharstr,CHARINDEX(substring(@input,@pos,1),@nextcharstr)+1,1)
		set @input = stuff(@input,@pos,1,@nextc)
	end

	set @pos = 8

	if exists (select 1 from #triplet where @input like '%' + triplet + '%')
	begin
		raiserror(@input,0,0) with nowait
		raiserror('---- Has triplet',0,0) with nowait
		if exists (
			select 1 from #pair p, #pair q
			where @input like '%' + p.pair + '%'
			and @input like '%' + q.pair + '%'
			and p.pair <> q.pair)
			begin
				raiserror('---- Has two pairs',0,0) with nowait
				set @found = 1
			end
	end
end



drop table if exists #pivot
select n into #pivot from (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as d(n)

declare @input varchar(8) = 'yzbqklnj'

declare @mn  varbinary(max), @mx  varbinary(max)
-- part 1
--set @mn = 0x000000
--set @mx = 0x00000F
-- part 2
set @mn = 0x00000000
set @mx = 0x000000FF

select * from 
(
	-- a little note on optimisation ... cast(i as varchar) will switch to 1e6 notation by default
	-- FORMAT() can be used to prevent this, but its slow
	-- so we use cast on lower and upper parts
	select x.msb * 1e4 + x.lsb as c, HashBytes('MD5', @input + cast(msb as varchar(4)) + cast(lsb as varchar(4))) md5
	from #pivot p0
	cross join #pivot p1
	cross join #pivot p2
	cross join #pivot p3
	cross join #pivot p4
	cross join #pivot p5
	cross join #pivot p6

 ) as x
where md5 between @mn and @mx
order by c


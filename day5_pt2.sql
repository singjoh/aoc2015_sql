use aoc2015
go
/*
create function day5_vowelcount_doubleletter_isNaughty(@input varchar(max)) returns bit 
as
begin
	declare @c int = 0
	declare @thisc varchar 
	declare @lastc varchar 
	declare @double bit = 0
	declare @vowel_c int = 0

	set @c = 0
	while @c < len(@input)
	begin
		set @c = @c + 1
		set @thisc = SUBSTRING(@input,@c,1)
		if @thisc in ('a','e','i','o','u')
			set @vowel_c = @vowel_c + 1
		if @thisc = @lastc
			set @double = 1
		if @double = 1 and @vowel_c >= 3
			return 0
		set @lastc = @thisc
	end
	return 1

end
-- */

go
drop table if exists #raw
create table #raw (s varchar(max))

bulk insert #raw from 'C:\Users\John\Documents\SQL Server Management Studio\Aoc2015\day5.txt'

/*
insert into #raw
values 
('qjhvhtzxzqqjkmpb'), -- is nice because is has a pair that appears twice (qj) and a letter that repeats with exactly one letter between them (zxz).
('xxyxx'), -- is nice because it has a pair that appears twice and a letter that repeats with one between, even though the letters used by each rule overlap.
('uurcxstgmygtbstg'), -- is naughty because it has a pair (tg) but no repeat with a single letter between them.
('ieodomkazucvgmuy'), -- is naughty because it has a repeating letter with one between (odo), but no pair that appears twice.
('xthhhqzwvqiyctvs')
--*/
/*
It contains a pair of any two letters that appears at least twice in the string without overlapping, like xyxy (xy) or aabcdefgaa (aa), but not like aaa (aa, but it overlaps).
It contains at least one letter which repeats with exactly one letter between them, like xyx, abcdefeghi (efe), or even aaa.
*/

drop table if exists #data
create table #data (s varchar(max), isNaughty bit)

insert into #data (s) select s from #raw

drop table if exists #letters
select c into #letters 
from (values 
	('a'),('b'),('c'),('d'),('e'),('f'),('g'),('h'),('i'),('j'),('k'),('l'),('m'),
	('n'),('o'),('p'),('q'),('r'),('s'),('t'),('u'),('v'),('w'),('x'),('y'),('z')
	) as x(c)

update d
set isNaughty =  case when xyx.s is not null and xyxy.s is not null then 0 else 1 end
from #data d
-- has a xyx pattern
left join (
	select distinct(s) s
	from #data d
	join #letters l
		on d.s like '%' + l.c + '_' + l.c + '%'
) as xyx
	on xyx.s = d.s
-- has a xyabcxy pattern
left join (
	select distinct(s) s
	from #data
	join (values 
		(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16)
		) as x(n)
		on x.n < len(s)
	outer apply (select substring(s,n,2) as snippit) as y
	outer apply (select CHARINDEX(snippit,s,n+1) as n) as z
	where z.n > x.n + 1
) as xyxy
	on xyxy.s = d.s
	
select isNaughty, count(*) from #data
group by isNaughty


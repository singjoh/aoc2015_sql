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
('ugknbfddgicrmopn'), -- is nice because it has at least three vowels (u...i...o...), a double letter (...dd...), and none of the disallowed substrings.
('aaa'), -- is nice because it has at least three vowels and a double letter, even though the letters used by different rules overlap.
('jchzalrnumimnmhp'), -- is naughty because it has no double letter.
('haegwjzuvuyypxyu'), -- is naughty because it contains the string xy.
('dvszwmarrgswjxmb') --is naughty because it contains only one vowel.
--*/

	
drop table if exists #data
create table #data (s varchar(max), isNaughty bit)

insert into #data (s) select s from #raw

-- does not include ab, cd, pq, or xy
update d
set isNaughty = 1
from #data d
where s like '%ab%' or s like '%cd%' or s like '%pq%' or s like '%xy%'

update d
set isNaughty = dbo.day5_vowelcount_doubleletter_isNaughty(s) 
from #data d
where isNaughty is null

select isNaughty, count(*) from #data
group by isNaughty

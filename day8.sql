set nocount on
use aoc2015
go
/*
use aoc2015
go

CREATE FUNCTION dbo.day8_countchars
(
   @input VARCHAR(MAX)
)
RETURNS int
AS
BEGIN
	declare @pos int = 0
	declare @ccnt int = 0
	declare @escaped varchar(8) = null
	declare @this varchar(1) = null

	while @pos < len(@input)
	begin
		set @pos = @pos + 1
		set @this = SUBSTRING(@input,@pos,1)
		if @escaped is not null
		begin
			if @this in ('\','"') 
			begin
				set @escaped = null
				set @ccnt = @ccnt + 1
			end
			else if @this = 'x' and @escaped = '\'
				set @escaped = @escaped + @this
			else if left(@escaped,2) = '\x' 
			begin
				if len(@escaped) < 4
					set @escaped = @escaped + @this
				else			
					set @ccnt = @ccnt + 1
			end
		end
		else
		begin
			if @this = '\'
				set @escaped = @this
			else if @this <> '"' -- ignore double quotes
				set @ccnt = @ccnt + 1
		end
	end

	return @ccnt
END
GO

CREATE FUNCTION dbo.day8_extended_notation
(
   @input VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	declare @pos int = 0
	declare @output varchar(max) = ''
	declare @escaped varchar(8) = null
	declare @this varchar(1) = null

	while @pos < len(@input)
	begin
		set @pos = @pos + 1
		set @this = SUBSTRING(@input,@pos,1)

		if @escaped is not null
		begin
			if @this in ('\','"') 
			begin
				set @escaped = null
				set @output = @output + '\\\' + @this
			end
			else if @this = 'x' and @escaped = '\'
				set @escaped = @escaped + @this
			else if left(@escaped,2) = '\x' 
			begin
				if len(@escaped) < 3
					set @escaped = @escaped + @this
				else
				begin
					set @output = @output + '\' + @escaped + @this
					set @escaped = null
				end
			end
		end
		else
		begin
			if @this = '\'
				set @escaped = @this
			else if @this = '"'
				set @output = @output + '\"'
			else 
				set @output = @output + @this
		end
	end

	set @output = '"' + @output + '"'
	return @output
END
GO


-- */

drop table if exists #raw
create table #raw (s varchar(max))

/*
-- test data
insert into #raw 
values 
('""'), -- is 2 characters of code (the two double quotes), but the string contains zero characters.
('"abc"'), -- is 5 characters of code, but 3 characters in the string data.
('"aaa\"aaa"'), --  is 10 characters of code, but the string itself contains six "a" characters and a single, escaped quote character, for a total of 7 characters in the string data.
('"\x27"') --  is 6 characters of code, but the string itself contains just one - an apostrophe ('), escaped using hexadecimal notation.
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day8.txt'

drop table if exists #data
select *
into #data
from #raw
outer apply (select dbo.day8_countchars(s) reallen) as x

select sum(len(s)) - sum(reallen) part1 from #data



/*(
"" encodes to "\"\"", an increase from 2 characters to 6.
"abc" encodes to "\"abc\"", an increase from 5 characters to 9.
"aaa\"aaa" encodes to "\"aaa\\\"aaa\"", an increase from 10 characters to 16.
"\x27" encodes to "\"\\x27\"", an increase from 6 characters to 11.
*/

drop table if exists #data2
select *
into #data2
from #raw
outer apply (select dbo.day8_extended_notation(s) extended_s) as x

--select *, len(s), len(extended_s) from #data2

select sum(len(extended_s)) - sum(len(s)) from #data2

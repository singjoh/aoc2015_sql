set nocount on
use aoc2015
go

drop table if exists #results
create table #results(stepid int, slen int, s varchar(max)) 

declare @cnt int = 40
declare @iter int = 0
declare @len int
declare @input varchar(MAX) = '1113122113'

insert into #results values(@iter, @len, @input)
raiserror('step %d, len %d: %s',0,0,@iter,@len,@input) with nowait

while @iter < @cnt
begin
	set @iter = @iter + 1
	set @input = dbo.day10_lookandsee(@input)
	set @len = len(@input)
	insert into #results values(@iter, @len, @input)
	raiserror('step %d, len %d: %s',0,0,@iter,@len,@input) with nowait
end
select len(@input)

-- too slow for SQL for part 2, could consider breaking into 'elements'
set nocount on

use aoc2015
go
/*

-- */


declare @row int = 2947
declare @col int = 3029

declare @code bigint = 20151125 

declare @n int = @row + @col - 2
declare @iter int = (@n * (@n + 1)) / 2 + @col - 1

declare @i int = 0

while @i < @iter
begin
	set @i = @i + 1
	if @i % 100000 = 0 
		raiserror ('Working on row %d',0,0,@i) with nowait

	set @code = @code * 252533 % 33554393
end

select @code


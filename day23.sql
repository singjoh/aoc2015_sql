set nocount on

use aoc2015
go
/*
use aoc2015
go

-- */

drop table if exists #raw
create table #raw (s varchar(100))

--test data
 /*
insert into #raw 
values
('inc a'),
('jio a, +2'),
('tpl a'),
('inc a')
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day23.txt'

drop table if exists #data

select	rown id, 
		max(case when x.id = 1 then x.item else null end) instr,
		max(case when x.id = 2 then replace(x.item,',','') else null end) register, -- get rid of comms in this
		max(case when x.id = 3 then cast(x.item as int) else null end) offset

into #data
from (
	select row_number() over (order by (select null)) as rown, s 
	from #raw
	) as r
outer apply dbo.fn_split(r.s,' ') x
group by r.rown

update #data
set register = null, 
	offset = cast(register as int)
where instr = 'jmp'

select * from #data

declare @pos int = 1
declare @a bigint = 1
declare @b bigint = 0
declare @msg varchar(max)

while 1=1
begin

	set @msg = '[' + cast(@a as varchar(max)) + ',' + cast(@b as varchar(max)) + ']'
	raiserror('Next instruct: %d.  Registers %s',0,0,@pos, @msg)


	select  @pos = @pos + case 
				when instr in ('hlf','tpl','inc') then 1
				when instr = 'jmp' then offset
				when instr = 'jie' then
					case 
						when register = 'a' and @a % 2 = 0 then offset
						when register = 'b' and @b % 2 = 0 then offset
						else 1 -- not specified ... but we must move the pointer if the jump fails
					end 
				when instr = 'jio' then
					case 
						when register = 'a' and @a = 1 then offset
						when register = 'b' and @b = 1 then offset
						else 1 -- not specified ... but we must move the pointer if the jump fails
					end 
				end,
			@a = case 
				when instr = 'hlf' and register = 'a' then @a / 2
				when instr = 'tpl' and register = 'a' then @a * 3
				when instr = 'inc' and register = 'a' then @a + 1
				else @a
				end,
			@b = case 
				when instr = 'hlf' and register = 'b' then @b / 2
				when instr = 'tpl' and register = 'b' then @b * 3
				when instr = 'inc' and register = 'b' then @b + 1
				else @b
				end
	from #data
	where id = @pos


	if @pos <= 0 or @pos > (select max(id) from #data) break
end

set @msg = '[' + cast(@a as varchar(max)) + ',' + cast(@b as varchar(max)) + ']'
raiserror('Complete. Registers %s',0,0, @msg)

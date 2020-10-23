set nocount on
use aoc2015
go
/*
use aoc2015
go

CREATE FUNCTION dbo.fn_split
(
   @List NVARCHAR(MAX),
   @Delimiter NVARCHAR(255)
)
RETURNS TABLE
WITH SCHEMABINDING AS
RETURN
  WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
       E4(N)        AS (SELECT 1 FROM E2 a, E2 b),
       E42(N)       AS (SELECT 1 FROM E4 a, E2 b),
       cteTally(N)  AS (SELECT 0 UNION ALL SELECT TOP (LEN(ISNULL(@List,1))) 
                         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E42),
       cteStart(N1) AS (SELECT t.N+1 FROM cteTally t
                         WHERE (SUBSTRING(@List,t.N,1) = @Delimiter OR t.N = 0))

  SELECT	Id = ROW_NUMBER() OVER (ORDER BY ((SELECT NULL))), 
			Item = SUBSTRING(@List, s.N1, ISNULL(NULLIF(CHARINDEX(@Delimiter,@List,s.N1),0)-s.N1,8000))
    FROM cteStart s;
GO

-- */




drop table if exists #raw
create table #raw (s varchar(max))

/*
-- part 1 test data
insert into #raw 
values 
('123 -> x'),
('456 -> y'),
('x AND y -> d'),
('x OR y -> e'),
('x LSHIFT 2 -> f'),
('y RSHIFT 2 -> g'),
('NOT x -> h'),
('NOT y -> i')
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day7.txt'


-- parse the instructions
drop table if exists #op
create table #op (opid int identity (1,1), op varchar(6), iput0 varchar(8), iput1 varchar(8), wname varchar(2))

drop table if exists #wires
create table #wires (wiredid int identity (1,1), wname varchar(2), signal int)

drop table if exists #rawsplit
select s, 
	max(case when id = 1 then Item else null end) word1,
	max(case when id = 2 then Item else null end) word2,
	max(case when id = 3 then Item else null end) word3,
	max(case when id = 4 then Item else null end) word4,
	max(case when id = 5 then Item else null end) word5
into #rawsplit
from #raw r
cross apply dbo.fn_split(s,' ') 
group by s

insert into #wires (wname, signal)
select word3, cast(word1 as int)
from #rawsplit
where word2 = '->'
and isnumeric(word1) = 1

insert into #op (op, iput0, wname)
select 'COPY', word1, word3
from #rawsplit
where word2 = '->'
and isnumeric(word1) = 0

insert into #op (op, iput0, wname)
select word1, word2, word4
from #rawsplit
where word1 = 'NOT'

insert into #op (op, iput0, iput1, wname)
select word2, word1, word3, word5
from #rawsplit
where not word1 = 'NOT'
and not word2 = '->'

-- possible dummy wires where the input has a value
insert into #wires (wname, signal)
select  Word2, cast(Word2 as int)
from #rawsplit
where word1 = 'NOT'
and ISNUMERIC(Word2) = 1
union
select  word1, cast(word1 as int)
from #rawsplit
where not word1 = 'NOT'
and not word2 = '->'
and ISNUMERIC(Word1) = 1
union
select  word3, cast(word3 as int)
from #rawsplit
where not word1 = 'NOT'
and not word2 = '->'
and ISNUMERIC(Word3) = 1

-- handle the trivial (NOT) case
-- loop until this is empty
declare @cnt int

select @cnt = count(*) 
from #op o
left join #wires wo
	on wo.wname = o.wname
where wo.wname is null

while @cnt > 0
begin

	raiserror('current cnt=%d',0,0,@cnt) with nowait

	-- Handle NOT and COPY (singleto inpuy 
	insert into #wires (wname, signal)
	select o.wname, case op when 'NOT' then 65535 - w.signal else w.signal end -- dbo.BitWiseNotInt16(w.signal)  
	from #op o
	join #wires w
		on w.wname = o.iput0
	left join #wires wo
		on wo.wname = o.wname
	where op in ( 'NOT','COPY')
	and wo.wname is null -- ignore the filled wires

	insert into #wires (wname, signal)
	select o.wname,
		case op 
		when 'AND' then w0.signal & w1.signal
		when 'OR' then w0.signal | w1.signal
		when 'LSHIFT' then w0.signal*power(2,w1.signal) & 65535
		when 'RSHIFT' then w0.signal/cast(power(2,w1.signal) as int)
		end
	from #op o
	join #wires w0
		on w0.wname = o.iput0
	join #wires w1
		on w1.wname = o.iput1
	left join #wires wo
		on wo.wname = o.wname
	where op not in ( 'NOT','COPY')
	and wo.wname is null -- ignore the filled wires

	select @cnt = count(*) 
	from #op o
	left join #wires wo
		on wo.wname = o.wname
	where wo.wname is null
end

declare @part1 int
select @part1 = signal from #wires
where wname = 'a'

raiserror('part 1 result = %d',0,0,@part1) with nowait

-----------------------------------------------
-- Part 2

-- reset all wires
-- copy a signal into b
-- load up other hard wires
-- rerun
truncate table #wires

insert into #wires (wname, signal)
select word3, cast(word1 as int)
from #rawsplit
where word2 = '->'
and isnumeric(word1) = 1

-- possible dummy wires where the input has a value
insert into #wires (wname, signal)
select  Word2, cast(Word2 as int)
from #rawsplit
where word1 = 'NOT'
and ISNUMERIC(Word2) = 1
union
select  word1, cast(word1 as int)
from #rawsplit
where not word1 = 'NOT'
and not word2 = '->'
and ISNUMERIC(Word1) = 1
union
select  word3, cast(word3 as int)
from #rawsplit
where not word1 = 'NOT'
and not word2 = '->'
and ISNUMERIC(Word3) = 1

if exists (select 1 from #wires where wname = 'b')
	update #wires set signal = @part1 where wname = 'b'
else
	insert into #wires (wname, signal)
	values('b', @part1)

-- declare @cnt int
select @cnt = count(*) 
from #op o
left join #wires wo
	on wo.wname = o.wname
where wo.wname is null

while @cnt > 0
begin

	raiserror('current cnt=%d',0,0,@cnt) with nowait

	-- Handle NOT and COPY (singleto inpuy 
	insert into #wires (wname, signal)
	select o.wname, case op when 'NOT' then 65535 - w.signal else w.signal end -- dbo.BitWiseNotInt16(w.signal)  
	from #op o
	join #wires w
		on w.wname = o.iput0
	left join #wires wo
		on wo.wname = o.wname
	where op in ( 'NOT','COPY')
	and wo.wname is null -- ignore the filled wires

	insert into #wires (wname, signal)
	select o.wname,
		case op 
		when 'AND' then w0.signal & w1.signal
		when 'OR' then w0.signal | w1.signal
		when 'LSHIFT' then (w0.signal*power(2,w1.signal)) & 65535
		when 'RSHIFT' then w0.signal/cast(power(2,w1.signal) as int)
		end
	from #op o
	join #wires w0
		on w0.wname = o.iput0
	join #wires w1
		on w1.wname = o.iput1
	left join #wires wo
		on wo.wname = o.wname
	where op not in ( 'NOT','COPY')
	and wo.wname is null -- ignore the filled wires

	select @cnt = count(*) 
	from #op o
	left join #wires wo
		on wo.wname = o.wname
	where wo.wname is null
end

declare @part2 int
select @part2 = signal from #wires
where wname = 'a'

raiserror('part 1 result = %d',0,0,@part1) with nowait

raiserror('part 2 result = %d',0,0,@part2) with nowait

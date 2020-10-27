set nocount on
use aoc2015
go
/*
use aoc2015
go

-- */

drop table if exists #raw
create table #raw (s varchar(max))

/*
-- test data
insert into #raw 
values 
('Alice would gain 54 happiness units by sitting next to Bob.'),
('Alice would lose 79 happiness units by sitting next to Carol.'),
('Alice would lose 2 happiness units by sitting next to David.'),
('Bob would gain 83 happiness units by sitting next to Alice.'),
('Bob would lose 7 happiness units by sitting next to Carol.'),
('Bob would lose 63 happiness units by sitting next to David.'),
('Carol would lose 62 happiness units by sitting next to Alice.'),
('Carol would gain 60 happiness units by sitting next to Bob.'),
('Carol would gain 55 happiness units by sitting next to David.'),
('David would gain 46 happiness units by sitting next to Alice.'),
('David would lose 7 happiness units by sitting next to Bob.'),
('David would gain 41 happiness units by sitting next to Carol.')
--*/

-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2015\day13.txt'

drop table if exists #data
select s, 
		max(case when id = 1 then item else null end) as name1,
		max(case when id = 3 and item = 'gain' then 1 else -1 end) *
		max(case when id = 4 then cast(item as int) else null end) as happiness,
		max(case when id = 11 then item else null end) as name2
into #data
from #raw
cross apply dbo.fn_split(s,' ')
group by s

update #data
set name2 = substring(name2,1,len(name2)-1)

declare @part2 bit = 1
if @part2 = 1
begin

	insert into #data
	select distinct name1 + ' would not care if sat next to me', name1, 0, 'me'
	from #data
	union
	select distinct 'I would not care if sat next to ' + name1, 'me', 0, name1
	from #data


end


drop table if exists #names
select row_number() over (order by name1) id, name1 name
into #names
from (select distinct name1 from #data) d

drop table if exists #links
select n1.id n1id, n2.id n2id, happiness
into #links
from #data d
join #names n1
	on n1.name = d.name1
join #names n2
	on n2.name = d.name2

drop table if exists #combs
select 2 guest_c, n1.name + ',' + n2.name as comb
into #combs
from #names n1
join #names n2
	on n2.id <> n1.id
and n1.name = 'Alice'

declare @c int = 2
while @c < (select count(*) from #names)
begin
	set @c = @c + 1
	insert into #combs
	select @c, c.comb + ',' + n.name
	from #combs c
	join #names n
		on CHARINDEX(n.name,comb) < 1
	where c.guest_c = @c - 1	
end

delete c
from #combs c
where c.guest_c < (select max(guest_c) from #combs)

drop table if exists #companions
select comb, x.item name,  
	isnull(lag(x.item) over (partition by comb order by x.id),x2.Item) lhs, 
	isnull(lead(x.item) over (partition by comb order by x.id),x1.Item) rhs
into #companions
from #combs c
outer apply dbo.fn_split(comb,',') x
outer apply dbo.fn_split(comb,',') x1
outer apply dbo.fn_split(comb,',') x2
where x1.id = 1
and x2.id = (select count(*) from #names)

select comb, sum(llhs.happiness) + sum(lrhs.happiness)
from #companions c
join #names n
	on n.name = c.name
join #names nlhs
	on nlhs.name = c.lhs
join #names nrhs
	on nrhs.name = c.rhs
join #links llhs
	on llhs.n1id = n.id
	and llhs.n2id = nlhs.id
join #links lrhs
	on lrhs.n1id = n.id
	and lrhs.n2id = nrhs.id
group by comb
order by 2 desc



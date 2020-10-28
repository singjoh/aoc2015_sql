set nocount on
use aoc2015
go
/*
use aoc2015
go

-- */

drop table if exists #raw
create table #raw (s varchar(max))

-- test data
/*
insert into #raw 
values 
('Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8'),
('Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3')
--*/

-- real data
insert into #raw 
values 
('Sprinkles: capacity 5, durability -1, flavor 0, texture 0, calories 5'),
('PeanutButter: capacity -1, durability 3, flavor 0, texture 0, calories 1'),
('Frosting: capacity 0, durability -1, flavor 4, texture 0, calories 6'),
('Sugar: capacity -1, durability 0, flavor 0, texture 2, calories 8')

update #raw set s = replace(s,',','') 

drop table if exists #data
select ROW_NUMBER() over (order by s) rownum,
		s, 
		max(case when id = 1 then item else null end) as name,
		max(case when id = 3 then cast(item as int) else null end) as capacity,
		max(case when id = 5 then cast(item as int) else null end) as durability,
		max(case when id = 7 then caST(item as int) else null end) as flavor,
		max(case when id = 9 then caST(item as int) else null end) as texture,
		max(case when id = 11 then caST(item as int) else null end) as calories
into #data
from #raw
cross apply dbo.fn_split(s,' ')
group by s

drop table if exists #teaspoons

;with cte_0 as (select item n from dbo.fn_split('0,1,2,3,4,5,6,7,8,9',',')),
 cte_numbers as (
	select cast(a0.n + a1.n * 10 + a2.n * 100 as int) n from cte_0 a0,cte_0 a1,cte_0 a2
 )
select * into #teaspoons
from cte_numbers
where n <= 100

select * from #data

-- first ingredient
drop table if exists #comb
select 1 item_c, cast(name + cast(n as varchar(3))as varchar(max)) as recipe, 
	n * capacity capacity, 
	n * durability durability, 
	n * flavor flavor, 
	n * texture texture, 
	n * calories calories,
	100 - n remaining_n
into #comb
from #data d
cross join #teaspoons
where d.rownum = 1

declare @maxrownum int, @rownum int

select @maxrownum = max(rownum) - 1, @rownum = 1 from #data

while @rownum < @maxrownum
begin
	set @rownum = @rownum + 1

	insert into #comb
	select @rownum, recipe + ' ' + name + cast(t.n as varchar(3)), 
		c.capacity + t.n * d.capacity, 
		c.durability + t.n * d.durability, 
		c.flavor + t.n * d.flavor, 
		c.texture + t.n * d.texture, 
		c.calories + t.n * d.calories,
		c.remaining_n - t.n
	from #data d
	join #comb c
		on c.item_c = @rownum - 1
	join #teaspoons t
		on t.n <= c.remaining_n
	where d.rownum = @rownum

end

-- last ingredient
insert into #comb
select mx.rownum, recipe + ' ' + name + cast(remaining_n as varchar(3)), 
	c.capacity + remaining_n * d.capacity, 
	c.durability + remaining_n * d.durability, 
	c.flavor + remaining_n * d.flavor, 
	c.texture + remaining_n * d.texture, 
	c.calories + remaining_n * d.calories,
	0 
from #data d
join (select max(rownum) rownum from #data) mx
	on d.rownum = mx.rownum
join #comb c
	on c.item_c = mx.rownum - 1
where d.rownum = (select max(rownum) from #data)

-- part 1
select top 10 recipe, capacity * durability * flavor * texture
from #comb d
where d.item_c = (select max(rownum) from #data)
and capacity >= 0  
and durability >= 0 
and flavor >= 0
and texture >= 0  
order by 2 desc

-- part 2
select top 10 recipe, capacity * durability * flavor * texture
from #comb d
where d.item_c = (select max(rownum) from #data)
and capacity >= 0  
and durability >= 0 
and flavor >= 0
and texture >= 0  
and calories = 500
order by 2 desc
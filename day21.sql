set nocount on

use aoc2015
go
/*
use aoc2015
go

-- */

drop table if exists #items
create table #items (itype varchar(16), name varchar(16), cost int, damage int, armour int)
insert into #items
values
('weapon','Dagger',       8,     4,       0),
('weapon','Shortsword',  10,     5,       0),
('weapon','Warhammer',   25,     6,       0),
('weapon','Longsword',    40,    7,       0),
('weapon','Greataxe',     74,     8,       0),
('armour','Leather',      13,     0,       1),
('armour','Chainmail',    31,     0,       2),
('armour','Splintmail',   53,     0,       3),
('armour','Bandedmail',   75,     0,       4),
('armour','Platemail',   102,     0,       5),
('ring','Damage +1',    25,     1,       0),
('ring','Damage +2',    50,     2,       0),
('ring','Damage +3',   100,     3,       0),
('ring','Defense +1',   20,     0,       1),
('ring','Defense +2',   40,     0,       2),
('ring','Defense +3',   80,     0,       3)

declare @boss_hp int = 104
declare @boss_damage int = 8
declare @boss_armour int = 1

declare @my_hp int = 100 


-- simulation
/*
declare @boss_hp int = 12
declare @boss_damage int = 7
declare @boss_armour int = 2

declare @my_hp int = 8
declare @my_damage int = 5
declare @my_armour int = 5

declare @boss_hp int = 104
declare @boss_damage int = 8
declare @boss_armour int = 1

declare @my_hp int = 100
declare @my_damage int = 7
declare @my_armour int = 2

while @my_hp > 0 and @boss_hp > 0
begin
	-- my move
	if @my_damage > @boss_armour
		set @boss_hp = @boss_hp + @boss_armour - @my_damage
	else
		set @boss_hp = @boss_hp - 1

	raiserror('My move, boss HP=%d',0,0,@boss_hp)
	if @boss_hp <= 0 break

	-- boss move
	if @boss_damage > @my_armour
		set @my_hp = @my_hp + @my_armour - @boss_damage
	else
		set @my_hp = @my_hp - 1

	raiserror('Boss move, my HP=%d',0,0,@my_hp)

end
-- */

-- build a table of all armour combos
drop table if exists #setup
select cast(name as varchar(max)) as setup, cost, damage, armour
into #setup
from #items w
where w.itype = 'weapon'

insert into #setup
select setup + ',' + name, w.cost + s.cost, w.damage + s.damage, w.armour + s.armour
from #items w
cross join #setup s
where w.itype = 'armour'

insert into #setup
select setup + ',' + name, w.cost + s.cost, w.damage + s.damage, w.armour + s.armour
from #items w
cross join #setup s
where w.itype = 'ring'

insert into #setup
select setup + ',' + name, w.cost + s.cost, w.damage + s.damage, w.armour + s.armour
from #items w
join #setup s
	on CHARINDEX(w.name, s.setup) = 0
where w.itype = 'ring'

--part 1
select top 10 *, --setup, cost, turns_to_kill_boss, turns_to_kill_me, 
@boss_hp - turns_to_kill_boss * my_attack boss_end_hp, @my_hp - turns_to_kill_me * boss_attack my_end_hp
from (
	select setup, cost, damage, armour, 
			ceiling(@boss_hp / cast(my_attack as float)) turns_to_kill_boss, 
			ceiling(@my_hp / cast(boss_attack as float)) turns_to_kill_me, my_attack, boss_attack 
	from #setup s
	outer apply (
		select 
		case when damage > @boss_armour then damage - @boss_armour else 1 end my_attack,
		case when @boss_damage > armour then @boss_damage - armour else 1 end boss_attack
	) as x
) as x
where turns_to_kill_me >= turns_to_kill_boss
order by cost 

--part 2
select top 10 *, --setup, cost, turns_to_kill_boss, turns_to_kill_me, 
@boss_hp - turns_to_kill_boss * my_attack boss_end_hp, @my_hp - turns_to_kill_me * boss_attack my_end_hp
from (
	select setup, cost, damage, armour, 
			ceiling(@boss_hp / cast(my_attack as float)) turns_to_kill_boss, 
			ceiling(@my_hp / cast(boss_attack as float)) turns_to_kill_me, my_attack, boss_attack 
	from #setup s
	outer apply (
		select 
		case when damage > @boss_armour then damage - @boss_armour else 1 end my_attack,
		case when @boss_damage > armour then @boss_damage - armour else 1 end boss_attack
	) as x
) as x
where turns_to_kill_me < turns_to_kill_boss
order by cost desc

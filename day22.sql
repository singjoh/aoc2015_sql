set nocount on

use aoc2015
go
/*
use aoc2015
go

-- */

drop table if exists #spells
create table #spells (spell varchar(16), mana int, damage int, heal int, turns int, armour int, newmana int)
insert into #spells
values
('Missile',53,  4,0,0,0,0),
('Drain', 73,   2,2,0,0,0),
('Shield', 113, 0,0,6,7,0),
('Poison', 173, 3,0,6,0,0),
('Recharge',229,0,0,5,0,101)

declare @boss_hp int = 55
declare @boss_damage int = 8

declare @my_hp int = 50
declare @my_mana int = 500

drop table if exists #fight
create table #fight
 (id int identity(1,1), turn int, spell varchar(8), pid int, stime int, ptime int, rtime int, bosshp int, myhp int, mymana int, totalmana int) 


-- used for checkiig a particular sequence
drop table if exists #fightplan
create table #fightplan
 (turn int, spell varchar(8))

-- test  1
/*
insert into #fightplan
values
	(1,'poison'),
	(2, 'missile')

set @boss_hp = 13
set @boss_damage = 8

set @my_hp = 10
set @my_mana = 250
-- */
-- test 2 
/*
insert into #fightplan
values
	(1,'Recharge'),
	(2, 'Shield'),
	(3, 'Drain'),
	(4, 'Poison'),
	(5, 'Missile')

set @boss_hp = 14
set @boss_damage = 8

set @my_hp = 10
set @my_mana = 250
-- */

truncate table #fight
insert into #fight (turn, pid, stime, ptime, rtime, bosshp, myhp, mymana,totalmana)
values (0, null, 0, 0, 0, @boss_hp, @my_hp, @my_mana, 0)

declare @mymove bit = 1
declare @turn int = 0

declare @rowcount int = 0

-- set to 0 for part one result
declare @parttwo int = 1

--while @my_hp > 0 and @boss_hp > 0
while @turn < 21 -- seems to be all over by 17 turns, add a few more in case a slightly longer plan results in lower mana
begin
	set @turn = @turn + 1
	raiserror('Processing turn %d',0,0,@turn) with nowait
	if @mymove = 1
	begin
		
		insert into #fight (spell, turn, pid, stime, ptime, rtime, bosshp, myhp, mymana, totalmana)
		select s.spell, @turn, f.id, 
			case when s.spell = 'shield' then s.turns when f.stime > 0 then f.stime - 1 else 0 end,
			case when s.spell = 'poison' then s.turns when f.ptime > 0 then f.ptime - 1 else 0 end,
			case when s.spell = 'recharge' then s.turns when f.rtime > 0 then f.rtime - 1 else 0 end,
			f.bosshp
			  -	case when s.turns = 0 then s.damage else 0 end -- immediate damage
			  -	case when f.ptime > 0 then sp.damage else 0 end, -- poison (event) damage
			f.myhp
			  + s.heal
			  - @parttwo, -- lose a hit point if part two
			f.mymana
			  +	case when f.rtime > 0 then sr.newmana else 0 end
			  - s.mana,
			f.totalmana + s.mana
		from #spells s
		join #spells sp on sp.spell = 'poison'
		join #spells sr on sr.spell = 'recharge'
		left join #fight f-- look for all previous spells, that is 
			on f.turn = @turn - 1
		where f.mymana >= s.mana
		and f.myhp > @parttwo -- do not continue if myhp was 1
		and f.bosshp > 0
		and case s.spell	
			when 'shield' then case when f.stime <= 1 then 1 else 0 end 
			when 'poison' then case when f.ptime <= 1 then 1 else 0 end 
			when 'recharge' then case when f.rtime <= 1 then 1 else 0 end 
			else 1
			end = 1 

		if @@ROWCOUNT = 0 break

	end
	else
	begin
		-- bosses move
	
		insert into #fight (spell, turn, pid, stime, ptime, rtime, bosshp, myhp, mymana, totalmana)
		select 'boss', @turn, f.id, 
			case when f.stime > 0 then f.stime - 1 else 0 end,
			case when f.ptime > 0 then f.ptime - 1 else 0 end,
			case when f.rtime > 0 then f.rtime - 1 else 0 end,
			f.bosshp
			  -	case when f.ptime > 0 then sp.damage else 0 end, -- poison (event) damage
			f.myhp
			  - case when @boss_damage > case when f.stime > 0 then ss.armour else 0 end
				then @boss_damage - case when f.stime > 0 then ss.armour else 0 end
				else 1 end,
			f.mymana
			  +	case when f.rtime > 0 then sr.newmana else 0 end,
			f.totalmana
		from #fight f-- look for all previous spells, that is 
		join #spells sp on sp.spell = 'poison'
		join #spells sr on sr.spell = 'recharge'
		join #spells ss on ss.spell = 'shield'
		where f.turn = @turn - 1
		and f.myhp > 0
		and f.bosshp > 0

		if @@ROWCOUNT = 0 break

	end
	set @mymove = 1 - @mymove
end

select @turn MaxTurnsUsed

-- review the test data
/*
;with cte_path as 
	(
		select row_number() over (order by f.id) attackid, f.id, f.pid from #fight f left join #fight fc on fc.pid = f.id where fc.pid is null
		union all
		select c.attackid, f.id, f.pid from #fight f join cte_path c on c.pid = f.id
	)
select f.*
from
	(
		select attackid, count(*) c
		from cte_path c
		join #fight f 
			on f.id = c.id 
		join #fightplan fp
			on fp.turn * 2 - 1 = f.turn
			and fp.spell = f.spell
		group by attackid
		having count(*) = (select count(*) from #fightplan)
	) as a
join cte_path c
	on c.attackid = a.attackid
join #fight f 
	on f.id = c.id 
	-- */

-- results
select top 10 * from #fight where bosshp <= 0 order by totalmana asc

-- review a fight
declare @id_end int = 106439
if @id_end is not null
begin
	;with cte_path as 
		(
			select f.id, f.pid from #fight f where f.id = @id_end
			union all
			select f.id, f.pid from #fight f join cte_path c on c.pid = f.id
		)
	select f.*
	from cte_path c
	join #fight f 
		on f.id = c.id 
	order by turn
end

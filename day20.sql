set nocount on

use aoc2015
go
/*
use aoc2015
go

-- */
declare @c int = 0
declare @f int
declare @fcomp int
declare @p int

-- part 1
while 1=0
begin
  set @c = @c + 1
  set @f = 1
  set @p = 0

  -- check for divisors up to sqrt(c)
  while @f <= sqrt(@c)
  begin
	
	if @c % @f = 0
		set @p = @p + 10 * @f
	-- and the complementary item (with come checks to ensure we don't get a repeated item)
	if @c % @f = 0 and @f * @f != @c and @c / @f > @f
	begin
		set @fcomp = @c / @f
		set @p = @p + 10 * @fcomp
	end
    set @f = @f + 1

  end
  
  if @c % 1000 = 0 
	  raiserror('House %d gets %d',0,0,@c,@p) with nowait

  if @p >= 33100000
  begin
	  raiserror('House %d gets %d',0,0,@c,@p) with nowait
	  break
  end

end

-- part 2
while 1=1
begin
  set @c = @c + 1
  set @f = 1
  set @p = 0

  while @f <= sqrt(@c)
  begin
	if @c % @f = 0 and @c / @f <= 50
		set @p = @p + 11 * @f
	if @c % @f = 0 and @f * @f != @c and @c / @f > @f 
	begin
		set @fcomp = @c / @f
		if @c / @fcomp <= 50
			set @p = @p + 11 * @fcomp
	end
    set @f = @f + 1

  end
  
  if @c % 1000 = 0 
	  raiserror('House %d gets %d',0,0,@c,@p) with nowait

  if @p >= 33100000
  begin
	  raiserror('House %d gets %d',0,0,@c,@p) with nowait
	  break
  end

end

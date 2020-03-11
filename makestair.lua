function TryDig(Direction)
	local DigDir = turtle.digUp
	local CheckDir = turtle.detectUp
	if Direction == Forward then
		DigDir = turtle.dig
		CheckDir = turtle.detect
	elseif Direction == Down then
		DigDir = turtle.digDown
		CheckDir = turtle.detectDown
	end
	if not CheckDir() then
		return false
	end
	DigDir()
	while CheckDir() do
		if not DigDir() then
			return false
		end
	end
	return true
end

function TryMove(Direction)
	local MoveDir = turtle.up
	local CheckDir = turtle.detectUp
	local AttackDir = turtle.attackUp
	if Direction == Forward then
		MoveDir = turtle.forward
		CheckDir = turtle.detect
		AttackDir = turtle.attack
	elseif Direction == Down then
		MoveDir = turtle.down
		CheckDir = turtle.detectDown
		AttackDir = turtle.attackDown
	end

	local trycount = 0
	while trycount < 20 and not MoveDir() do
		if CheckDir() then
			if not TryDig(Direction) then
				print("Reached bedrock!")
				return false
			end
		elseif AttackDir() then
			while AttackDir() do end
		elseif turtle.getFuelLevel() == 0 then
			if not TryRefuel() then
				print("Ran out of fuel!")
				return false
			end
		end
		trycount = trycount + 1
	end
	if trycount < 20 then
		return true
	else
		return false
	end
end

function TryRefuel()

	turtle.select(1)
	local data = turtle.getItemDetail()
	if data then
		if(data.name == "minecraft:coal" or data.name == "minecraft:coal_block") then
			turtle.refuel(1)
			return true
		else
			print("slot 1 should have coal but has "..data.name)
			return false
		end
	end

	return false
	
end	

function CheckAction(testBool, fCall, fParam)
	if testBool then
		if fCall(fParam) then
			return true
		else
			Print("TryMove returned false")
		end
	end
	return false
end

function EnsureBlockBelow()
	if turtle.detectDown() then
		return true
	else
		turtle.select(2)
		if turtle.placeDown() then
			return true
		end
	end
	return false
end

function ClearSides()
	turtle.turnLeft()
	TryDig(Forward)
	turtle.turnRight()
	turtle.turnRight()
	TryDig(Forward)
	turtle.turnLeft()
end
print("Number of steps:")
local l = tonumber(read())

Up, Forward, Down = -1, 0, 1
local ok = true
while l > 0 and ok do
	ok = CheckAction(ok, TryMove, Up)
	ok = CheckAction(ok, TryMove, Up)
	ok = CheckAction(ok, TryMove, Up)
	ClearSides()
	ok = CheckAction(ok, TryMove, Down)
	ClearSides()
	ok = CheckAction(ok, TryMove, Down)
	ClearSides()
	ok = CheckAction(ok, TryMove, Down)
	ClearSides()
	ok = CheckAction(ok, TryMove, Down)
	ClearSides()
	ok = CheckAction(ok, EnsureBlockBelow)
	ok = CheckAction(ok, TryMove, Forward)
	l = l - 1
end
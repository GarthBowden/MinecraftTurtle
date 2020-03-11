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

function TryPlace(Direction, BlockType)
	local getBlockSlot = FindInventory(BlockType)
	if getBlockSlot then
		turtle.select(getBlockSlot)
	else
		return false
	end
	local PlaceDir = turtle.placeUp
	local CheckDir = turtle.detectUp
	local AttackDir = turtle.attackUp
	if Direction == Forward then
		CheckDir = turtle.detect
		PlaceDir = turtle.place
		AttackDir = turtle.attack
	elseif Direction == Down then
		CheckDir = turtle.detectDown
		PlaceDir = turtle.placeDown
		AttackDir = turtle.attackDown
	end
	local trycount = 0
	while trycount < 20 and not (CheckDir() or PlaceDir()) do
		trycount = trycount + 1
		while AttackDir() do end
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

function FindInventory(findItem)

	for i = 2,16 do
		turtle.select(i)
		local data = turtle.getItemDetail()
		if data then
			if(data.name == findItem) then
				return i
			end
		end
	end
end

function BottomRow(Parity)
	if Parity > 0 then 
		turtle.turnLeft()
	else
		turtle.turnRight()
	end
	if not TryPlace(Forward, "minecraft:netherrack") then return false end
	if not TryPlace(Down, "minecraft:netherrack") then return false end
	if Parity > 0 then 
		turtle.turnLeft()
		if not TryPlace(Forward, "minecraft:stone_slab") then return false end		
		turtle.turnLeft()
	else
		turtle.turnLeft()
		turtle.turnLeft()
	end
	if not TryMove(Forward) then return false end
	if not TryPlace(Down, "minecraft:netherrack") then return false end

	if Parity > 0 then
		turtle.turnRight()
		if not TryPlace(Forward, "minecraft:stone_slab") then return false end		
		turtle.turnLeft()
	end
	if not TryMove(Forward) then return false end
	if not TryPlace(Forward, "minecraft:netherrack") then return false end
	if not TryPlace(Down, "minecraft:netherrack") then return false end
	if Parity > 0 then
		turtle.turnRight()
		if not TryPlace(Forward, "minecraft:stone_slab") then return false end		
		turtle.turnLeft()
	end
	if Parity > 0 then 
		turtle.turnLeft()
	else
		turtle.turnRight()
	end
	
	return true
end

function SecondRow(Parity)
	if Parity > 0 then 
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
	if not TryPlace(Forward, "minecraft:netherrack") then return false end
	if Parity > 0 then 
		if not TryPlace(Down, "minecraft:stone_slab") then return false end
		turtle.turnLeft()
		turtle.turnLeft()
	else
		turtle.turnRight()
		turtle.turnRight()
	end
	if not TryMove(Forward) then return false end
	if Parity > 0 then
		if not TryPlace(Down, "minecraft:stone_slab") then return false end
	end
	if not TryMove(Forward) then return false end
	if Parity > 0 then
		if not TryPlace(Down, "minecraft:stone_slab") then return false end
	end
	if not TryPlace(Forward, "minecraft:netherrack") then
		return false
	end
	if Parity > 0 then 
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
	return true
end

function ThirdRow(Parity)
	if Parity > 0 then 
		turtle.turnLeft()
	else
		turtle.turnRight()
	end
	if not TryPlace(Forward, "minecraft:netherrack") then
		return false
	end
	if Parity > 0 then 
		turtle.turnRight()
		turtle.turnRight()
	else
		turtle.turnLeft()
		turtle.turnLeft()
	end
	if not TryMove(Forward) then
		return false
	end
	if not TryMove(Forward) then
		return false
	end
	if not TryPlace(Forward, "minecraft:netherrack") then
		return false
	end
	if Parity > 0 then 
		turtle.turnLeft()
	else
		turtle.turnRight()
	end
	
	return true
end

function TopRow(Parity)
	if Parity > 0 then 
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
	if not (TryPlace(Forward, "minecraft:netherrack") and TryPlace(Up, "minecraft:netherrack")) then
		return false
	end
	if Parity > 0 then 
		turtle.turnLeft()
		turtle.turnLeft()
	else
		turtle.turnRight()
		turtle.turnRight()
	end
	if not(TryMove(Forward) and TryPlace(Up, "minecraft:netherrack")) then
		return false
	end
	if not(TryMove(Forward) and TryPlace(Up, "minecraft:netherrack")) then
		return false
	end
	if not TryPlace(Forward, "minecraft:netherrack") then
		return false
	end
	if Parity > 0 then 
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
	return true
end
local tArgs = { ... }
if #tArgs ~= 1 then
	print( "Usage: netherpath <length>" )
	return
end
local size = tonumber( tArgs[1] )
if size < 1 then
	print( "Path distance must be positive" )
	return
end
Up, Forward, Down = -1, 0, 1
if not(turtle.turnLeft() and TryMove(Forward) and turtle.turnRight()) then
	return
end

local parity = 0
for l = 1,size do
	if parity == 0 then 
		parity = 1
	else
		parity = 0
	end
	if not TryMove(Forward) then
		break
	end
	if parity == 1 then
		if not BottomRow(parity) then break end
		if not TryMove(Up) then break end
		if not SecondRow(parity) then break end
		if not TryMove(Up) then break end
		if not ThirdRow(parity) then break end
		if not TryMove(Up) then break end
		if not TopRow(parity)then break end
	else
		if not TopRow(parity) then break end
		if not TryMove(Down) then break end
		if not ThirdRow(parity) then break end
		if not TryMove(Down) then break end
		if not SecondRow(parity) then break end
		if not TryMove(Down) then break end
		if not BottomRow(parity)then break end
	end
end
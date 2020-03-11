function LoopAdd(a, b, upperB) --# modulus on sum with result between 1 and upper bound
	local c = a + b
	if c > upperB then
		c = c - upperB
	elseif c < 1 then
		c = c + upperB
	end
	return c
end

function CheckCrop(CropName, CropGrowth) --# Returns a seed to plant or nil if crop should not be harvested
	local MatchingSeed
	for i, crop in ipairs(seedbank) do
		if crop[1] == CropName and crop[2] == CropGrowth then
			MatchingSeed = crop[3]
			break
		end
	end
	return MatchingSeed
end

function findSeedsInInv(Seed) --#Select inventory slot with matching seeds
	local p = turtle.getSelectedSlot()
	for i = 0,15 do
		turtle.select(LoopAdd(p, i, 16))
		local data = turtle.getItemDetail()
		if data then
			if data.name == Seed then
				return true
			end
		end
	end
	return false
end

function ReadyToHarvest() --#Checks if this block is ready for harvesting, then harvest-plants. Tills IF block is empty
	local success, data = turtle.inspectDown()
	if success then
		local seed = CheckCrop(data.name, data.metadata)
		if seed then
			turtle.digDown()
			if findSeedsInInv(seed) then
				turtle.placeDown()
			end
		end
	else
		turtle.digDown()	
	end
end

function RecTurtleUp() --# records the turtle climbing up one block
	TurtleRelPos[3] = TurtleRelPos[3] + 1
end

function RecTurtleDown()
	TurtleRelPos[3] = TurtleRelPos[3] - 1
end

function RecTurtleFwd()
	TurtleRelPos[1] = TurtleRelPos[1] + Orientation[OriPtr][1]
	TurtleRelPos[2] = TurtleRelPos[2] + Orientation[OriPtr][2]
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

function TryMove(MoveDirection) --# move. -1 = up, 0 = forward, 1 = down
	local Cmove = turtle.down
	local Cdetect = turtle.detectDown
	local Cdig = turtle.digDown
	local Cattack = turtle.attackDown
	local CRecT = RecTurtleDown
	if MoveDirection == 0 then
		Cmove = turtle.forward
		Cdetect = turtle.detect
		Cdig = turtle.dig
		Cattack = turtle.attack
		CRecT = RecTurtleFwd
	elseif MoveDirection < 0 then
		Cmove = turtle.up
		Cdetect = turtle.detectUp
		Cdig = turtle.digUp
		Cattack = turtle.attackUp
		CRecT = RecTurtleUp
	end
	
	local trycount = 0
	while trycount < 20 and not Cmove() do
		if Cdetect() then
			return false
		elseif Cattack() then
			while Cattack() do end
		elseif turtle.getFuelLevel() == 0 then
			if not TryRefuel() then
				print("Ran out of fuel!")
				return false
			end
		end
		trycount = trycount + 1
	end

	if trycount < 20 then
		CRecT()
		return true
	else
		return false
	end
end

function Advance() --# call trymove 1 block, then ReadyToHarvest. Returns TRUE if successful moving.
	if TryMove(0) then 
		ReadyToHarvest()
		return true
	end
	return false
end

function Farmline(LastTurn)
	while Advance() do end
	if LastTurn == Zig then
		return Zag
	else
		return Zig
	end
end

function Zig() --#CW double turn, returns boolean TRUE if successful, FALSE if failed. Used to check for finished
	turtle.turnRight()
	OriPtr = LoopAdd(OriPtr, 1, 4)
	if TryMove(0) then
		ReadyToHarvest()
	else
		return false
	end
	turtle.turnRight()
	OriPtr = LoopAdd(OriPtr, 1, 4)
	return true
end

function Zag() --#CCW version of Zig
	turtle.turnLeft()
	OriPtr = LoopAdd(OriPtr, -1, 4)
	if TryMove(0) then
		ReadyToHarvest()
	else
		return false
	end
	turtle.turnLeft()
	OriPtr = LoopAdd(OriPtr, -1, 4)
	return true
end

function ReturnHome()

	while TurtleRelPos[3] > 0 do
		if not TryMove(1) then break
		end
	end
	while TurtleRelPos[3] < 0 do
		if not TryMove(-1) then break
		end
	end
	if TurtleRelPos[1] < 0 then
		if OriPtr == 1 then
			turtle.turnRight()
			OriPtr = LoopAdd(OriPtr, 1, 4)
		elseif OriPtr == 3 then
			turtle.turnLeft()
			OriPtr = LoopAdd(OriPtr, -1, 4)
		elseif OriPtr == 4 then
			turtle.turnRight()
			turtle.turnRight()
			OriPtr = LoopAdd(OriPtr, 2, 4)
		end
	elseif TurtleRelPos[1] > 0 then
		if OriPtr == 1 then
			turtle.turnLeft()
			OriPtr = LoopAdd(OriPtr, -1, 4)
		elseif OriPtr == 3 then
			turtle.turnRight()
			OriPtr = LoopAdd(OriPtr, 1, 4)
		elseif OriPtr == 2 then
			turtle.turnLeft()
			turtle.turnLeft()
			OriPtr = LoopAdd(OriPtr, -2, 4)
		end
	end
	while TurtleRelPos[1] ~= 0 do
		if not TryMove(0) then break
		end
	end
	if TurtleRelPos[2] < 0 then --# I think this case can't happen
		if OriPtr == 4 then
			turtle.turnRight()
			OriPtr = LoopAdd(OriPtr, 1, 4)
		elseif OriPtr == 2 then
			turtle.turnLeft()
			OriPtr = LoopAdd(OriPtr, -1, 4)
		elseif OriPtr == 3 then
			turtle.turnRight()
			turtle.turnRight()
			OriPtr = LoopAdd(OriPtr, 2, 4)
		end
	elseif TurtleRelPos[2] > 0 then
		if OriPtr == 4 then
			turtle.turnLeft()
			OriPtr = LoopAdd(OriPtr, -1, 4)
		elseif OriPtr == 2 then
			turtle.turnRight()
			OriPtr = LoopAdd(OriPtr, 1, 4)
		elseif OriPtr == 1 then
			turtle.turnLeft()
			turtle.turnLeft()
			OriPtr = LoopAdd(OriPtr, -2, 4)
		end
	end
	while TurtleRelPos[2] ~= 0 do
		if not TryMove(0) then break
		end
	end	
	
end

Orientation = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}
OriPtr = 1
TurtleRelPos = {0, 0, 0}

seedbank = {{"minecraft:wheat", 7, "minecraft:wheat_seeds"}, {"minecraft:beetroots", 3, "minecraft:beetroot_seeds"}, {"minecraft:carrots", 7, "minecraft:carrot"}, {"minecraft:potatoes", 7, "minecraft:potato"}}

NextTurn = Farmline(Zag)
while NextTurn() do
	NextTurn = Farmline(NextTurn)
end
ReturnHome()
turtle.turnLeft()
OriPtr = LoopAdd(OriPtr, -1, 4)
turtle.turnLeft()
OriPtr = LoopAdd(OriPtr, -1, 4)
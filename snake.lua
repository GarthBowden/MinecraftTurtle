function IsDesirableOre(BlockName)

	local undesirables = {"minecraft:stone", "minecraft:grass", "minecraft:dirt", "minecraft:cobblestone", "minecraft:planks", "minecraft:bedrock", "minecraft:sand", "minecraft:gravel", "minecraft:sandstone", "minecraft:netherrack"}
	for i, BlockID in ipairs(undesirables)
	do
		if BlockName == BlockID then
			return false
		end
	end
	return true
	
end

function MaybeMine()

	if turtle.detect() then
		local success, data = turtle.inspect()
		if IsDesirableOre(data.name) then
			turtle.dig()
		end
	end
	
end

function CheckSides()

	turtle.turnLeft()
	MaybeMine()
	turtle.turnRight()
	turtle.turnRight()
	MaybeMine()
	turtle.turnLeft()
	
end

function MaybeMineV()
	if turtle.detectUp() then
		local success, data = turtle.inspectUp()
		if IsDesirableOre(data.name) then
			turtle.digUp()
		end
	end
	if turtle.detectDown() then
		local success, data = turtle.inspectDown()
		if IsDesirableOre(data.name) then
			turtle.digDown()
		end	
	end
	
end

function LoopAdd(a, b, upperB) --# modulus on sum with result between 1 and upper bound
	local c = a + b
	if c > upperB then
		c = c - upperB
	elseif c < 1 then
		c = c + upperB
	end
	return c
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
		MaybeMineV()
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
			if not Cdig() then
				print("Reached bedrock!")
				return false
			end
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
	MaybeMine()
	if trycount < 20 then
		CRecT()
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

function main(length, width, depth)
	local AWidth, remainingDepth = width, depth
	if(width < 0) then 
		NextTurn = turtle.turnLeft
		AWidth = AWidth * -1
		OriIncDir = -1
	end
	if(depth < 0) then
		remainingDepth = remainingDepth * -1
	end

	while remainingDepth > 0 do
		local remainingWidth = AWidth
		local remainingLength = length
		while remainingWidth > 0 do
			remainingLength = length
			while remainingLength > 0 do
				if not TryMove(0) then
					return
				else 
					remainingLength = remainingLength - 1
					CheckSides()
				end
			end
			NextTurn()
			OriPtr = LoopAdd(OriIncDir, OriPtr, 4)
			for i=1,3 do
				if not TryMove(0) then
					return
				end
			end
			NextTurn()
			OriPtr = LoopAdd(OriIncDir, OriPtr, 4)
			
			if NextTurn == turtle.turnRight then
				NextTurn = turtle.turnLeft
				OriIncDir = -1
			else
				NextTurn = turtle.turnRight
				OriIncDir = 1
			end
			remainingWidth = remainingWidth - 3
		end
		remainingLength = length
		while remainingLength > 0 do
			if not TryMove(0) then
				return
			else remainingLength = remainingLength - 1
			end
		end
		remainingDepth = remainingDepth - 3
		NextTurn()
		NextTurn()
		OriPtr = LoopAdd(OriIncDir * 2, OriPtr, 4)

		if remainingDepth > 0 then
			for i=1,3 do
				if not TryMove(depth) then
					return
				end
			end
		end
	end
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
print("Input length:")
local l = tonumber(read())
print("Input width:")
local w = tonumber(read())
print("Input depth:")
local d = tonumber(read())

Orientation = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}
OriPtr = 1
OriIncDir = 1
TurtleRelPos = {0, 0, 0}

if l > 0 and w ~= 0 and d ~= 0 then
	NextTurn = turtle.turnRight
	main(l, w, d)
	ReturnHome()
else
	print("args must be nonzero numbers and argument 1 must be positive!")
end



	
-- Room Validator Script for ComputerCraft Turtle
-- This script removes water or lava blocks to ensure no leaks in the room.

-- Function to prompt user for movement instructions
local function getMovementInstructions()
    print("Enter the number of blocks to move/dig in each direction:")
    io.write("Go right x blocks: ")
    local right = tonumber(read())
    io.write("Go left x blocks: ")
    local left = tonumber(read())
    io.write("Go forward x blocks: ")
    local forward = tonumber(read())
    io.write("Go backward x blocks: ")
    local backward = tonumber(read())
    io.write("Go up x blocks: ")
    local up = tonumber(read())
    io.write("Go down x blocks: ")
    local down = tonumber(read())
    return right, left, forward, backward, up, down
end

-- Function to calculate room dimensions based on movement instructions
local function calculateRoomDimensions(right, left, forward, backward, up, down, includeCurrentPosition)
    local width = right + left
    local length = forward + backward
    local height = up + down

    -- Include the turtle's current position in the calculation if specified
    if includeCurrentPosition then
        width = width + 1
        length = length + 1
        height = height + 1
    end

    return length, width, height
end

-- Function to confirm room dimensions with the player
local function confirmRoomDimensions(length, width, height)
    print("The calculated room size is:")
    print("Length (forward): " .. length)
    print("Width (right): " .. width)
    print("Height (up): " .. height)
    print("Is this correct? (yes/no)")
    local response = read()
    return response:lower() == "yes"
end

-- Function to check for liquids and remove them
local function removeLiquid(direction)
    local success, block
    if direction == "forward" then
        success, block = turtle.inspect()
    elseif direction == "up" then
        success, block = turtle.inspectUp()
    elseif direction == "down" then
        success, block = turtle.inspectDown()
    end

    if success and (block.name == "minecraft:water" or block.name == "minecraft:lava") then
        print("Liquid block detected (" .. block.name .. "). Replacing...")
        if direction == "forward" then
            turtle.dig()
            turtle.place()
        elseif direction == "up" then
            turtle.digUp()
            turtle.placeUp()
        elseif direction == "down" then
            turtle.digDown()
            turtle.placeDown()
        end
    end
end

-- Function to move forward and check for liquids
local function moveForwardAndCheck()
    removeLiquid("forward")
    while not turtle.forward() do
        turtle.dig()
        sleep(0.5)
    end
end

-- Function to check for liquids above and below
local function checkVerticalLiquids()
    removeLiquid("up")
    removeLiquid("down")
end

-- Function to validate a single layer
local function validateLayer(length, width)
    for w = 1, width do
        for l = 1, length - 1 do
            checkVerticalLiquids()
            moveForwardAndCheck()
        end
        if w < width then
            if w % 2 == 1 then
                turtle.turnRight()
                moveForwardAndCheck()
                turtle.turnRight()
            else
                turtle.turnLeft()
                moveForwardAndCheck()
                turtle.turnLeft()
            end
        end
    end
end

-- Function to move forward n steps, handling obstacles and fuel
local function moveForward(steps)
    for i = 1, steps do
        if not checkFuel(1) then
            print("Not enough fuel to move forward.")
            return false
        end
        while not turtle.forward() do
            if turtle.detect() then
                print("Obstacle detected. Digging...")
                turtle.dig()
            else
                print("Unable to move forward. Retrying...")
                sleep(0.5)
            end
        end
        print("Moved forward 1 step. Remaining steps: " .. (steps - i))
    end
    return true
end

-- Function to check fuel level and refuel if necessary
local function checkFuel(minimumFuel)
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" then
        return true
    end
    if fuelLevel < minimumFuel then
        print("Low fuel. Current fuel level: " .. fuelLevel)
        return refuel()
    end
    return true
end

-- Function to move the turtle based on movement instructions
local function moveTurtle(right, left, forward, backward, up, down)
    -- Move right
    if right > 0 then
        print("Moving right " .. right .. " blocks...")
        turtle.turnRight()
        if not moveForward(right) then
            print("Failed to move right.")
            return false
        end
        turtle.turnLeft()
    end

    -- Move left
    if left > 0 then
        print("Moving left " .. left .. " blocks...")
        turtle.turnLeft()
        if not moveForward(left) then
            print("Failed to move left.")
            return false
        end
        turtle.turnRight()
    end

    -- Move forward
    if forward > 0 then
        print("Moving forward " .. forward .. " blocks...")
        if not moveForward(forward) then
            print("Failed to move forward.")
            return false
        end
    end

    -- Move backward
    if backward > 0 then
        print("Moving backward " .. backward .. " blocks...")
        turtle.turnRight()
        turtle.turnRight()
        if not moveForward(backward) then
            print("Failed to move backward.")
            return false
        end
        turtle.turnRight()
        turtle.turnRight()
    end

    -- Move up
    if up > 0 then
        print("Moving up " .. up .. " blocks...")
        for i = 1, up do
            if not checkFuel(1) then
                print("Not enough fuel to move up.")
                return false
            end
            while not turtle.up() do
                print("Obstacle detected above. Digging...")
                turtle.digUp()
                sleep(0.5)
            end
        end
    end

    -- Move down
    if down > 0 then
        print("Moving down " .. down .. " blocks...")
        for i = 1, down do
            if not checkFuel(1) then
                print("Not enough fuel to move down.")
                return false
            end
            while not turtle.down() do
                print("Obstacle detected below. Digging...")
                turtle.digDown()
                sleep(0.5)
            end
        end
    end

    print("Movement complete.")
    return true
end

-- Main function to handle room validation
local function main()
    print("Should the turtle move to a designated area first or start validation from its current position? (move/start)")
    local startOption = read():lower()

    if startOption == "move" then
        print("Enter movement instructions to reach the designated area:")
        local right, left, forward, backward, up, down = getMovementInstructions()
        if not moveTurtle(right, left, forward, backward, up, down) then
            print("Failed to move to the designated area. Exiting...")
            return
        end
    end

    local right, left, forward, backward, up, down
    local includeCurrentPosition

    repeat
        right, left, forward, backward, up, down = getMovementInstructions()
        print("Should the turtle's current position be included in the room size? (yes/no)")
        includeCurrentPosition = read():lower() == "yes"

        local length, width, height = calculateRoomDimensions(right, left, forward, backward, up, down, includeCurrentPosition)
        if not confirmRoomDimensions(length, width, height) then
            print("Let's try again.")
        end
    until confirmRoomDimensions(length, width, height)

    print("Starting room validation...")

    local length, width, height = calculateRoomDimensions(right, left, forward, backward, up, down, includeCurrentPosition)

    for h = 1, height do
        validateLayer(length, width)
        if h < height then
            removeLiquid("down")
            turtle.down()
        end
    end

    print("Room validation complete!")
end

main()
-- Dynamic Excavation Script for ComputerCraft Turtle
-- The turtle calculates the room size based on movement instructions and confirms with the player.

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

-- Function to refuel the turtle
local function refuel()
    print("Returning to refuel...")
    for slot = 1, 16 do
        turtle.select(slot)
        if turtle.refuel(0) then
            turtle.refuel()
            print("Refueled successfully.")
            return true
        end
    end
    print("No fuel available in inventory. Please add fuel and press Enter to continue.")
    read()
    return refuel()
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

-- Function to dig forward, handling obstacles
local function digForward()
    while turtle.detect() do
        turtle.dig()
        sleep(0.5)
    end
    while not turtle.forward() do
        turtle.dig()
        sleep(0.5)
    end
end

-- Function to dig upward, handling obstacles
local function digUp()
    while turtle.detectUp() do
        turtle.digUp()
        sleep(0.5)
    end
end

-- Function to dig downward, handling obstacles
local function digDown()
    while turtle.detectDown() do
        turtle.digDown()
        sleep(0.5)
    end
end

-- Function to move forward n steps, handling obstacles and fuel
local function moveForward(steps)
    for i = 1, steps do
        if not checkFuel(1) then
            return false
        end
        digForward()
    end
    return true
end

-- Function to move the turtle based on movement instructions
local function moveTurtle(right, left, forward, backward, up, down)
    -- Move right
    if right > 0 then
        print("Moving right " .. right .. " blocks...")
        turtle.turnRight()
        moveForward(right)
        turtle.turnLeft()
    end

    -- Move left
    if left > 0 then
        print("Moving left " .. left .. " blocks...")
        turtle.turnLeft()
        moveForward(left)
        turtle.turnRight()
    end

    -- Move forward
    if forward > 0 then
        print("Moving forward " .. forward .. " blocks...")
        moveForward(forward)
    end

    -- Move backward
    if backward > 0 then
        print("Moving backward " .. backward .. " blocks...")
        turtle.turnRight()
        turtle.turnRight()
        moveForward(backward)
        turtle.turnRight()
        turtle.turnRight()
    end

    -- Move up
    if up > 0 then
        print("Moving up " .. up .. " blocks...")
        for i = 1, up do
            if not checkFuel(1) then
                return false
            end
            while not turtle.up() do
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
                return false
            end
            while not turtle.down() do
                turtle.digDown()
                sleep(0.5)
            end
        end
    end

    print("Movement complete.")
end

-- Function to excavate a single layer
local function excavateLayer(length, width)
    for w = 1, width do
        for l = 1, length - 1 do
            digUp()
            digDown()
            digForward()
        end
        if w < width then
            if w % 2 == 1 then
                turtle.turnRight()
                digUp()
                digDown()
                digForward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                digUp()
                digDown()
                digForward()
                turtle.turnLeft()
            end
        end
    end
end

-- Main function to handle excavation
local function main()
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

    print("Starting excavation...")
    moveTurtle(right, left, forward, backward, up, down)

    local length, width, height = calculateRoomDimensions(right, left, forward, backward, up, down, includeCurrentPosition)

    for h = 1, height do
        excavateLayer(length, width)
        if h < height then
            digDown()
            turtle.down()
        end
    end

    print("Excavation complete!")
end

main()
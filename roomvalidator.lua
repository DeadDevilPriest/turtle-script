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

-- Main function to handle room validation
local function main()
    print("Should the turtle move to a designated area first or start validation from its current position? (move/start)")
    local startOption = read():lower()

    if startOption == "move" then
        print("Enter movement instructions to reach the designated area:")
        local right, left, forward, backward, up, down = getMovementInstructions()
        moveTurtle(right, left, forward, backward, up, down)
    elseif startOption ~= "start" then
        print("Invalid option. Exiting...")
        return
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
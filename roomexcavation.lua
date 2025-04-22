-- Dynamic Excavation Script for ComputerCraft Turtle
-- The turtle starts at the center of the room's length, at the front-left corner.

-- Function to prompt user for dimensions
local function getDimensions()
    print("Enter the room dimensions:")
    io.write("Length (forward): ")
    local length = tonumber(read())
    io.write("Width (right): ")
    local width = tonumber(read())
    io.write("Height (up): ")
    local height = tonumber(read())
    return length, width, height
end

-- Function to refuel the turtle
local function refuel()
    print("Returning to refuel...")
    -- Attempt to refuel
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
    return refuel() -- Retry refueling
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
        if not checkFuel(1) then -- Ensure enough fuel for each step
            return false
        end
        digForward()
    end
    return true
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
    local length, width, height = getDimensions()
    if not length or not width or not height then
        print("Invalid input. Please enter numeric values.")
        return
    end

    -- Calculate half dimensions
    local halfLength = math.floor(length / 2)
    local halfWidth = math.floor(width / 2)

    print("Moving to starting corner...")

    -- Move to starting corner
    if not moveForward(halfWidth) then
        print("Failed to move to starting corner (width).")
        return
    end
    turtle.turnRight()
    if not moveForward(halfLength) then
        print("Failed to move to starting corner (length).")
        return
    end
    turtle.turnRight()
    print("Reached starting corner.")

    print("Starting excavation...")

    for h = 1, height do
        excavateLayer(length, width)
        if h < height then
            digDown()
            turtle.down()
            -- Return to starting position for next layer
            if width % 2 == 0 then
                turtle.turnRight()
                for i = 1, width - 1 do
                    if not checkFuel(1) then
                        return
                    end
                    digForward()
                end
                turtle.turnRight()
            else
                if length % 2 == 0 then
                    turtle.turnLeft()
                    for i = 1, width - 1 do
                        if not checkFuel(1) then
                            return
                        end
                        digForward()
                    end
                    turtle.turnLeft()
                else
                    turtle.turnRight()
                    for i = 1, width - 1 do
                        if not checkFuel(1) then
                            return
                        end
                        digForward()
                    end
                    turtle.turnRight()
                end
            end
        end

        -- Check fuel level periodically
        if not checkFuel(10) then
            return
        end
    end

    -- Return to center
    for i = 1, height - 1 do
        turtle.up()
    end
    turtle.turnLeft()
    moveForward(halfLength)
    turtle.turnLeft()
    moveForward(halfWidth)
    turtle.turnRight()

    print("Excavation complete!")
end

main()
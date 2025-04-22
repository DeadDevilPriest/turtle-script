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
    -- Return to starting position
    turtle.turnLeft()
    moveForward(halfLength)
    turtle.turnLeft()
    moveForward(halfWidth)
    turtle.turnRight()
  
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

  -- Modify checkFuel to include refueling logic
local function checkFuel(requiredFuel)
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" then
      return true
    end
    if fuelLevel < requiredFuel then
      print("Not enough fuel. Required: " .. requiredFuel .. ", Available: " .. fuelLevel)
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
  
  -- Function to move forward n steps
  local function moveForward(steps)
    for i = 1, steps do
      digForward()
    end
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
  
 -- Update main function to handle refueling during excavation
local function main()
    local length, width, height = getDimensions()
    if not length or not width or not height then
      print("Invalid input. Please enter numeric values.")
      return
    end
  
    -- Calculate half dimensions
    halfLength = math.floor(length / 2)
    halfWidth = math.floor(width / 2)
  
    print("Moving to starting corner...")
  
    -- Move to starting corner
    turtle.turnLeft()
    moveForward(halfWidth)
    turtle.turnRight()
    moveForward(halfLength)
    turtle.turnRight()
  
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
            digForward()
          end
          turtle.turnRight()
        else
          if length % 2 == 0 then
            turtle.turnLeft()
            for i = 1, width - 1 do
              digForward()
            end
            turtle.turnLeft()
          else
            turtle.turnRight()
            for i = 1, width - 1 do
              digForward()
            end
            turtle.turnRight()
          end
        end
      end
  
      -- Check fuel level periodically
      if not checkFuel(length * width * (height - h)) then
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
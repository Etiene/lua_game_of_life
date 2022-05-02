-- Conway's game of life, written in Lua
-- By Etiene Dalcol
-- License: CC-By

package.path = '3rd_party/?.lua;' .. package.path
lurker = require "lurker" -- for hot reloading code in Love2D

local World = {}
local Cell = {}

function Cell:new(world, active, x, y)
    local obj = obj or {
        active = active or false,
        world = world,
        x = x,
        y = y
	}
 
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function Cell:count_neighbors()
    local count = 0
    local neighbors = self:get_neighbors()
    for _, cell in ipairs(neighbors) do
        if(cell.active) then 
            count = count + 1
        end
    end
    self.active_neighbors = count
    return count
end

function Cell:iterate()
    local active_neighbors = self.active_neighbors
    if(self.active) then
        self.active = active_neighbors == 2 or active_neighbors == 3
    else
        self.active = active_neighbors == 3
    end
end 

function Cell:draw()
    local scale = self.world.scale
    if(self.active) then
        love.graphics.rectangle("fill", self.x * scale , self.y * scale, scale, scale)
    end
end

function Cell:get_neighbors()
    local neighbors = {}
    local start_x = math.max(self.x - 1, 1)
    local start_y = math.max(self.y - 1, 1)
    local end_x = math.min(self.x + 1, self.world.width)
    local end_y = math.min(self.y + 1, self.world.height)
    for x=start_x, end_x do
        for y=start_y, end_y do
            if(x ~= self.x or y ~= self.y) then -- different position than self
                neighbors[#neighbors+1]=self.world.world[x][y]
            end
        end
    end
    return neighbors
end

function World:new(width, height, chance, scale)
    chance = chance or 1
    local obj = obj or {
		width = width, 
		height = height,
        scale = scale or 1,
        cell_list = {},
        world = {} 
	}
    for x=1,width do
        obj.world[x] = {}
        for y=1,height do
            local cell = Cell:new(obj, math.random(100) < chance, x, y)
            obj.world[x][y]= cell
            obj.cell_list[#(obj.cell_list) + 1] = cell
        end
    end
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function World:iterate()
    for _,cell in ipairs(self.cell_list) do
        cell:count_neighbors()
    end
    for _,cell in ipairs(self.cell_list) do
        cell:iterate()
    end
end

function World:draw()
    for _, cell in ipairs(self.cell_list) do
        cell:draw()
    end
end

local time = 0
local time_divider = 5 -- bigger number == slower animation
local world_size_pixels =  300
local percent_initial_active_cells = 15
local scale = 3 -- bigger number == cell square looks bigger
local world = World:new(
    math.floor(world_size_pixels/scale),
    math.floor(world_size_pixels/scale),
    percent_initial_active_cells,
    scale)

function love.load()
    -- runs once when opening game
	love.window.setTitle("Conway's game of life")
	love.window.setMode(world_size_pixels, world_size_pixels)
end

function love.update()
    -- runs continuously at every frame
    lurker.update() -- this line required for hot reloading
    time = time + 1

    if(time % (time_divider + 1) == time_divider) then
        world:iterate()
        time = 0
    end
end

function love.draw()
    -- runs continously at every frame
    world:draw()
end

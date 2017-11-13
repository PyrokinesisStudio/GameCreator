--[[
	Pixel Vision 8 - Preloader Tool
	Copyright (C) 2017, Pixel Vision 8 (http://pixelvision8.com)
	Created by Jesse Freeman (@jessefreeman)

	Please do not copy and distribute verbatim copies
	of this license document, but modifications without
	distribiting is allowed.
]]--

-- mode enums
local Up, Down, Right, Left, A, B, Select, Start = 0, 1, 2, 3, 4, 5, 6, 7

-- animation data
local anim = {
	delay = 0,
	time = .5,
	frame = 1,
	total = 2,
	frames = {
		{
			{0, 1, 8, 9},
			{0, 1, 10, 11}
		},
		{
			{2, 3, 12, 13},
			{2, 3, 14, 15}
		},
		{
			{4, 5, 16, 17},
			{4, 5, 18, 19}
		},
		{
			{4, 5, 16, 17},
			{4, 5, 18, 19}
		}
	}
}

-- player data
local player = {
	dir = 1,
	flipH = false,
	x = 0,
	y = 0,
	tilePos = {
		col = 0,
		row = 0
	}
}

-- map data
local map = {
	grid = {
		col = 0,
		row = 0,
		size = 0
	},
	scrollX = 0,
	scrollY = 0,
	scrollPos = {
		col = 0,
		row = 0
	},
	bounds = {
		min = 0,
		max = 0
	}
}

local inputDelay = .2
local inputTime = 0

local message = ""

function Init()

	-- Build the screen buffer
	BackgroundColor(1)

	local displaySize = DisplaySize()

	-- get the tile size we want to move the player
	map.grid.size = SpriteSize().x * 2
	map.grid.col = math.ceil(displaySize.x / map.grid.size)
	map.grid.rows = math.ceil(displaySize.y / map.grid.size)

	-- reset map values

	map.bounds.left = 1
	map.bounds.right = map.grid.col - 2
	map.bounds.top = 1
	map.bounds.bottom = map.grid.rows - 2

	-- map.bounds.left = 1
	-- map.bounds.right = map.grid.col-1
	map.scrollX = 0
	map.scrollY = 0--displaySize.y
	map.scrollPos.col = 0
	map.scrollPos.row = 0

	movePlayer(5, 5)

end

function Update(timeDelta)

	ScrollPosition(map.scrollX + (map.scrollPos.col * map.grid.size), map.scrollY + (map.scrollPos.row * map.grid.size))

	inputTime = inputTime + timeDelta

	if(inputTime > inputDelay) then

		inputTime = 0

		local dirVector = {x = 0, y = 0}

		-- capture imput
		if(Button(Up, 0)) then
			-- show back of player
			player.dir = 2
			player.flipH = false
			dirVector.y = -1
		end
		if (Button(Down, 0)) then
			-- show front of player
			player.dir = 1
			player.flipH = false
			dirVector.y = 1
		end
		if(Button(Right, 0)) then
			-- show side of player and toggle flip
			player.dir = 4
			player.flipH = true
			dirVector.x = -1
		end
		if (Button(Left, 0)) then
			-- show side of player and toggle flip
			player.dir = 3
			player.flipH = false
			dirVector.x = 1
		end

		if(dirVector.x ~= 0 or dirVector.y ~= 0) then
			movePlayer(dirVector.x, dirVector.y)
		end
	end
	-- update animation timer
	anim.delay = anim.delay + timeDelta

	-- see if we should change animation
	if(anim.delay > anim.time) then

		-- reset the delay
		anim.delay = 0

		-- update the current frame
		anim.frame = anim.frame + 1

		-- make sure we reset the frame counter when out of anim.frames
		if(anim.frame > anim.total) then
			anim.frame = 1
		end
	end

end

function Draw()

	-- We can use the RedrawDisplay() method to clear the screen and redraw the tilemap in a
	-- single call.
	RedrawDisplay()

	-- We need to make sure we don't auto hide the sprites since they will stay on the screen at all times
	DrawSprites(anim.frames[player.dir][anim.frame], player.x, player.y, 2, player.flipH, false, DrawMode.SpriteAbove, 0, false)

	if(message ~= "") then
		DrawText(message, 8, 0, DrawMode.Sprite, "message-font", 0, - 4)
	end

end

function movePlayer(col, row)

	-- set up values to pre-calculate where the player should move to
	local nextCol = player.tilePos.col + col
	local nextRow = player.tilePos.row + row
	local nextScrollPos = {col = map.scrollPos.col, row = map.scrollPos.row }

	-- test the horizontal boundary
	if(nextCol < map.bounds.left) then
		nextCol = map.bounds.left
		nextScrollPos.col = nextScrollPos.col + col
	elseif nextCol > map.bounds.right then
		nextCol = map.bounds.right
		nextScrollPos.col = nextScrollPos.col + col
	end

	-- test the vertical boundary
	if(nextRow < map.bounds.top) then
		nextScrollPos.row = nextScrollPos.row + row
		nextRow = map.bounds.top
	elseif nextRow > map.bounds.bottom then
		nextRow = map.bounds.bottom
		nextScrollPos.row = nextScrollPos.row + row
	end


	-- calculate the correct map column
	local testCol = Repeat((nextCol + nextScrollPos.col) * 2, 40)

	-- TODO need to fix the math here, not sure what 40 is from

	-- calculate the correct map row
	local testRow = Repeat((nextRow + nextScrollPos.row) * 2, 40) --nextRow * 2-- + (apiBridge.displayHeight / apiBridge.spriteHeight)


	-- test for collision
	local testFlag = Tile(testCol, testRow).flag

	-- track if the player can walk
	local canWalk = false

	-- test for collision
	if(testFlag < 3) then
		canWalk = true
	end

	-- Set for testing
	--canWalk = true

	-- move the player
	if(canWalk) then

		-- set the values once collision is not detected
		player.tilePos.col = nextCol
		player.tilePos.row = nextRow
		map.scrollPos = nextScrollPos

		-- move the player
		player.x = nextCol * map.grid.size
		player.y = nextRow * map.grid.size

		if(testFlag == -1) then
			message = ""
		elseif (testFlag == 0) then
			message = "Approaching A Castle"
		elseif (testFlag == 1) then
			message = "Approaching A Town"
		elseif (testFlag == 2) then
			message = "Approaching A Dungeon"
		end
	end

end

--
-- Copyright (c) 2017, Jesse Freeman. All rights reserved.
--
-- Licensed under the Microsoft Public License (MS-PL) License.
-- See LICENSE file in the project root for full license information.
--
-- Contributors
-- --------------------------------------------------------
-- This is the official list of Pixel Vision 8 contributors:
--
-- Jesse Freeman - @JesseFreeman
-- Christer Kaitila - @McFunkypants
-- Pedro Medeiros - @saint11
-- Shawn Rakowski - @shwany
--

function EditorUI:CreateToggleButton(flag, rect, spriteName, toolTip, forceDraw)

  -- Use the same data as the button
  local data = self:CreateButton(flag, rect, spriteName, toolTip, forceDraw)

  -- Add the selected property to make this a toggle button
  data.selected = false

  data.onClick = function(tmpData)
    self:ToggleButton(tmpData)
  end

  return data

end

function EditorUI:ToggleButton(data, value, callAction)

  if(value == nil) then
    value = not data.selected
  end

  -- invert the selected value
  data.selected = value

  -- force the button to redraw itself
  data.invalid = true

  -- Call the button data's onAction method and pass the current selected state
  if(data.onAction ~= nil and callAction ~= false)then
    data.onAction(data.selected)
  end

end

function EditorUI:CreateToggleGroup(flag, singleSelection)

  singleSelection = singleSelection == nil and true or singleSelection

  local data = self:CreateData(flag)

  -- flagID = flag,
  -- x = x,
  -- y = y,
  data.buttons = {}
  data.currentSelection = 0
  data.onAction = nil
  data.invalid = false
  data.hovered = 0
  data.singleSelection = singleSelection
  -- }

  return data

end

-- Helper method that created a toggle button and adds it to the group
function EditorUI:ToggleGroupButton(data, rect, spriteName, toolTip, forceDraw)

  -- Create a new toggle group button
  local buttonData = self:CreateToggleButton(data.flagID, rect, spriteName, toolTip, forceDraw)

  -- Add the new button to the toggle group
  self:ToggleGroupAddButton(data, buttonData)

  -- Return the button data
  return buttonData

end

function EditorUI:ToggleGroupAddButton(data, buttonData, id)

  -- When adding a new button, force it to redraw
  --data.invalid = forceDraw or true

  -- Modify the hit rect to the new rect position
  buttonData.hitRect = {x = buttonData.rect.x, y = buttonData.rect.y, w = buttonData.rect.w, h = buttonData.rect.h}

  -- TODO need to replace with table insert
  -- Need to figure out where to put the button, if no id exists, find the last position in the buttons table
  id = id or #data.buttons + 1

  -- save the button data
  table.insert(data.buttons, id, buttonData)

  -- Attach a new onAction to the button so it works within the group
  buttonData.onAction = function()

    self:SelectToggleButton(data, id)

  end

  -- Invalidate the button so it redraws
  self:Invalidate(buttonData)

end

function EditorUI:ToggleGroupRemoveButton(data, id)

  if(data.currentSelection == id) then
    data.currentSelection = 0
  end

  table.remove(data.buttons, id)

  data.invalid = true

  --TODO Call remove button method on editor ui

end

function EditorUI:UpdateToggleGroup(data)

  -- Exit the update if there is no is no data
  if(data == nil) then
    return
  end

  -- Set data for the total number of buttons for the loop
  local total = #data.buttons
  local btn = nil

  -- Loop through each of the buttons and update them
  for i = 1, total do

    btn = data.buttons[i]

    self:UpdateButton(btn)

  end

  --self.collisionManager:ClearHovered()

end

-- function EditorUI:DrawToggleGroup(data)
--
--   -- Make sure there is button data to render
--   if(data.buttons == nil)then
--     return
--   end
--
--   -- We'll use this to store button data as we draw the toggle group
--   local buttonData = nil
--
--   -- Get the total number of buttons
--   local total = #data.buttons
--
--   -- Loop through each of the buttons and update them
--   for i = 1, total do
--
--     -- Get the button data from the collection of buttons
--     buttonData = data.buttons[i]
--     if(buttonData ~= nil) then
--       -- Check to see if the button is actually invalid
--       -- if(buttonData.invalid == true or data.hovered == i) then
--       --TODO this is constantly be called, need to optimize it better
--       self:DrawButton(buttonData)
--       -- end
--     end
--   end
--
-- end

function EditorUI:SelectToggleButton(data, id, trigger)
  -- TODO need to make sure we handle multiple selections vs one at a time

  -- Get the new button to select
  local buttonData = data.buttons[id]
  --print("Select", id, #data.buttons)

  -- Make sure there is button data and the button is not disabled
  if(buttonData == nil or buttonData.enabled == false)then
    return
  end

  -- if the button is already selected, just ignore the request
  if(id == buttonData.selected) then
    return
  end



  if(data.singleSelection == true) then
    -- Make sure that the button is selected before we disable it
    buttonData.selected = true
    self:Enable(buttonData, false)

  end

  -- Now it's time to restore the last button.
  if(data.currentSelection > 0) then

    -- Get the old button data
    buttonData = data.buttons[data.currentSelection]

    -- Make sure there is button data first, incase there wasn't a previous selection
    if(buttonData ~= nil) then

      if(data.singleSelection == true) then
        -- Reset the button's selection value to the group's disable selection value
        buttonData.selected = false

        -- Enable the button since it is no longer selected
        self:Enable(buttonData, true)

      end

    end

  end

  -- Set the current selection ID
  data.currentSelection = id

  -- Trigger the action for the selection
  if(data.onAction ~= nil and trigger ~= false) then
    data.onAction(id)
  end

end

function EditorUI:ToggleGroupCurrentSelection(data)
  return data.buttons[data.currentSelection]
end

-- TODO is anything using this?
function EditorUI:ToggleGroupSelections(data)
  local selections = {}
  print("Toggle Data", data.name)
  local total = #data.buttons
  local buttonData = nil
  for i = 1, total do
    buttonData = data.buttons[i]
    if(buttonData ~= nil and buttonData.selected == true)then
      selections[#selections + 1] = i
    end
  end

  return selections
end

function EditorUI:ClearGroupSelections(data)

  local total = #data.buttons
  local buttonData = nil
  for i = 1, total do
    buttonData = data.buttons[i]
    if(buttonData ~= nil)then
      -- TODO this will accidentally enable disabled buttons. Need to check that they are selected and disabled
      self:Enable(buttonData, true)
      buttonData.selected = false
      buttonData.invalid = true
    end
  end

  data.currentSelection = 0
  data.invalid = true
end

function EditorUI:ClearToggleGroup(data)

  -- Loop through all of the buttons and clear them
  local total = #data.buttons

  for i = 1, total do
    self:ClearButton(data.buttons[i])
  end

  -- TODO need to remove existing buttons from the tilemap
  self:ClearGroupSelections(data)

  data.buttons = {}
end

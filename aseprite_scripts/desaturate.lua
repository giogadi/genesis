local spr = app.activeSprite
if not spr then
  return app.alert("There is no active sprite")
end

local INPUT_START = 32
local COUNT = 16
local OUTPUT_START = 32

-- Each Palette:setColor() call will be grouped in one undoable
-- transaction. In this way the Edit > Undo History will contain only
-- one item that can be undone.
app.transaction(
  function()
    local pal = spr.palettes[1]
    for i = 0,COUNT-1
      -- Want to do color & 0xF0. dividing out and re-multiplying does the trick.
      local color = pal:getColor(INPUT_START+i)
      color.saturation = color.saturation / 2;
      pal:setColor(OUTPUT_START+i, color);
    end
  end)

-- Here we redraw the screen to show the new palette, in a future this
-- shouldn't be necessary, but just in case...
app.refresh()

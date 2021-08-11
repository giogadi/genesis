local spr = app.activeSprite
if not spr then
  return app.alert("There is no active sprite")
end

-- Each Palette:setColor() call will be grouped in one undoable
-- transaction. In this way the Edit > Undo History will contain only
-- one item that can be undone.
app.transaction(
  function()
    local pal = spr.palettes[1]
    for i = 0,#pal-1 do
      -- Want to do color & 0xF0. dividing out and re-multiplying does the trick.
      local color = pal:getColor(i)
      pal:setColor(i, Color{ r=(color.red // 16) * 16,
                             g=(color.green // 16) * 16,
                             b=(color.blue // 16) * 16 })
    end
  end)

-- Here we redraw the screen to show the new palette, in a future this
-- shouldn't be necessary, but just in case...
app.refresh()

-- lol this seems hacky as hell, hopefully not needed when tilemaps are out of beta
if ColorMode.TILEMAP == nil then ColorMode.TILEMAP = 4 end
assert(ColorMode.TILEMAP == 4)

local cel = app.activeCel
if not cel then
  return app.alert("There is no active image")
end

if cel.image.colorMode ~= ColorMode.TILEMAP then
    return app.alert("Can only export tilemaps!")
end

-- BEWAREEEEEEE! THIS DOES NOT AUTOMATICALLY GET THE ENTIRE CANVAS! ONLY THE OCCUPIED PART!
-- put something at each corner of the canvas to get the entire thing.
local tilemap = cel.image
for y=0,tilemap.height-1 do
    local row = ""
    for x=0,tilemap.width-1 do
        row = row .. string.format("%d,", tilemap:getPixel(x,y)+65)
    end
    print(row)
end
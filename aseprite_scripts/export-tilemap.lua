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

local tilemap = cel.image
for y=0,tilemap.height-1 do
    for x=0,tilemap.width-1 do
        -- tiles are 1-indexed, ugh. But the weird part is that they are
        -- 1-indexed NOT INCLUDING the first (transparent) tile. So as-is they
        -- are the correct 0-based index. The only exception is if there are
        -- transparent tiles on the map; they are -1 ($FFFFFFFFFFFFFFFF) so they
        -- need to be handled separately. We don't account for that yet in the game.
        print(string.format("\tdc.w $%x",tilemap:getPixel(x,y)))
    end
end
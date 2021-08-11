local spr = app.activeSprite
if not spr then
  return app.alert("There is no active sprite")
end

local tileset = spr.tilesets[1]

local grid = tileset.grid
-- size of each grid cell. So 8x8 for MD
local size = grid.tileSize;
-- #tileset is the number of tiles in the tileset.
for i = 0,#tileset-1 do
    local tile = tileset:getTile(i)
    -- assume 8x8 tiles for now.
    print(string.format("; Tile %d", i))
    for y=0,7 do
        local row = "\tdc.l $"
        for x=0,7 do
            -- keep colors in mod 16 just in case
            row = row .. string.format("%x",tile:getPixel(x,y) % 16)
        end
        print(row)
    end
end
-- print(string.format("HOWDY %d", #tileset))
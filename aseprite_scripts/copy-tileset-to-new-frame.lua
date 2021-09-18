local spr = app.activeSprite
if not spr then
  return app.alert("There is no active sprite")
end

  -- TODO: check that image is large enough to contain all tiles
  local spec = spr.spec
  spec.colorMode = ColorMode.INDEXED
  spec.width = spr.width
  spec.height = spr.height
  local image = Image(spec)
  image:clear()
  local drawX = 0
  local drawY = 0

for tilesetIx = 1,#spr.tilesets do
  local tileset = spr.tilesets[tilesetIx]
  local grid = tileset.grid
  -- size of each grid cell. So 8x8 for MD
  local tileSize = grid.tileSize;

  for i = 0,#tileset-1 do
    local tile = tileset:getTile(i)
    image:drawImage(tile, Point(drawX, drawY))
    drawX = drawX + tileSize.width
    if drawX >= spr.width then
        drawX = 0
        drawY = drawY + tileSize.height
    end
  end
end

local frame = spr:newEmptyFrame(#spr.frames+1)
local cel = spr:newCel(spr.layers[1], #spr.frames, image, Point(0,0))
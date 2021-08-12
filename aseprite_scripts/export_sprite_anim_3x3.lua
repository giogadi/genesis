-- MD sprites are column-major in how they read tiles

local spr = app.activeSprite
if not spr  then
    return app.alert("There is no active sprite")
end

if spr.colorMode ~= ColorMode.INDEXED then
    return app.alert("Color mode must be indexed")
end

-- Let's divvy up into 8x8 cells one at a time, thanks in advance. Also assume
-- that the image is divisible into 3x3 collections of cells.
if spr.height % 24 ~= 0 then
    return app.alert(string.format("height must be a multiple of 8 px (%d px)", image.height))
end
if spr.width % 24 ~= 0 then
    return app.alert(string.format("width must be a multiple of 8 px (%d px)", image.width))
end

local numTilesX = spr.width / 8
local numTilesY = spr.height / 8
for celIx,cel in ipairs(spr.cels) do
    local image = cel.image
    for tileY=0,numTilesY-1,3 do
        for tileX=0,numTilesX-1 do
            local xPos = tileX*8
            for ty=tileY,tileY+2 do
                local yPos = ty*8
                for y=yPos,yPos+7 do
                    local row = "\tdc.l $"
                    for x=xPos,xPos+7 do
                        local xInCel = x - cel.position.x
                        local yInCel = y - cel.position.y
                        if xInCel >= 0 and xInCel < image.width and yInCel >= 0 and yInCel < image.height then
                            row = row .. string.format("%x",image:getPixel(xInCel,yInCel) % 16)
                        else
                            row = row .. string.format("0")
                        end
                    end
                    print(row)
                end
            end 
        end
    end
end
local spr = app.activeSprite
if not spr  then
    return app.alert("There is no active sprite")
end

local image = app.activeImage
if image.colorMode ~= ColorMode.INDEXED then
    return app.alert("Color mode must be indexed")
end

-- Let's divvy up into 8x8 cells one at a time, thanks in advance
if spr.height % 8 ~= 0 then
    return app.alert(string.format("height must be a multiple of 8 px (%d px)", image.height))
end
if spr.width % 8 ~= 0 then
    return app.alert(string.format("width must be a multiple of 8 px (%d px)", image.width))
end

local numTilesX = spr.width / 8
local numTilesY = spr.height / 8
for tileY = 0, numTilesY-1 do
    yPos = tileY*8
    for tileX = 0, numTilesX-1 do
        -- TODO: we need to check that each individual tile has colors from only
        -- one subpalette, where a subpalette is just a 16 color region within
        -- the overall palette.
        xPos = tileX*8
        for y=yPos,yPos+7 do
            row = "\tdc.l $"
            for x=xPos,xPos+7 do
                -- doing some dumb stuff because for SOME REASON we can only
                -- access pixels through the cel, and the cel might not
                -- encompass the entire sprite. sigh.
                xInCel = x - image.cel.position.x
                yInCel = y - image.cel.position.y
                if xInCel >= 0 and xInCel < image.width and yInCel >= 0 and yInCel < image.height then
                    row = row .. string.format("%x",image:getPixel(xInCel,yInCel) % 16)
                else
                    row = row .. string.format("0");
                end
            end
            print(row)
        end 
    end
end
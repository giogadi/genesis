local spr = app.activeSprite
if not spr then
  return app.alert("There is no active sprite")
end

local pal = spr.palettes[1]
if #pal % 16 ~= 0 then
    return app.alert("palette size must be a multiple of 16")
end
local numPalettes = #pal // 16
for p=0,numPalettes-1 do
    print(string.format("; Palette %d", p))
    for i=0,15 do
        local color = pal:getColor(p*16 + i)
        print(string.format("\tdc.w $0%x%x%x", color.blue / 16, color.green / 16, color.red / 16))
    end
end
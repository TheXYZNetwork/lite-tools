include("shared.lua")

function ENT:Draw()
end

-- Create the fonts. We do it here because (for now), this is the only module that uses it. So if you yett this it gets yeeted too.
for i=30, 100 do
	surface.CreateFont("LiteTools.TextPlacements.Font."..i, {
		font = "Calibri",
		size = i,
		weight = 100
	})
end
-- We create it here for the same reason as above.
local function drawText(text, size, posx, posy, color, align1, align2)
	return draw.SimpleText(text or "Sample Text", "LiteTools.TextPlacements.Font."..(size or 30), posx or 0, posy or 0, color or color_black, align1 or TEXT_ALIGN_CENTER, align2 or TEXT_ALIGN_CENTER)
end

local ang
function ENT:DrawTranslucent()
	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000000 then return end

	if (not self.data) and (not self.requested) then
		self.requested = true
		net.Start("LiteTool.TextPlacements.RequestData")
			net.WriteEntity(self)
		net.SendToServer()

		return
	elseif (not self.data) then
		return
	end

    ang = self:GetAngles()

    -- Very yucky but this is what it takes to give you guys per line customization... You asked for this, remember that :/
    for i=1, 2 do
		cam.Start3D2D(self:GetPos(), ang, 0.17)
			for k, v in pairs(self.data.text) do
				local space = 70*#self.data.text
				local startingPos = 0-(space/2)+(70/2)
				drawText(v, self.data.size[k] or 50, 0, startingPos+((k-1)*70), self.data.color[k], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		cam.End3D2D()

		-- Rotate it so we can do it for the back too
		ang:RotateAroundAxis(ang:Right(), 180*i)
    end
end

net.Receive("LiteTool.TextPlacements.RespondData", function()
	local ent = net.ReadEntity()
	if not ent then return end

	ent.data = net.ReadTable()

	ent.requested = false
end)
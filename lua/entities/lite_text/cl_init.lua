include("shared.lua")

function ENT:Draw()
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
	cam.Start3D2D(self:GetPos(), ang, 0.17)
		for k, v in pairs(self.data.text) do
			local space = 60*#self.data.text
			local startingPos = 0-(space/2)+(60/2)
			XYZUI.DrawText(v, self.data.size[k] or 50, 0, startingPos+((k-1)*60), self.data.color[k], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Right(), 180)

	cam.Start3D2D(self:GetPos(), ang, 0.17)
		for k, v in pairs(self.data.text) do
			local space = 75*#self.data.text
			local startingPos = 0-(space/2)+(75/2)
			XYZUI.DrawText(v, self.data.size[k] or 50, 0, startingPos+((k-1)*75), self.data.color[k], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()
end

net.Receive("LiteTool.TextPlacements.RespondData", function()
	local ent = net.ReadEntity()
	if not ent then return end

	ent.data = net.ReadTable()

	ent.requested = false
end)
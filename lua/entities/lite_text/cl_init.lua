include("shared.lua")

function ENT:Draw()
end

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

    local ang = self:GetAngles()

	cam.Start3D2D(self:GetPos(), ang, 0.17)
		XYZUI.DrawLineBreakText(self.data.text, self.data.size, 0, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, self.data.color)
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Right(), 180)

	cam.Start3D2D(self:GetPos(), ang, 0.17)
		XYZUI.DrawLineBreakText(self.data.text, self.data.size, 0, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, self.data.color)
	cam.End3D2D()
end

net.Receive("LiteTool.TextPlacements.RespondData", function()
	local ent = net.ReadEntity()
	if not ent then return end

	ent.data = {}
	ent.data.text = net.ReadString()
	ent.data.color = net.ReadColor()
	ent.data.size = net.ReadInt(32)

	ent.requested = false
end)
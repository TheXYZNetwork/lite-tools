TOOL.Category = "Lite Tools"
TOOL.Name = "#tool.lite_snap.name"
TOOL.Information = {
	{name = "left"}
} 

TOOL.ClientConVar["pitch"] = "0"
TOOL.ClientConVar["yaw"] = "0"
TOOL.ClientConVar["roll"] = "0"
TOOL.ClientConVar["undo"] = "1"

if CLIENT then
	language.Add("tool.lite_snap.name", "Snap")	
	language.Add("tool.lite_snap.desc", "Snap a prop to the set rotation.")	
    language.Add("tool.lite_snap.left", "Snap the prop to the provided settings.")

	language.Add("tool.lite_snap.pitch", "Snap Pitch")
	language.Add("tool.lite_snap.pitch.help", "The pitch to snap to.")
	language.Add("tool.lite_snap.yaw", "Snap Yaw")
	language.Add("tool.lite_snap.yaw.help", "The yaw to snap to.")
	language.Add("tool.lite_snap.roll", "Snap Roll")
	language.Add("tool.lite_snap.roll.help", "The roll to snap to.")
	language.Add("tool.lite_snap.undo", "Register Undo")
	language.Add("tool.lite_snap.undo.help", "Add this action to your undo list.")
end

function TOOL:ValidateEntity(entity)
	if not IsValid(entity) then return false end
	if entity:IsPlayer() then return false end

	return true
end

function TOOL:RotateEntity(trace)
	local ent = trace.Entity
	local oldAng = ent:GetAngles()

	local curAng = ent:GetAngles()
	curAng.pitch = math.Round(curAng.pitch/math.Clamp(self:GetClientNumber("pitch"), 0, 180))*math.Clamp(self:GetClientNumber("pitch"), 0, 180)
	curAng.yaw = math.Round(curAng.yaw/math.Clamp(self:GetClientNumber("yaw"), 0, 180))*math.Clamp(self:GetClientNumber("yaw"), 0, 180)
	curAng.roll = math.Round(curAng.roll/math.Clamp(self:GetClientNumber("roll"), 0, 180))*math.Clamp(self:GetClientNumber("roll"), 0, 180)
	ent:SetAngles(curAng)

	ent:GetPhysicsObject():EnableMotion(false)

	if self:GetClientNumber("undo") == 1 then
		undo.Create("lite_snap")
			undo.SetPlayer(self:GetOwner())
			undo.AddFunction( function(_, ent, oldAng)
				if not IsValid(ent) then return end
		
				ent:SetAngles(oldAng)
			end, ent, oldAng)
		undo.Finish()
	end
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	if not self:ValidateEntity(trace.Entity) then return end
	self:RotateEntity(trace)
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {Text = "#tool.lite_snap.name", Description = "#tool.lite_snap.desc"})
	panel:AddControl("Slider", {Label = "#tool.lite_snap.pitch", Command = "lite_snap_pitch", Type = "Int", Min = 0, Max = 180})
	panel:AddControl("Slider", {Label = "#tool.lite_snap.yaw", Command = "lite_snap_yaw", Type = "Int", Min = 0, Max = 180})
	panel:AddControl("Slider", {Label = "#tool.lite_snap.roll", Command = "lite_snap_roll", Type = "Int", Min = 0, Max = 180})
	panel:AddControl("Checkbox", {Label = "#tool.lite_snap.undo", Command = "lite_snap_undo"})
end
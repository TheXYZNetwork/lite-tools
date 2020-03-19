TOOL.Category = "Lite Tools"
TOOL.Name = "#tool.lite_rotate.name"
TOOL.Information = {
	{name = "left"},
	{name = "reload"}
} 

TOOL.ClientConVar["pitch"] = "0"
TOOL.ClientConVar["yaw"] = "0"
TOOL.ClientConVar["roll"] = "0"
TOOL.ClientConVar["undo"] = "1"

if CLIENT then
	language.Add("tool.lite_rotate.name", "Rotate")	
	language.Add("tool.lite_rotate.desc", "Rotate a prop.")	
    language.Add("tool.lite_rotate.left", "Rotate the prop to the provided settings.")
    language.Add("tool.lite_rotate.reload", "Reset the prop.")

	language.Add("tool.lite_rotate.pitch", "Rotate Pitch")
	language.Add("tool.lite_rotate.pitch.help", "The pitch to rotate to.")
	language.Add("tool.lite_rotate.yaw", "Rotate Yaw")
	language.Add("tool.lite_rotate.yaw.help", "The yaw to rotate to.")
	language.Add("tool.lite_rotate.roll", "Rotate Roll")
	language.Add("tool.lite_rotate.roll.help", "The roll to rotate to.")
	language.Add("tool.lite_rotate.undo", "Register Undo")
	language.Add("tool.lite_rotate.undo.help", "Add this action to your undo list.")
end

function TOOL:ValidateEntity(entity)
	if not IsValid(entity) then return false end
	if entity:IsPlayer() then return false end

	return true
end

function TOOL:RotateEntity(trace, rotate)
	local ent = trace.Entity
	local oldAng = ent:GetAngles()
	ent:SetAngles(Angle(rotate.p or 0, rotate.y or 0, rotate.r or 0))
	
	ent:GetPhysicsObject():EnableMotion(false)

	if self:GetClientNumber("undo") == 1 then
		undo.Create("lite_rotate")
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
	self:RotateEntity(trace, {p = math.Clamp(self:GetClientNumber("pitch"), 0, 360), y = math.Clamp(self:GetClientNumber("yaw"), 0, 360), r = math.Clamp(self:GetClientNumber("roll"), 0, 360)})
end

function TOOL:Reload(trace)
	if CLIENT then return true end
	if not self:ValidateEntity(trace.Entity) then return end
	self:RotateEntity(trace, {p = 0, y = 0, r = 0})
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {Text = "#tool.lite_rotate.name", Description = "#tool.lite_rotate.desc"})
	panel:AddControl("Slider", {Label = "#tool.lite_rotate.pitch", Command = "lite_rotate_pitch", Type = "Int", Min = 0, Max = 360})
	panel:AddControl("Slider", {Label = "#tool.lite_rotate.yaw", Command = "lite_rotate_yaw", Type = "Int", Min = 0, Max = 360})
	panel:AddControl("Slider", {Label = "#tool.lite_rotate.roll", Command = "lite_rotate_roll", Type = "Int", Min = 0, Max = 360})
	panel:AddControl("Checkbox", {Label = "#tool.lite_rotate.undo", Command = "lite_rotate_undo"})
end

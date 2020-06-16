TOOL.Category = "Lite Tools"
TOOL.Name = "#tool.lite_push_pull.name"
TOOL.Information = {
	{name = "left"},
	{name = "right"}
} 

TOOL.ClientConVar["power"] = "5"
TOOL.ClientConVar["undo"] = "1"

if CLIENT then
	language.Add("tool.lite_push_pull.name", "Push/Pull")	
	language.Add("tool.lite_push_pull.desc", "Push/Pull a prop in a direction.")	
    language.Add("tool.lite_push_pull.left", "Push the entity away.")
    language.Add("tool.lite_push_pull.right", "Pull the entity closer.")

	language.Add("tool.lite_push_pull.power", "Push/Pull Power")
	language.Add("tool.lite_push_pull.power.help", "How powerful the push/pull action should be.")
	language.Add("tool.lite_push_pull.undo", "Register Undo")
	language.Add("tool.lite_push_pull.undo.help", "Add this action to your undo list.")
end

function TOOL:ValidateEntity(entity)
	if not IsValid(entity) then return false end
	if entity:IsPlayer() then return false end

	return true
end

function TOOL:MoveEntity(trace, dir)
	local ent = trace.Entity
	local phys = ent:GetPhysicsObjectNum(trace.PhysicsBone)
	local oldPos = phys:GetPos()
	local target = phys:GetPos() + trace.HitNormal * math.Clamp(self:GetClientNumber("power"), 0, 50) * dir
	phys:SetPos(target)
	phys:Wake()

--	if not util.IsInWorld(ent:GetPos()) then
--		ent:Remove()
--	end
	
	ent:GetPhysicsObject():EnableMotion(false)

	if self:GetClientNumber("undo") == 1 then
		undo.Create("lite_push_pull")
			undo.SetPlayer(self:GetOwner())
			undo.AddFunction( function(_, phys, oldPos)
				if not IsValid(phys) then return end
		
				phys:SetPos(oldPos)
				phys:Wake()
			end, phys, oldPos)
		undo.Finish()
	end
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	if not self:ValidateEntity(trace.Entity) then return end
	self:MoveEntity(trace, -1)

	return true
end

function TOOL:RightClick(trace)
	if CLIENT then return true end
	if not self:ValidateEntity(trace.Entity) then return end
	self:MoveEntity(trace, 1)
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {Text = "#tool.lite_push_pull.name", Description = "#tool.lite_push_pull.desc"})
	panel:AddControl("Slider", {Label = "#tool.lite_push_pull.power", Command = "lite_push_pull_power", Type = "Float", Min = 0, Max = 50})
	panel:AddControl("Checkbox", {Label = "#tool.lite_push_pull.undo", Command = "lite_push_pull_undo"})
end

TOOL.Category = "Lite Tools"
TOOL.Name = "#tool.lite_stacker.name"
TOOL.Information = {
	{name = "left"}
} 

TOOL.ClientConVar["distance"] = "40"
TOOL.ClientConVar["direction"] = "up"
TOOL.ClientConVar["count"] = "1"

if CLIENT then
	language.Add("tool.lite_stacker.name", "Stacker")	
	language.Add("tool.lite_stacker.desc", "Stack props in any direction.")	
    language.Add("tool.lite_stacker.left", "Stack the prop in the configured direction.")

	language.Add("tool.lite_stacker.distance", "Stack Distance")
	language.Add("tool.lite_stacker.distance.help", "The distance from the target prop.")
	language.Add("tool.lite_stacker.direction", "Stack Direction")
	language.Add("tool.lite_stacker.direction.help", "The direction to stack in.")
		language.Add("tool.lite_stacker.direction.up", "Up")
		language.Add("tool.lite_stacker.direction.forward", "Forward")
		language.Add("tool.lite_stacker.direction.right", "Right")
	language.Add("tool.lite_stacker.count", "Stack Count")
	language.Add("tool.lite_stacker.count.help", "The amount to stack.")
end

function TOOL:GetDistanceToAdd(direction, ent)
	if direction == "up" then
		return ent:GetUp() * (math.abs(ent:OBBMins().z - ent:OBBMaxs().z) - 0.5) + (ent:GetUp() * math.Clamp(self:GetClientNumber("distance"), -200, 200))
	elseif direction == "down" then
		return -ent:GetUp() * (math.abs(ent:OBBMins().z - ent:OBBMaxs().z) - 0.5) + (-ent:GetUp() * math.Clamp(self:GetClientNumber("distance"), -200, 200))
	elseif direction == "forward" then
		return ent:GetForward() * (math.abs(ent:OBBMins().x - ent:OBBMaxs().x) - 0.5) + (ent:GetForward() * math.Clamp(self:GetClientNumber("distance"), -200, 200))
	elseif direction == "back" then
		return -ent:GetForward() * (math.abs(ent:OBBMins().x - ent:OBBMaxs().x) - 0.5) + (-ent:GetForward() * math.Clamp(self:GetClientNumber("distance"), -200, 200))
	elseif direction == "right" then
		return ent:GetRight() * (math.abs(ent:OBBMins().y - ent:OBBMaxs().y) - 0.5) + (ent:GetRight() * math.Clamp(self:GetClientNumber("distance"), -200, 200))
	elseif direction == "left" then
		return -ent:GetRight() * (math.abs(ent:OBBMins().y - ent:OBBMaxs().y) - 0.5) + (-ent:GetRight() * math.Clamp(self:GetClientNumber("distance"), -200, 200))
	end
end

function TOOL:ValidateEntity(entity)
	if not IsValid(entity) then return false end
	if entity:IsPlayer() then return false end
	if not IsEntity(entity) then return false end

	return true
end

function TOOL:CreateEntity(entity, newPos)
	local newEnt = ents.Create("prop_physics")
	newEnt:SetModel(entity:GetModel())
	newEnt:SetPos(newPos)
	newEnt:SetAngles(entity:GetAngles())
	newEnt:SetSkin(entity:GetSkin())
	newEnt:SetMaterial(entity:GetMaterial())
	newEnt:SetColor(entity:GetColor())
	newEnt:Spawn()

	return newEnt
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	local ent = trace.Entity
	local ply = self:GetOwner()

	if not self:ValidateEntity(ent) then return end

	local targetEnt = ent
	targetEnt:GetPhysicsObject():EnableMotion(false)
	-- Start the undo process
	undo.Create("lite_stacker")
	for i = 1, math.Clamp(self:GetClientNumber("count"), 1, 5) do

		if not ply:CheckLimit("props") then break end -- Check prop limit
		if hook.Run("PlayerSpawnProp", ply, ent:GetModel()) == false then break end  -- Check if they're allowed to spawn it
		
		local newPos = targetEnt:GetPos() + self:GetDistanceToAdd(self:GetClientInfo("direction"), ent)

		if not util.IsInWorld(newPos) then break end

		local newEnt = self:CreateEntity(targetEnt, newPos)
		if not IsValid(newEnt) then break end

		-- Physgun freeze the entity
		newEnt:GetPhysicsObject():EnableMotion(false)

		targetEnt = newEnt


		if hook.Run("StackerEntity", newEnt, ply) ~= nil then break end -- Used for anti-propspams
		if hook.Run("PlayerSpawnedProp", ply, newEnt:GetModel(), newEnt) ~= nil then break end

		undo.AddEntity(newEnt)
		ply:AddCleanup("props", newEnt)
	end

	undo.SetPlayer( ply )
	undo.Finish()

	return true
end


function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {Text = "#tool.lite_stacker.name", Description = "#tool.lite_stacker.desc"})
	panel:AddControl("Slider", {Label = "#tool.lite_stacker.distance", Command = "lite_stacker_distance", Type = "Float", Min = -200, Max = 200})
	panel:AddControl("Slider", {Label = "#tool.lite_stacker.count", Command = "lite_stacker_count", Type = "Int", Min = 1, Max = 5})

	local combo = panel:AddControl("ListBox", {Label = "#tool.lite_stacker.direction"})
	combo:AddOption("Up", {lite_stacker_direction = "up"})
	combo:AddOption("Down", {lite_stacker_direction = "down"})
	combo:AddOption("Front", {lite_stacker_direction = "forward"})
	combo:AddOption("Back", {lite_stacker_direction = "back"})
	combo:AddOption("Left", {lite_stacker_direction = "left"})
	combo:AddOption("Right", {lite_stacker_direction = "right"})
end

if CLIENT then
	--local currentEnt
	function TOOL:Think()
		local ply = self:GetOwner()
		local ent = ply:GetEyeTrace().Entity

		if not self:ValidateEntity(ent) then
			if IsValid(currentEnt) then
				currentEnt:Remove()
			end
			return
		end

		if not IsValid(currentEnt) then
			currentEnt = ents.CreateClientProp()
			currentEnt:SetModel(ent:GetModel())
			currentEnt:SetColor(Color(255, 255, 255, 155))
			currentEnt:SetRenderMode(RENDERMODE_TRANSALPHA )
			currentEnt:Spawn()
		end

		local newPos = ent:GetPos() + self:GetDistanceToAdd(self:GetClientInfo("direction"), ent)

		currentEnt:SetPos(newPos)
		currentEnt:SetAngles(ent:GetAngles())
	end

	function TOOL:Holster()
		if IsValid(currentEnt) then
			currentEnt:Remove()
			currentEnt = nil
		end
	end
end
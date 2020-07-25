TOOL.Category = "Lite Tools"
TOOL.Name = "#tool.lite_shadow_remover.name"
TOOL.Information = {
	{name = "left"},
	{name = "right"}
}

TOOL.ClientConVar["strength"] = "100"

local propCache = {}
if SERVER then
	util.AddNetworkString("LiteTool.ShadowRemover.PlayerInitialSpawn")
	util.AddNetworkString("LiteTool.ShadowRemover.ApplyShadow")
	util.AddNetworkString("LiteTool.ShadowRemover.ResetShadow")

	hook.Add("PlayerInitialSpawn", "LiteTools.ShadowRemover.LoadProps", function(ply)
		timer.Simple(5, function()
			if not IsValid(ply) then return end

			net.Start("LiteTool.ShadowRemover.PlayerInitialSpawn")
				net.WriteTable(propCache)
			net.Send(ply)
		end)
	end)
end

if CLIENT then
	language.Add("tool.lite_shadow_remover.name", "Shadow Remover")	
	language.Add("tool.lite_shadow_remover.desc", "Remove shadows from an object.")	
    language.Add("tool.lite_shadow_remover.left", "Apply the shadow remover filter.")
    language.Add("tool.lite_shadow_remover.right", "Reset the shadow remover filter.")

	language.Add("tool.lite_shadow_remover.strength", "Brightness Strength")
	language.Add("tool.lite_shadow_remover.strength.help", "How bright the object should be as a %.")
end

function TOOL:BuildBrightnessColor(entity)
	local h, s, v = ColorToHSV(entity:GetColor())
	v = math.Clamp(self:GetClientNumber("strength"), 0, 100)/100

	return HSVToColor(h, s, v)
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end

	local ent = trace.Entity

	propCache[ent] = true
	ent.oldColor = ent.oldColor or ent:GetColor()
	ent:SetColor(ent.oldColor)
	local newColor = self:BuildBrightnessColor(ent)
	ent:SetColor(newColor)

	net.Start("LiteTool.ShadowRemover.ApplyShadow")
		net.WriteEntity(ent)
	net.Broadcast()

	return true
end
function TOOL:RightClick(trace)
	if CLIENT then return true end

	local ent = trace.Entity

	propCache[ent] = nil
	ent:SetColor(ent.oldColor)
	ent.oldColor = nil

	net.Start("LiteTool.ShadowRemover.ResetShadow")
		net.WriteEntity(ent)
	net.Broadcast()

	return true
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {Text = "#tool.lite_shadow_remover.name", Description = "#tool.lite_shadow_remover.desc"})
	panel:AddControl("Slider", {Label = "#tool.lite_shadow_remover.strength", Command = "lite_shadow_remover_strength", Type = "Int", Min = 0, Max = 100})
end


if CLIENT then
	net.Receive("LiteTool.ShadowRemover.ApplyShadow", function()
		local ent = net.ReadEntity()
		ent.RenderOverride = function(self) render.SuppressEngineLighting(true) self:DrawModel() render.SuppressEngineLighting(false) end
	end)

	net.Receive("LiteTool.ShadowRemover.ResetShadow", function()
		local ent = net.ReadEntity()
		ent.RenderOverride = function(self) self:DrawModel() end
	end)

	net.Receive("LiteTool.ShadowRemover.PlayerInitialSpawn", function()
		local props = net.ReadTable()

		for k, v in pairs(props) do
			k.RenderOverride = function(self) render.SuppressEngineLighting(true) self:DrawModel() render.SuppressEngineLighting(false) end
		end
	end)
end
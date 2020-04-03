AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("LiteTool.TextPlacements.RequestData")
util.AddNetworkString("LiteTool.TextPlacements.RespondData")

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate1x1.mdl")

	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:DrawShadow(false)
	self:SetMaterial("models/effects/vol_light001")
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	self.data = {}
	self.data.text = {"Placeholder Text"}
	self.data.color = {Color(255, 255, 255)}
	self.data.size = {50}
end


function ENT:SetText(line, text)
	self.data.text[line] = text
end

function ENT:SetTextColor(line, color)
	self.data.color[line] = color
end

function ENT:SetTextSize(line, size)
	self.data.size[line] = size
end

net.Receive("LiteTool.TextPlacements.RequestData", function(_, ply)
	local ent = net.ReadEntity()
	if not ent then return end

	net.Start("LiteTool.TextPlacements.RespondData")
		net.WriteEntity(ent)
		net.WriteTable(ent.data)
	net.Send(ply)
end)

hook.Add("CanTool", "LiteTool.TextPlacements.BlockToolgun", function(ply, tr, tool)
	if (tr.Entity and (tr.Entity:GetClass() == "lite_text")) and (not (tool == "remover")) then return false end
end)
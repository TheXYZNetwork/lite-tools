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
	self.data.text = "Placeholder Text"
	self.data.color = Color(255, 255, 255)
	self.data.size = 50
end


function ENT:SetText(text)
	self.data.text = text
end

function ENT:SetTextColor(color)
	self.data.color = color
end

function ENT:SetTextSize(size)
	self.data.size = size
end

net.Receive("LiteTool.TextPlacements.RequestData", function(_, ply)
	local ent = net.ReadEntity()
	if not ent then return end

	net.Start("LiteTool.TextPlacements.RespondData")
		net.WriteEntity(ent)
		net.WriteString(ent.data.text)
		net.WriteColor(ent.data.color)
		net.WriteInt(ent.data.size, 32)
	net.Send(ply)
end)

--hook.Add("CanTool", "LiteTool.TextPlacements.BlockToolgun", function(ply, tr, tool)
--	if (tr.Entity and (ty.Entity:GetClass() == "lite_text")) and (not (tool == "remover")) then return false end
--end)
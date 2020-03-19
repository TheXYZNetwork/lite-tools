TOOL.Category = "Lite Tools"
TOOL.Name = "#tool.lite_text_placements.name"
TOOL.Information = {
	{name = "left"}
} 

TOOL.ClientConVar["r"] = "255"
TOOL.ClientConVar["g"] = "255"
TOOL.ClientConVar["b"] = "255"
TOOL.ClientConVar["a"] = "255"
TOOL.ClientConVar["size"] = "50"
for i=1, 5 do
	TOOL.ClientConVar["text"..i] = ""
end

if SERVER then
	CreateConVar("sbox_maxtextplacements", "3", {FCVAR_NOTIFY, FCVAR_REPLICATED})	
end

if CLIENT then
	language.Add("tool.lite_text_placements.name", "Text Placement")	
	language.Add("tool.lite_text_placements.desc", "Place text on a wall.")	
    language.Add("tool.lite_text_placements.left", "Place the text.")
    language.Add("tool.lite_text_placements.right", "Update existing text.")

	language.Add("tool.lite_text_placements.color", "Text Color")
	language.Add("tool.lite_text_placements.color.help", "The color of the text.")
	language.Add("tool.lite_text_placements.size", "Text Size")
	language.Add("tool.lite_text_placements.size.help", "The size of the text.")
	for i=1, 5 do
		language.Add("tool.lite_text_placements.text"..i, "Line "..i)
		language.Add("tool.lite_text_placements.text"..i..".help", "The text for line "..i..".")
	end

	language.Add("SBoxLimit.textplacements", "You've hit the text placement limit!")
	language.Add("SBoxLimit_textplacements", "You've hit the text placement limit!")
end

function TOOL:BuildText()
	local str = ""
	for i=1, 5 do
		str = str.."\n"..string.sub(string.Replace(self:GetClientInfo("text"..i), "\n", ""), 1, 30)
	end

	str = string.Trim(str, "\n")

	if str == "" then return false end

	return str
end

function TOOL:CreateEntity(trace)
	local newEnt = ents.Create("lite_text")
	newEnt:SetPos(trace.HitPos)

	local angle = trace.HitNormal:Angle()
	angle:RotateAroundAxis(trace.HitNormal:Angle():Right(), -90)
	angle:RotateAroundAxis(trace.HitNormal:Angle():Forward(), 90)
	newEnt:SetAngles(angle)

	newEnt:Spawn()
	newEnt:Activate()

	return newEnt
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	local ply = self:GetOwner()

	if not ply:CheckLimit("textplacements") then return end
	local text = self:BuildText()
	if not text then return end

	local ent = self:CreateEntity(trace)
	ent:SetText(text)
	ent:SetTextColor(Color(math.Clamp(self:GetClientNumber("r", 255), 0, 255), math.Clamp(self:GetClientNumber("g", 255), 0, 255), math.Clamp(self:GetClientNumber("b", 255), 0, 255)))
	ent:SetTextSize(math.Clamp(self:GetClientNumber("size", 50), 30, 100))

	ply:AddCount("textplacements", ent)
	ply:AddCleanup("textplacements", ent)
	undo.Create("lite_text_placements")
		undo.AddEntity(ent)
		undo.SetPlayer(ply)
	undo.Finish()

	return true
end


function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {Text = "#tool.lite_text_placements.name", Description = "#tool.lite_text_placements.desc"})
	panel:AddControl("Color", {Label = "#tool.lite_text_placements.color", Red = "lite_text_placements_r", Green = "lite_text_placements_g", Blue = "lite_text_placements_b", Alpha = "lite_text_placements_a"})
	panel:AddControl("Slider", {Label = "#tool.lite_text_placements.size", Command = "lite_text_placements_size", Type = "Int", Min = 30, Max = 100})
	for i=1, 5 do
		panel:AddControl("textbox", {Label = "#tool.lite_text_placements.text"..i, Command = "lite_text_placements_text"..i, MaxLenth = "30"})
	end
end
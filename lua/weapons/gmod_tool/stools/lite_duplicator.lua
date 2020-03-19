-- Define these!
TOOL.Category = "Lite Tools" -- Name of the category
TOOL.Name = "Duplicator" -- Name to display. # means it will be translated ( see below )

-- An example clientside convar
TOOL.ClientConVar["CLIENTSIDE"] = "default"
-- An example serverside convar
TOOL.ServerConVar["SERVERSIDE"] = "default"

-- This function/hook is called when the player presses their left click
function TOOL:LeftClick(trace)
	Msg("PRIMARY FIRE\n")
end

-- This function/hook is called when the player presses their right click
function TOOL:RightClick(trace)
	Msg("ALT FIRE\n")
end

-- This function/hook is called when the player presses their reload key
function TOOL:Reload(trace)
	-- The SWEP doesn't reload so this does nothing :(
	Msg("RELOAD\n")
end

-- This function/hook is called every frame on client and every tick on the server
function TOOL:Think()
end
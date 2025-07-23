include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

--[[
function ENT:Initialize()
	self.PixVis = util.GetPixelVisibleHandle()
end
]]

function ENT:Draw()
	self.BaseClass.Draw( self )
end

function ENT:GetOverlayText()
	return ("Sound level: %.2f dB, %s\n(%s)"):format( self:GetSoundLevel() or 0, self:GetOn() and "On" or "Off", self:GetPlayerName() )
end
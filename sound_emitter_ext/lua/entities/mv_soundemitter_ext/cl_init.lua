include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

local matLight 	= Material( "sprites/light_ignorez" )
local matBeam	= Material( "effects/lamp_beam" )

function ENT:Initialize()
	self.PixVis = util.GetPixelVisibleHandle()
end

function ENT:Draw()
	self.BaseClass.Draw( self )
end

function ENT:GetOverlayText()
	return "Sound level: "..string.format("%.2f", self:GetSoundLevel() or 0).."dB\n("..self:GetPlayerName()..")"
end
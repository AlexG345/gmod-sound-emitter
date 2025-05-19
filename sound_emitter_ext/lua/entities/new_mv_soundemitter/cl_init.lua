include('shared.lua')

ENT.RenderGroup 	= RENDERGROUP_OPAQUE

local matLight 		= Material( "sprites/light_ignorez" )
local matBeam		= Material( "effects/lamp_beam" )

function ENT:Initialize()
	self.PixVis = util.GetPixelVisibleHandle()
end

function ENT:Draw()
	self.BaseClass.Draw( self )
end

function ENT:Think() end

function ENT:GetOverlayText()
	return self:GetSound().."\n("..self:GetPlayerName()..")"
end
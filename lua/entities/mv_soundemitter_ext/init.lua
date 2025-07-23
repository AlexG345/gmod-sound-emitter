AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

--[[-------------------------------------------------------
   Name: Initialize
---------------------------------------------------------]]
function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE ) -- Unreliable
	self.soundRF = RecipientFilter()
	
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end

end

--[[-------------------------------------------------------
   Name: Network things
---------------------------------------------------------]]

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


--[[-------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------]]
function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
	if self:GetDamageActivate() then
		if self:GetDamageToggle() then
			self:ToggleSound()
		elseif not self:GetOn() then
			self:PreEmit()
		end
	end
end

--[[-------------------------------------------------------
   Name: OnRemove
---------------------------------------------------------]]
function ENT:OnRemove()
	self:StopEmit()
end


--[[-------------------------------------------------------
   Name: Emit Functions
---------------------------------------------------------]]
function ENT:StartEmit()
	
	if not self then return end

	self.isFadingOut = false
	self:StopMySound()
	-- I tried many methods (e.g. a pool of csoundpatches) but this is the only one which keeps sound script randomness,
	-- up-to-date recipient filters (RF) even during looping, and custom pitch/volume.
	-- https://github.com/Facepunch/garrysmod-issues/issues/5877 exact same problem I think.
	
	if self.soundRF then self.soundRF:AddPAS( self:GetPos() ) end

	local snd = self:GetSound()
	local sndscript = snd and sound.GetProperties( snd )
	local pitch
	local fadeIn = self:GetFadeIn()
	local volume = self:GetVolume()
	local startVolume = fadeIn > 0 and 0 or volume

	if sndscript then
		if istable(sndscript.sound) then 
			snd = sndscript.sound[math.random( #sndscript.sound )]--more efficient than table.Random( sndscript.sound )
		else
			snd = sndscript.sound
		end

		if self:GetUseScriptPitch() then
			pitch = sndscript.pitch
			if istable( pitch ) then
				pitch = math.random( pitch[1] or pitch.pitchstart, pitch[2] or pitch.pitchend )
			end
		end
	end

	pitch = pitch or self:GetPitch()

	self.MySound = CreateSound( self, snd or "common/NULL.WAV", self.soundRF )
	self.MySound:SetSoundLevel( self:GetSoundLevel() )
	self.MySound:SetDSP( self:GetDSP() )
	self.MySound:PlayEx( startVolume, pitch )
	if startVolume != volume then self.MySound:ChangeVolume( volume, fadeIn ) end

	
	-- We can calculate the duration here since we've finally picked an exact sound
	-- Maybe we should save length per sound in a table instead of recalculating each time...
	local playLength	= self:GetAutoLength() and MSECalculateDuration( snd, pitch ) or self:GetLength() or 0
	local loopLength	= self:GetSameLength() and playLength or self:GetLoopLength() or 0
	local fadeOut		= self:GetFadeOut() or 0
	local preFadeOut	= math.max( 0, playLength - fadeOut )
	local isFinite, isLooping = playLength > 0, loopLength > 0
	local willFade		= fadeOut > 0 and isFinite and ( preFadeOut < loopLength or not isLooping )
	local willStop		= isFinite and ( playLength < loopLength or not isLooping )
	local entindex		= self:EntIndex()
	local emitter		= self

	if willFade then
		if preFadeOut > 0 then
			timer.Create( "SoundFadeOut_"..entindex, preFadeOut, 1, function()
				emitter:FadeOut( fadeOut )
			end )
		else emitter:FadeOut( fadeOut ) end
	end

	if willStop then
		local f = isLooping and self.StopMySound or self.StopEmit
		if playLength > 0 then
			timer.Create( "SoundStop_"..entindex, playLength, 1, function()
				f( emitter )
			end )
		else f( emitter ) end
	end

	if isLooping then
		timer.Create( "SoundStart_"..entindex, loopLength, 1, function()
			emitter:StartEmit()
		end )
	end
end


function ENT:PreEmit()
	
	self:ClearTimers()
	
	if self:GetOn() then
		self:StopEmit()
	else
		self:ClearTimers()
	end

	self.isFadingOut = false
	self:SetOn( true )
	local delay = self:GetDelay()
	if delay <= 0 then self:StartEmit() return end

	local emitter = self
	timer.Create("SoundStart_"..self:EntIndex(), delay, 1, function()
		emitter:StartEmit()
	end)
end



function ENT:FadeOut( dt )
	self.isFadingOut = true
	if self.MySound then self.MySound:FadeOut( dt or self:GetFadeOut() ) end
end


function ENT:StopMySound()
	if self.MySound then self.MySound:Stop() end
end


function ENT:Off()
	self:SetOn( false )
	self:ClearTimers()
end


function ENT:StopEmit()
	self:Off()
	self:StopMySound()
end


function ENT:FadeOutAndStopEmit( dt1, dt2 )

	if not self.isFadingOut then self:FadeOut( dt1 ) end

	local entindex = self:EntIndex()
	timer.Remove("SoundStart_"..entindex)
	timer.Remove("SoundFadeOut_"..entindex)
	self:DelayStopEmit( dt, entindex )
end

function ENT:DelayStopEmit( dt, entindex )
	dt = dt or self:GetLength()
	if dt > 0 then
		local emitter = self
		local id = "SoundStop_"..( entindex or self:EntIndex() )
		if not timer.Exists( id ) or timer.TimeLeft( id ) > dt then
			timer.Create( id, dt, 1, function()
				emitter:StopEmit()
			end )
		end
	else
		self:StopEmit()
	end	
end


function ENT:ToggleSound()
	if self:GetOn() and not self:GetNoStopToggle() then
		self:Off()
		self:FadeOutAndStopEmit()
	else
		self:PreEmit()
	end
end


function ENT:ClearTimers()
	local entindex = self:EntIndex()
	timer.Remove("SoundStart_"..entindex)
	timer.Remove("SoundFadeOut_"..entindex)
	timer.Remove("SoundStop_"..entindex)
end

function ENT:Use( activator, caller, useType, value )
	if self:GetToggle() then
		if useType == USE_ON then self:ToggleSound() end
	else
		local on, off = USE_ON, USE_OFF
		if self:GetReverse() then on, off = off, on end
		if useType == on then self:PreEmit() end
		if useType == off then self:FadeOutAndStopEmit() end
	end

	return true
end


--[[-------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------]]
local function Down( pl, ent )
	if not ent:IsValid() then return false end

	if ent:GetToggle() then ent:ToggleSound() else ent:PreEmit() end

	return true
end

local function Up( pl, ent )
	if not ent:IsValid() then return false end

	if ent:GetOn() and not ent:GetToggle() then ent:FadeOutAndStopEmit() end

	return true
end

function ENT:UpdateNumpadActions()
	if self.impulseDown then numpad.Remove( self.impulseDown ) end
	if self.impulseUp   then numpad.Remove( self.impulseUp	) end

	local key = self:GetKey()
	if not key then return end

	local ply = self:GetPlayer()
	if not ply then return end

	local act1, act2 = "mv_soundemitter_Down", "mv_soundemitter_Up"
	if self:GetReverse() then act1, act2 = act2, act1 end

	self.impulseDown = numpad.OnDown( ply, key, act1, self )
	self.impulseUp	 = numpad.OnUp(	  ply, key, act2, self )
end

numpad.Register( "mv_soundemitter_Down", Down )
numpad.Register( "mv_soundemitter_Up", Up )
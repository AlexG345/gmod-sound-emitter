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
	if not self.SetOn then return end
	self:StopEmit()
end


--[[-------------------------------------------------------
   Name: Emit Functions
---------------------------------------------------------]]
function ENT:StartEmit()
	
	if not self then return end

	self:StopMySound()
	-- I tried many methods (e.g. a pool of csoundpatches) but this is the only one which keeps sound script randomness,
	-- up-to-date recipient filters (RF) even during looping, and custom pitch/volume.
	-- https://github.com/Facepunch/garrysmod-issues/issues/5877 exact same problem I think.
	
	if self.soundRF then self.soundRF:AddPAS( self:GetPos() ) end

	local snd = self:GetSound()
	local sndscript
	local pitch = self:GetPitch()
	local fadeIn = self:GetFadeIn()
	local volume = self:GetVolume()
	local startVolume = fadeIn > 0 and 0 or volume

	if snd and sound.GetProperties( snd ) then
		sndscript = sound.GetProperties( snd )
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

	self.MySound = CreateSound( self, snd or self.NullSound, self.soundRF )
	self.MySound:SetSoundLevel( self:GetSoundLevel() )
	self.MySound:SetDSP( self:GetDSP() )
	self.MySound:PlayEx( startVolume, pitch )
	if startVolume != volume then self.MySound:ChangeVolume( volume, fadeIn ) end

	
	-- We can calculate the duration here since we've finally picked an exact sound
	-- Maybe we should save length per sound in a table instead of recalculating each time...
	local length = self:GetAutoLength() and MSECalculateDuration( snd, pitch ) or self:GetLength() or 0
	local loopLength = self:GetSameLength() and length or self:GetLoopLength() or 0
	local entindex = self:EntIndex()
	local emitter = self

	if loopLength > 0 then
		if length > 0 and length < loopLength then
			timer.Create("SoundStop_"..entindex, length, 1, function()
				emitter:FadeOut( false ) -- stay enabled
			end)
		end
		timer.Create("SoundStart_"..entindex, loopLength, 1, function()
			emitter:StartEmit()
		end)
	elseif length > 0 then 
		timer.Create("SoundStop_"..entindex, length, 1, function()
			emitter:FadeOut( true )
		end)
	end
end


function ENT:PreEmit()
	
	if self:GetOn() then
		self:StopEmit()
	else
		self:ClearTimers()
	end

	self:SetOn( true )
	local delay = self:GetDelay()
	if delay <= 0 then self:StartEmit() return end

	local emitter = self
	local entindex = self:EntIndex()

	timer.Create("SoundStart_"..entindex, delay, 1, function()
		emitter:StartEmit()
	end)
end

function ENT:StopMySound()
	if self.MySound then self.MySound:Stop() end
end

function ENT:FadeOut( stopEmit )
	
	if stopEmit then
		self:SetOn( false )
		self:ClearTimers()
	end

	local fadeOut = self:GetFadeOut()
	if self.MySound and fadeOut > 0 then
		self.MySound:FadeOut( fadeOut )
		
		if stopEmit then
			local emitter = self
			local entindex = self:EntIndex()

			timer.Create("SoundStop_"..entindex, fadeOut, 1, function()
				emitter:StopEmit()
			end)
		end
		
		return
	end

	if stopEmit then
		self:StopEmit()
	else
		self:StopMySound()
	end
end


function ENT:StopEmit()
	self:SetOn( false )
	self:ClearTimers()
	self:StopMySound()
end

function ENT:ToggleSound()
	if self:GetOn() and not self:GetNoStopToggle() then
		self:FadeOut( true )
	else
		self:PreEmit()
	end
end

function ENT:ClearTimers()
	local entindex = self:EntIndex()
	timer.Remove("SoundStart_"..entindex)
	timer.Remove("SoundStop_"..entindex)
end

function ENT:Use( activator, caller, useType, value )
	if self:GetToggle() then
		if useType == USE_ON then self:ToggleSound() end
	else
		local a, b = USE_ON, USE_OFF
		if self:GetReverse() then a, b = b, a end
		if useType == a then self:PreEmit() end
		if useType == b then self:FadeOut( true ) end
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

	if not ent:GetToggle() then ent:FadeOut( true ) end

	return true
end

function ENT:UpdateNumpadActions( )
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
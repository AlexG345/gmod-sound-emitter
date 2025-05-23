AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( ONOFF_USE ) -- Unreliable
	self.soundRF = RecipientFilter()
	
	self:SetOn(false)

	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end

end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
	if self:GetDamageActivate() then
		if self:GetDamageToggle() then
			self:ToggleSound()
		elseif not self:GetOn() then
			self:PreEmit()
		end
	end
end

/*---------------------------------------------------------
   Name: OnRemove
---------------------------------------------------------*/
function ENT:OnRemove()
	self:StopEmit()
end


/*---------------------------------------------------------
   Name: Emit Functions
---------------------------------------------------------*/
function ENT:StartEmit()
	
	if not self then return end

	if self.MySound then self.MySound:Stop() end
	-- EmitSound won't let you change the pitch of sound scripts.
	-- We use CreateSound instead, it picks a random sound from the sound script.
	self.MySound = CreateSound( self.Entity, self:GetSound() or self.NullSound, self.soundRF )
	self.MySound:PlayEx( self:GetVolume(), self:GetPitch() )
	
	local length = self:GetLength() or 0
	if length <= 0 then return end

	local entindex = self.Entity:EntIndex()
	local emitter = self
	if self:GetLooping() then
		timer.Create("SoundStart_"..entindex, length, 1, function()
			emitter:StartEmit()
		end)
	else
		timer.Create("SoundStop_"..entindex, length, 1, function()
			emitter:StopEmit()
		end)
	end
end


function ENT:PreEmit()
	if self:GetOn() then self:StopEmit() end

	-- Mostly fixes original addon issue with sound distance
	-- Looping sounds might not be heard by players who joined while they are looping.
	if self.soundRF then self.soundRF:AddPAS( self.Entity:GetPos() ) end

	self:SetOn( true )
	local delay = self:GetDelay()
	if delay <= 0 then self:StartEmit() return end

	local entindex = self.Entity:EntIndex()
	local emitter = self
	timer.Create("SoundStart_"..entindex, delay, 1, function()
		emitter:StartEmit()
	end)
end

function ENT:StopEmit()
	self:SetOn( false )
	self:ClearTimers()
	if self.MySound then self.MySound:Stop() end
end

function ENT:ToggleSound()
	if self:GetOn() then
		self:StopEmit()
	else
		self:PreEmit()
	end
end

function ENT:ClearTimers()
	local entindex = self.Entity:EntIndex()
	timer.Destroy("SoundStart_"..entindex)
	timer.Destroy("SoundStop_"..entindex)
end

function ENT:Use( activator, caller, useType, value )
	if self:GetToggle() then
		if useType == USE_ON then self:ToggleSound() end
	else
		local a, b = USE_ON, USE_OFF
		if self:GetReverse() then a, b = b, a end
		if useType == a then self:PreEmit() end
		if useType == b then self:StopEmit() end
	end

	return true
end


/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/
local function Down( pl, ent )
	if not ent:IsValid() then return false end

	if ent:GetToggle() then ent:ToggleSound() else ent:PreEmit() end

	return true
end

local function Up( pl, ent )
	if not ent:IsValid() then return false end

	if not ent:GetToggle() then ent:StopEmit() end

	return true
end

numpad.Register( "mv_soundemitter_Down", Down )
numpad.Register( "mv_soundemitter_Up", Up )
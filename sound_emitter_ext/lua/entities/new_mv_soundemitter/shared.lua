ENT.Type 				= "anim"
ENT.Base 				= "base_gmodentity"

ENT.PrintName			= "MV Sound Emitter"
ENT.Author				= "MajorVictory (fixed by Alex)"
ENT.Contact				= ""
ENT.Purpose				= "To annoy others with your shitty music."
ENT.Instructions		= ""

ENT.ClassNameOverride	= "mv_soundemitter" -- Folder name is new_mv_soundemitter (for original addon overriding)
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.NullSound = Sound("common/NULL.WAV")

ENT.TYPE_STRING 	= 0
ENT.TYPE_BOOL		= 1
ENT.TYPE_INT		= 2
ENT.TYPE_FLOAT		= 3
-- AccessorFuncNW doesn't work on SENTs
-- so i'll just make my own local one, with emulated constants :P
-- Angle, Vector, and Color not included, do it yourself
function ENT:AccessorFuncENT( name, varname, varDefault, iType )
	iType = iType or self.TYPE_STRING

	if iType == self.TYPE_STRING then
		self["Set"..name] = function (self, v) self.Entity:SetNWString(varname,tostring(v)) end
		self["Get"..name] = function (self, v) return self.Entity:GetNWString(varname) or varDefault end
		return
	end
	if iType == self.TYPE_BOOL then
		self["Set"..name] = function (self, v) self.Entity:SetNWBool(varname,tobool(v)) end
		self["Get"..name] = function (self, v) local v=self.Entity:GetNWBool(varname) if v ~= nil then return v end return varDefault end
		return
	end
	if iType == self.TYPE_INT then
		self["Set"..name] = function (self, v) self.Entity:SetNWInt(varname,tonumber(v)) end
		self["Get"..name] = function (self, v) return self.Entity:GetNWInt(varname) or varDefault end
		return
	end
	if iType == self.TYPE_FLOAT then
		self["Set"..name] = function (self, v) self.Entity:SetNWFloat(varname,tonumber(v)) end
		self["Get"..name] = function (self, v) return self.Entity:GetNWFloat(varname) or varDefault end
		return
	end
end

ENT:AccessorFuncENT( "InternalSound", "SoundFile", "common/NULL.WAV", ENT.TYPE_STRING )
ENT:AccessorFuncENT( "Length", "Length", -1, ENT.TYPE_FLOAT )
ENT:AccessorFuncENT( "Looping", "Looping", false, ENT.TYPE_BOOL )
ENT:AccessorFuncENT( "Delay", "Delay", 0, ENT.TYPE_FLOAT )
ENT:AccessorFuncENT( "Toggle", "Toggle", true, ENT.TYPE_BOOL )
ENT:AccessorFuncENT( "DamageActivate", "DamageActivate", false, ENT.TYPE_BOOL )
ENT:AccessorFuncENT( "DamageToggle", "DamageToggle", false, ENT.TYPE_BOOL )
ENT:AccessorFuncENT( "Volume", "Volume", 100, ENT.TYPE_FLOAT )
ENT:AccessorFuncENT( "Pitch", "Pitch", 100, ENT.TYPE_FLOAT )
ENT:AccessorFuncENT( "Key", "Key", 41, ENT.TYPE_INT )
ENT:AccessorFuncENT( "On", "Active", false, ENT.TYPE_BOOL )

setter = ENT["SetKey"]
ENT["SetKey"] = function( self, key )
	key = key or 41
	setter( self, key )
	if self.impulseDown then numpad.Remove( self.impulseDown ) end
	if self.impulseUp   then numpad.Remove( self.impulseUp	) end
	ply = self:GetPlayer()
	self.impulseDown = numpad.OnDown( ply, key, "mv_soundemitter_Down",	self )
	self.impulseUp	 = numpad.OnUp(	  ply, key, "mv_soundemitter_Up",	self )
end

function ENT:SetSound( s )
	-- Need to stop the old sound before updating.
	if self:GetOn() then self:StopEmit() end

	self:SetInternalSound(s)
	self:UpdateSound()
end

function ENT:GetSound() return self:GetInternalSound() end


function ENT:UpdateSound()
	
	local soundName = self:GetSound()
	if soundName then util.PrecacheSound( soundName ) end
	
end
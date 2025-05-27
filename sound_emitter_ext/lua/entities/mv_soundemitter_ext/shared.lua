ENT.Type 				= "anim"
ENT.Base 				= "base_gmodentity"
ENT.ClassNameOverride	= "mv_soundemitter" -- Folder name is new_mv_soundemitter (for original addon overriding)
ENT.PrintName			= "MV Sound Emitter"
ENT.Author				= "Alex"
ENT.Contact				= ""
ENT.Purpose				= "To annoy others with your shitty music."
ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.Editable = true

ENT.NullSound = Sound("common/NULL.WAV")

function ENT:SetupDataTables()

	self:NetworkVar( "String",	0,	"Sound" )
 	self:NetworkVar( "Bool",	0,	"Looping" )
	self:NetworkVar( "Bool",	1,	"Toggle" )
	self:NetworkVar( "Bool",	2,	"DamageActivate" )
	self:NetworkVar( "Bool",	3,	"DamageToggle" )
	self:NetworkVar( "Bool",	4,	"AutoLength" )
	self:NetworkVar( "Bool",	5,	"Reverse" )
	self:NetworkVar( "Bool",	6,	"On" )
 	self:NetworkVar( "Float",	0,	"Length"	)
	self:NetworkVar( "Float",	1,	"Delay" )
	self:NetworkVar( "Float",	2,	"Volume" )
	self:NetworkVar( "Float",	3,	"Pitch" )
	self:NetworkVar( "Float",	4,	"Key" )
	self:NetworkVar( "Float",	5,	"SoundLevel" ) -- not used by duplicator

	local setter = self.SetKey
	self.SetKey = function( self, key )
		setter( self, key )
		self:UpdateNumpadActions()
	end

	local setter = self.SetReverse
	self.SetReverse = function( self, reverse )
		if reverse == self:GetReverse() then return end -- nothing to change
		setter( self, reverse )
		self:UpdateNumpadActions()
	end

	local setter = self.SetSound
	self.SetSound = function( self, sound )
		-- Need to stop the old sound before updating.
		if self:GetOn() then self:StopEmit() end
		setter( self, sound )
		self:UpdateSound()
	end

	if SERVER then

		self:SetSound( self.NullSound )
		self:SetLooping( false )
		self:SetToggle( false )
		self:SetDamageActivate( false )
		self:SetDamageToggle( false )
		self:SetAutoLength( false )
		self:SetReverse( false )
		self:SetOn( false )
		self:SetLength( 0 )
		self:SetDelay( 0 )
		self:SetVolume( 1 )
		self:SetPitch( 100 )
		self:SetKey( 41 )
		self:SetSoundLevel( 75 )
	
	end

 end


function ENT:UpdateSound()
	
	local soundName = self:GetSound()
	if soundName then util.PrecacheSound( soundName ) end
	
end
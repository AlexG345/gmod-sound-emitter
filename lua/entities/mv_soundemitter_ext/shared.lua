ENT.Type 				= "anim"
ENT.Base 				= "base_gmodentity"
ENT.ClassNameOverride	= "mv_soundemitter" -- old addon compability
ENT.PrintName			= "MV Sound Emitter"
ENT.Author				= "Alex"
ENT.Contact				= ""
ENT.Purpose				= "To annoy others with your music."
ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.Editable			= true

function ENT:SetupDataTables()

	local c
	local t = "#tool.mv_soundemitter_ext."
	self:NetworkVar( "Float",	0,	"Key" )
	self:NetworkVar( "String",	0,	"Sound",			{ KeyName = "sound",		  Edit = { type = "String",	order = 0 } } )
	c = "Sound effects"
	self:NetworkVar( "Float",	1,	"Volume",			{ KeyName = "volume",		  Edit = { type = "Float",	order = 10,	category = c, min = 0, max = 1 } } )
	self:NetworkVar( "Float",	2,	"SoundLevel" )
	self:NetworkVar( "Float",	3,	"Pitch",			{ KeyName = "pitch",		  Edit = { type = "Float",	order = 11,	category = c, min = 0, max = 255 } } )
	self:NetworkVar( "Bool",	0,	"UseScriptPitch",	{ KeyName = "sndscriptpitch", Edit = { type = "Bool",	order = 12,	category = c, title = t.."usescriptpitch" } })
	self:NetworkVar( "Int",		0,	"DSP",				{ KeyName = "DSP", 			  Edit = { type = "Int", 	order = 13,	category = c, title = t.."dsp", min = 0, max = 133 } } )
	c = "Time related options"
	self:NetworkVar( "Float",	4,	"Delay",			{ KeyName = "delay",		  Edit = { type = "Float",	order = 20,	category = c, title = t.."delay", min = 0, max = 100 } } )
 	self:NetworkVar( "Float",	5,	"Length",			{ KeyName = "length",		  Edit = { type = "Float",	order = 21,	category = c, title = t.."length", min = 0, max = 100 } } )
	self:NetworkVar( "Bool",	1,	"AutoLength",		{ KeyName = "autolength",	  Edit = { type = "Bool",	order = 22,	category = c, title = t.."autolength" } } )
	self:NetworkVar( "Float",	6,	"LoopLength",		{ KeyName = "looplength",	  Edit = { type = "Float",	order = 23,	category = c, title = t.."looplength", min = 0, max = 100 } } )
	self:NetworkVar( "Bool",	2,	"SameLength",		{ KeyName = "samelength",	  Edit = { type = "Bool",	order = 24,	category = c, title = t.."samelength" } })
	self:NetworkVar( "Float",	7,	"FadeIn",			{ KeyName = "fadein",		  Edit = { type = "Float",	order = 25,	category = c, title = t.."fadein" } })
	self:NetworkVar( "Float",	8,	"FadeOut",			{ KeyName = "fadeout",		  Edit = { type = "Float",	order = 26,	category = c, title = t.."fadeout" } })
	c = "Activation options"
	self:NetworkVar( "Bool",	3,	"Toggle",			{ KeyName = "toggle",		  Edit = { type = "Bool",	order = 30, category = c } } )
	self:NetworkVar( "Bool",	4,	"NoStopToggle",		{ KeyName = "nostoptoggle",	  Edit = { type = "Bool",	order = 31,	category = c, title = t.."nostoptoggle" } })
	self:NetworkVar( "Bool",	5,	"Reverse",			{ KeyName = "reverse",		  Edit = { type = "Bool",	order = 32, category = c } } )
	self:NetworkVar( "Bool",	6,	"DamageActivate",	{ KeyName = "dmgactivate",	  Edit = { type = "Bool",	order = 33, category = c, title = t.."dmgactivate" } } )
	self:NetworkVar( "Bool",	7,	"DamageToggle",		{ KeyName = "dmgtoggle",	  Edit = { type = "Bool",	order = 34, category = c, title = t.."dmgtoggle" } } )
	self:NetworkVar( "Bool",	8,	"On" )

	local setter = self.SetKey
	self.SetKey = function( self, key )
		setter( self, key )
		self:UpdateNumpadActions()
	end

	local setter = self.SetReverse
	self.SetReverse = function( self, reverse )
		if reverse == self:GetReverse() then return end
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

		self:SetSound( "common/NULL.WAV" )
		self:SetToggle( false )
		self:SetDamageActivate( false )
		self:SetDamageToggle( false )
		self:SetAutoLength( false )
		self:SetReverse( false )
		self:SetOn( false )
		self:SetLength( 0 )
		self:SetLoopLength( 0 )
		self:SetDelay( 0 )
		self:SetVolume( 1 )
		self:SetPitch( 100 )
		self:SetKey( 41 )
		self:SetSoundLevel( 75 )
		self:SetDSP( 0 )
		self:SetUseScriptPitch( false )
		self:SetNoStopToggle( false )
		self:SetSameLength( true )
		self:SetFadeIn( 0 )
		self:SetFadeOut( 0 )
	
	end

 end


function ENT:UpdateSound()
	
	local soundName = self:GetSound()
	if soundName then util.PrecacheSound( soundName ) end
	
end

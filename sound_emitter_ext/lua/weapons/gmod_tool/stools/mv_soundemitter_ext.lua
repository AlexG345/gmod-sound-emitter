local mode = TOOL.Mode

TOOL.Category		= "Construction"
TOOL.Name			= "#Tool."..mode..".name"

TOOL.ClientConVar[ "model" ]		= "models/props_lab/citizenradio.mdl"
TOOL.ClientConVar[ "sound" ] 		= "coast.siren_citizen"
TOOL.ClientConVar[ "length" ]		= "0"
TOOL.ClientConVar[ "autolength"  ]	= "0"
TOOL.ClientConVar[ "looping" ]		= "0"
TOOL.ClientConVar[ "delay" ]		= "0"
TOOL.ClientConVar[ "toggle" ]		= "0"
TOOL.ClientConVar[ "dmgactivate" ] 	= "0"
TOOL.ClientConVar[ "dmgtoggle" ] 	= "0"
TOOL.ClientConVar[ "key"    ] 		= "38"
TOOL.ClientConVar[ "volume" ]		= "1"
TOOL.ClientConVar[ "pitch"  ]		= "100"
TOOL.ClientConVar[ "reverse" ]		= "0"


cleanup.Register( "mv_soundemitter" )

-- Use this if you need more presets?
if file.Exists("soundemitter_ext/custom_sound_presets.txt", "DATA") then
	local SoundPresets = util.KeyValuesToTable(file.Read("soundemitter_ext/custom_sound_presets.txt", "DATA"))
	for key, value in pairs(SoundPresets) do
		list.Set( "MVSoundEmitterExtSound", key, value )
	end
end


local function isMSE( ent )
	return isentity( ent ) and ent:IsValid() and ( ent:GetClass() == "mv_soundemitter" )
end

if CLIENT then
	
	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
		{ name = "reload" }
	}
	
	local t = "Tool."..mode
	language.Add( t..".name", "Sound Emitter (+)" )
	language.Add( t..".desc", "Create sound emitters" )
	language.Add( t..".left", "Attach or update a sound emitter" )
	language.Add( t..".right", "Same as left click but no weld" )
	language.Add( t..".reload", "Copy settings or model." )
	t = nil

	language.Add( "SBoxLimit_mv_soundemitters", "You've hit the Sound Emitter limit!" )
	language.Add( "mv_soundemitter", "Sound Emitter" )
	language.Add( "Cleanup_mv_soundemitter", "Sound Emitters" )
	language.Add( "Cleaned_mv_soundemitter", "Cleaned up all Sound Emitters" )

	function TOOL:LeftClick( trace )	return not( trace.Entity and trace.Entity:IsPlayer() ) end
	function TOOL:RightClick( trace )	return self:LeftClick( trace ) end
	function TOOL:Reload( trace )		return isMSE( trace.Entity ) end

elseif SERVER then

	local cvars =  {
	sbox_maxmv_soundemitters = 3,
	sv_mv_soundemitters_min_loop_length = game.SinglePlayer() and 0 or 0.05
	}
	for name, default in pairs( cvars ) do
		if !ConVarExists( name ) then CreateConVar( name, default ) end
	end
	cvars = nil

	local dupeKeys = { "model", "sound", "length", "looping", "delay", "toggle", "dmgactivate", "dmgtoggle", "volume", "pitch", "key", "nocollide", "autolength", "reverse" }

	 -- Returns table with keys dupeKeys and values ...
	local function toMSEProperties( ... )
		local values = { ... }
		local t = {}
		for i, k in ipairs(dupeKeys) do
			t[k] = values[i]
		end
		return t
	end

	local emitterProperties = toMSEProperties(
		"Model",
		"Sound",
		"Length",
		"Looping",
		"Delay",
		"Toggle",
		"DamageActivate",
		"DamageToggle",
		"Volume",
		"Pitch",
		"Key",
		nil,
		"AutoLength",
		"Reverse"
	)

	local function updateMSE( emitter, ply, t ) -- t = properties table

		if not isMSE( emitter ) then return end

		-- false might once have been saved as "0"
		local bool_props = { "looping", "toggle", "dmgactivate", "dmgtoggle", "nocollide", "autolength", "reverse" }
		for _, prop in ipairs( bool_props ) do
			if t[prop] == "0" or t[prop] == 0 then
				t[prop] = false
			end
		end

		if ply and not emitter:GetPlayer():IsPlayer() then
			emitter:SetPlayer(ply)
		end
		ply = emitter:GetPlayer()

		if t.pitch then
			t.pitch = math.Clamp(t.pitch, 0, 255)
			if t.autolength and t.sound then
				t.length = ( t.pitch <= 0 ) and 0 or ( SoundDuration( t.sound ) * 100 / t.pitch ) -- pitch is in percentage
			end
		end	

		if t.looping and t.length and t.length > 0 then
			local minLength = GetConVar( "sv_mv_soundemitters_min_loop_length" ):GetFloat() or 0 -- error if cvar doesn't exist
			if t.length < minLength then
				if ply then ply:ChatPrint("Play length too short: changed from "..t.length.." to "..math.Round( minLength, 2 ).." second(s).") end
				t.length = minLength
			end
		end

		for duName, value in pairs( t ) do
			if value ~= nil then
				local name = emitterProperties[duName]
				if name then emitter["Set"..name]( emitter, value ) end
				emitter[duName] = value
			end
		end

		if t.nocollide then emitter:GetPhysicsObject():EnableCollisions( false ) end
		if t.reverse then emitter:PreEmit() end

	end

	
	local function MakeMVSoundEmitter(  ply, pos, ang, ... ) -- look at dupeKeys table for ... args order !

		if not ply:CheckLimit( "mv_soundemitters" ) then return false end

		-- Get the emitter properties
		local t = ( type( ... ) == "table" ) and ... or toMSEProperties( ... )

		if not ( t.model and util.IsValidModel( t.model ) ) then
			ply:ChatPrint("Invalid model!")
			return false
		end

		local emitter = ents.Create( "mv_soundemitter" ) or NULL
		if not emitter:IsValid() then return false end

		emitter:SetPos( pos )
		emitter:SetAngles( ang )
		emitter:SetModel(t.model) -- useless?
		emitter:Spawn()
		updateMSE( emitter, ply, t )

		ply:AddCount( "mv_soundemitters", emitter )
		ply:AddCleanup( "mv_soundemitter", emitter )

		DoPropSpawnedEffect( emitter )

		return emitter
	end

	duplicator.RegisterEntityClass( "mv_soundemitter", MakeMVSoundEmitter, "pos", "ang", unpack(dupeKeys) )


	function TOOL:LeftClick( trace, do_weld )

		local ent = trace.Entity
		if ent and ent:IsPlayer() then return false end
		if do_weld == nil then do_weld = true end

		-- If there's no physics object then we can't constraint it.
		if do_weld and not util.IsValidPhysicsObject( ent, trace.PhysicsBone ) then return false end

		local ply = self:GetOwner()

		local t = toMSEProperties(
			self:GetClientInfo("model"),
			self:GetClientInfo("sound"),
			self:GetClientNumber("length"),
			self:GetClientBool("looping"),
			self:GetClientNumber("delay"),
			self:GetClientBool("toggle"),
			self:GetClientBool("dmgactivate"),
			self:GetClientBool("dmgtoggle"),
			self:GetClientNumber("volume"),
			self:GetClientNumber("pitch"),
			self:GetClientNumber("key"),
			false, -- nocollide
			self:GetClientBool("autolength"),
			self:GetClientBool("reverse")
		)

		if isMSE( ent ) and ( ent:GetPlayer() == ply ) then

			t.model = nil
			updateMSE( ent, nil, t )
			return true

		end

		local pos = trace.HitPos
		local ang = trace.HitNormal:Angle()
		ang.pitch = ang.pitch + 90

		local emitter = MakeMVSoundEmitter( ply, pos, ang, t )

		if not emitter then return false end

		local min = emitter:OBBMins()
		emitter:SetPos( pos - trace.HitNormal * min.z )

		undo.Create("mv_soundemitter")
			undo.AddEntity( emitter )

			if ent and do_weld then
				local weld = constraint.Weld( ent, emitter, trace.PhysicsBone, 0, 0 )
				ent:DeleteOnRemove( emitter )

				local physobj = emitter:GetPhysicsObject() 
				if IsValid( physobj ) then physobj:EnableCollisions( false ) end
				emitter.nocollide = true
				undo.AddEntity( weld )
			end

			undo.SetPlayer( ply )
		undo.Finish()

		return true
	end	


	function TOOL:RightClick( trace )
		return self:LeftClick( trace, false )
	end	


	function TOOL:Reload( trace )

		local ent = trace.Entity

		if not ent:IsValid() then return false end
		
		local ply = self:GetOwner()
		local model = ent:GetModel()
		if model then ply:ConCommand(mode.."_model "..tostring(model)) end
		
		if not isMSE( ent ) then return false end

		local conStart = mode.."_"
		for duName, name in pairs( emitterProperties ) do
			local val = ent["Get" .. name]( ent )
			if val ~= nil then ply:ConCommand( conStart..duName.." "..tostring( val ) ) end
		end

		-- Fix for copying original addon sound emitters which always return 0 for key.
		local key = ent:GetKey()
		if ( not key ) or ( key == 0 and key ~= ent.key ) then
			ply:ConCommand(mode.."_key "..tostring( ent.key ))	
		end

		return true

	end


end


local cvarList = TOOL:BuildConVarList()

function TOOL.BuildCPanel(cpanel)

	cpanel:ToolPresets( mode, cvarList )

	local panel = cpanel:KeyBinder( "Sound Emitter Key", mode.."_key" )
		panel:SetToolTip("The keyboard key that can set on and off the sound emitter.")
	
	cpanel:PropSelect("Preset Models", mode.."_model", list.Get("MVSoundEmitterModel"), 3)
	cpanel:TextEntry( "Model:", mode.."_model" )

	local listview = vgui.Create( "DListView" )
		listview:SetSize( 80,200 )
		listview:SetMultiSelect( false )
		listview:AddColumn( "Preset Sounds" )
		for soundName, _ in pairs(list.Get("MVSoundEmitterExtSound")) do
			listview:AddLine( soundName )
		end
		listview:SortByColumn( 1 )

		local command = "mv_soundemitter_ext_sound"
		listview.OnRowSelected = function( panel, rowIndex, row )
			-- Get the soundname at this cell
			local parameter = list.Get("MVSoundEmitterExtSound")[row:GetValue( 1 )][ command ]
			if parameter then LocalPlayer():ConCommand( command.." "..parameter ) end
		end
	cpanel:AddItem( listview )

	local panel = cpanel:TextEntry( "Sound:", mode.."_sound" )
		panel:SetToolTip( "A sound from the game content.\nSupports soundscripts, .mp3, .ogg, .wav." )

	local panel1, panel2 = vgui.Create( "DButton", panel ), vgui.Create( "DButton", panel )
		panel1:SetText("Sound Preview")
		panel2:SetText("Stop the Sound Preview")
		panel1:SetImage("icon32/unmuted.png")
		panel2:SetImage("icon32/muted.png")
		local ply = LocalPlayer()
		panel1.DoClick = function()
			if panel1.soundName then ply:StopSound( panel1.soundName ) end
			panel1.soundName = GetConVar( mode.."_sound" ):GetString() or ""
			ply:EmitSound( panel1.soundName )
		end
		panel2.DoClick = function()
			if panel1.soundName then ply:StopSound( panel1.soundName ) end
		end
		panel1:Dock(TOP)
		panel2:DockMargin( 15, 0, 0, 0 )
		panel2:Dock(TOP)
		cpanel:AddItem( panel1, panel2 )

	local panel = cpanel:NumSlider( "Volume", mode.."_volume", 0, 1 )
		panel:SetToolTip( "The loudness of the sound, in proportion of max volume." )

	local panel = cpanel:NumSlider( "Pitch", mode.."_pitch", 0, 255 )
		panel:SetToolTip( "The pitch percentage of the sound." )
	
	local panel = cpanel:NumSlider( "Initial Delay", mode.."_delay", 0, 100 )
		panel:SetToolTip( "How many seconds to wait before starting the sound emitter." )

	local panel = cpanel:NumSlider( "Play Length", mode.."_length", 0, 300 )
		panel:SetToolTip( "How long before the sound stops or repeats, in seconds.\nSet to 0 or below for infinite duration." )

	local checkbox = cpanel:CheckBox( "Calculate length", mode.."_autolength" )
		checkbox:SetToolTip( "Set the play length to the approximate length of the sound.\nThis can be inaccurate for self-looping sounds." )
	
	function checkbox:OnChange( isChecked )
		panel:SetEnabled( not isChecked )
	end

	local panel = cpanel:CheckBox( "Toggle", mode.."_toggle" )
		panel:SetToolTip( "Toggle turning the sound emitter on and off." )

	local panel = cpanel:CheckBox( "Reverse", mode.."_reverse" )
		panel:SetToolTip( "Reverse the activation order." )
	
	local panel = cpanel:CheckBox( "Loop", mode.."_looping" )
		panel:SetToolTip( "Replay the sound after the play length is over.\nFor self-looping sounds it's better to set this off and the play length to -1." )

	local checkbox = cpanel:CheckBox( "Activate on Damage", mode.."_dmgactivate" )
		checkbox:SetToolTip( "The emitter will activate if something damages it." )

	local panel = cpanel:CheckBox( "Toggle on Damage", mode.."_dmgtoggle" )
		panel:SetToolTip( "If something damages the emitter it will toggle but only if 'Activate on Damage' is on." )
	
	function checkbox:OnChange( isChecked )
		panel:SetEnabled( isChecked )
	end

end


function TOOL:UpdateGhostMVSoundEmitter( ent, player )

	if not IsValid( ent ) then return end

	local trace = player:GetEyeTrace()
	if not trace.Hit then return end
	
	local trEnt = trace.Entity
	if not trEnt then return end

	if isMSE( trEnt ) or trEnt:IsPlayer() then

		ent:SetNoDraw( true )
		return

	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	ent:SetAngles( Ang )

	ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )

	ent:SetNoDraw( false )

end


function TOOL:Think()
	
	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo("model") ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end

	self:UpdateGhostMVSoundEmitter( self.GhostEntity, self:GetOwner() )

end
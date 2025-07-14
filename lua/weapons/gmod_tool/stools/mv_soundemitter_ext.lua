local mode = TOOL.Mode

TOOL.Category		= "Construction"
TOOL.Name			= "#Tool."..mode..".name"

TOOL.ClientConVar[ "model" ]			= "models/props_lab/citizenradio.mdl"
TOOL.ClientConVar[ "sound" ] 			= "coast.siren_citizen"
TOOL.ClientConVar[ "length" ]			= "0"
TOOL.ClientConVar[ "autolength"  ]		= "0"
TOOL.ClientConVar[ "looplength" ]		= "0"
TOOL.ClientConVar[ "delay" ]			= "0"
TOOL.ClientConVar[ "toggle" ]			= "0"
TOOL.ClientConVar[ "dmgactivate" ] 		= "0"
TOOL.ClientConVar[ "dmgtoggle" ] 		= "0"
TOOL.ClientConVar[ "key"    ] 			= "38"
TOOL.ClientConVar[ "volume" ]			= "1"
TOOL.ClientConVar[ "pitch"  ]			= "100"
TOOL.ClientConVar[ "reverse" ]			= "0"
TOOL.ClientConVar[ "sndlvl" ]			= "75"
TOOL.ClientConVar[ "dsp" ]				= "0"
TOOL.ClientConVar[ "usescriptpitch" ] 	= "0"
TOOL.ClientConVar[ "nostoptoggle" ] 	= "0"
TOOL.ClientConVar[ "samelength" ] 		= "1"
TOOL.ClientConVar[ "fadein" ] 			= "0"
TOOL.ClientConVar[ "fadeout" ] 			= "0"

local soundConVar, pitchConVar, dspConVar, volumeConVar

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

local conVars =  {
	sbox_maxmv_soundemitters = 3,
	sv_mv_soundemitter_min_looplength = game.SinglePlayer() and 0 or 0.15,
	sv_mv_soundemitter_max_sndlvl = game.SinglePlayer() and 0 or 105,
	sv_mv_soundemitter_check_dsp = game.SinglePlayer() and 0 or 1 -- should make this into a table somehow to let people add or remove chosen forbidden DSP
}
for name, default in pairs( conVars ) do
	if not ConVarExists( name ) then CreateConVar( name, default, { FCVAR_REPLICATED, FCVAR_NOTIFY,  } ) end
end
conVars = nil

if CLIENT then

	local function refreshConVar()
		soundConVar 	 = GetConVar( mode.."_sound" )
		volumeConVar	 = GetConVar( mode.."_volume" )
		pitchConVar 	 = GetConVar( mode.."_pitch" )
		dspConVar		 = GetConVar( mode.."_dsp" )
	end
	-- lua refresh....
	refreshConVar()
	
	hook.Add("InitPostEntity", "mv_soundemitter_ext_init", function()
		-- store convars for sound preview in the menu
		refreshConVar()
	end)

	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
		{ name = "reload" }
	}
	
	local t = "tool."..mode
	language.Add( t..".name", "Sound Emitter (+)" )
	language.Add( t..".desc", "Create sound emitters" )
	language.Add( t..".left", "Attach or update a sound emitter" )
	language.Add( t..".right", "Same as left click but no weld" )
	language.Add( t..".reload", "Copy settings or model" )
	language.Add( t..".dmgactivate", "Activate on Damage" )
	language.Add( t..".dmgtoggle", "Toggle on Damage" )
	language.Add( t..".autolength", "Calculate length" )
	language.Add( t..".length", "Play Length" )
	language.Add( t..".delay", "Initial Delay" )
	language.Add( t..".sndlvl", "Sound Level" )
	language.Add( t..".dsp", "Digital Signal Processing" )
	language.Add( t..".usescriptpitch", "Use Soundscript Pitch" )
	language.Add( t..".nostoptoggle", "Toggle always plays" )
	language.Add( t..".looplength", "Loop Length" )
	language.Add( t..".samelength", "Use play length as loop length" )
	language.Add( t..".fadein", "Fade-in duration" )
	language.Add( t..".fadeout", "Fade-out duration" )
	t = nil

	language.Add( "SBoxLimit_mv_soundemitters", "You've hit the Sound Emitter limit!" )
	language.Add( "mv_soundemitter", "Sound Emitter" )
	language.Add( "Cleanup_mv_soundemitter", "Sound Emitters" )
	language.Add( "Cleaned_mv_soundemitter", "Cleaned up all Sound Emitters" )

	function TOOL:LeftClick( trace )	return not( trace.Entity and trace.Entity:IsPlayer() ) end
	function TOOL:RightClick( trace )	return self:LeftClick( trace ) end
	function TOOL:Reload( trace )		return isMSE( trace.Entity ) end

elseif SERVER then

	local dupeKeys = { "model", "sound", "length", "looplength", "delay", "toggle", "dmgactivate", "dmgtoggle", "volume", "pitch", "key", "nocollide", "autolength", "reverse", "sndlvl", "dsp", "usescriptpitch", "nostoptoggle", "samelength", "fadein", "fadeout" }

	 -- Returns a table with keys dupeKeys and values ...
	local function toMSEProperties( ... )
		local values = { ... }
		local t = {}
		for i, k in ipairs(dupeKeys) do
			t[k] = values[i]
		end
		return t
	end

	-- Those are the properties you want to use a setter function on when the emitter is created.
	local emitterProperties = toMSEProperties(
		"Model",
		"Sound",
		"Length",
		"LoopLength",
		"Delay",
		"Toggle",
		"DamageActivate",
		"DamageToggle",
		"Volume",
		"Pitch",
		"Key",
		nil,
		"AutoLength",
		"Reverse",
		"SoundLevel",
		"DSP",
		"UseScriptPitch",
		"NoStopToggle",
		"SameLength",
		"FadeIn",
		"FadeOut"
	)

	local function updateMSE( emitter, ply, t ) -- t = properties table

		if not isMSE( emitter ) then return end

		-- false might once have been saved as "0"
		local bool_props = { "toggle", "dmgactivate", "dmgtoggle", "nocollide", "autolength", "reverse", "usescriptpitch", "nostoptoggle", "samelength" }
		for _, prop in ipairs( bool_props ) do
			if t[prop] == "0" or t[prop] == 0 then
				t[prop] = false
			end
		end

		if ply and not emitter:GetPlayer():IsPlayer() then
			emitter:SetPlayer(ply)
		end
		ply = emitter:GetPlayer()

		-- Check the DSP since some of them play a global sound
		if t.dsp and GetConVar( "sv_mv_soundemitter_check_dsp" ):GetInt() ~= 0 then
			local forbidden = { [35] = true, [36] = true, [37] = true, [39] = true }
			if forbidden[t.dsp] then
				ply:ChatPrint("This DSP is forbidden! Changed from "..t.dsp.." to 0.")
				t.dsp = 0
			end
		end

		-- Limit the pitch
		if t.pitch then t.pitch = math.Clamp(t.pitch, 0, 255) end	
		
		-- Limit the loop length
		if t.looplength and t.looplength > 0 then
			local minLoopLength = GetConVar( "sv_mv_soundemitter_min_looplength" ):GetFloat() or 0 -- error if cvar doesn't exist
			if t.looplength < minLoopLength then
				if ply then ply:ChatPrint("Loop length too short! Changed from "..t.looplength.." to "..math.Round( minLoopLength, 2 ).." second(s).") end
				t.looplength = minLoopLength
			end
		end

		-- Limit the sound level.
		if t.sndlvl then
			local maxSndLvl = GetConVar( "sv_mv_soundemitter_max_sndlvl"):GetFloat() or 100
			-- If global sounds are allowed there's no need to limit the sound level
			-- Sound levels <= 1 play at infinite distances.
			if maxSndLvl > 0 and ( t.sndlvl <= 1 or t.sndlvl > maxSndLvl ) then
				if ply then ply:ChatPrint("Sound level too high! Changed from "..t.sndlvl.." to "..math.Round( maxSndLvl, 2 ).." decibel(s).") end
				t.sndlvl = maxSndLvl
			end
			t.sndlvl = math.Clamp( t.sndlvl, 0, 255 ) -- valid range
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

		-- Get the emitter properties table
		local t = ( type( ... ) == "table" ) and ... or toMSEProperties( ... )

		if not ( t.model and util.IsValidModel( t.model ) ) then
			ply:ChatPrint("Invalid model!")
			return false
		end

		local emitter = ents.Create( "mv_soundemitter" ) or NULL
		if not emitter:IsValid() then return false end

		emitter:SetPos( pos )
		emitter:SetAngles( ang )
		emitter:SetModel(t.model)
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
			self:GetClientNumber("looplength"),
			self:GetClientNumber("delay"),
			self:GetClientBool("toggle"),
			self:GetClientBool("dmgactivate"),
			self:GetClientBool("dmgtoggle"),
			self:GetClientNumber("volume"),
			self:GetClientNumber("pitch"),
			self:GetClientNumber("key"),
			false, -- nocollide isn't used yet
			self:GetClientBool("autolength"),
			self:GetClientBool("reverse"),
			self:GetClientNumber("sndlvl"),
			self:GetClientNumber("dsp"),
			self:GetClientBool("usescriptpitch"),
			self:GetClientBool("nostoptoggle"),
			self:GetClientBool("samelength"),
			self:GetClientNumber("fadein"),
			self:GetClientNumber("fadeout")
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
			local getter = name and ent["Get"..name]
			local val
			if getter then val = getter( ent ) end
			if val == nil then val = ent[duName] end -- dupekey fallback
			if val ~= nil then
				if type(val) == "number" then val = math.Round(val, 2) end
				ply:ConCommand( conStart..duName.." "..tostring(val) )
			end
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

	local t = "#tool."..mode.."."
	local ply = LocalPlayer()
	local panel1, panel2, pitchSlider, lengthSlider

	cvars.AddChangeCallback( mode.."_sound", function(convar_name, value_old, value_new)
		pitchSlider:updatePitch()
		lengthSlider:updateLength()
	end)

	cvars.AddChangeCallback( mode.."_pitch", function(convar_name, value_old, value_new)
		lengthSlider:updateLength()
	end)

	local function paint( panel, w, h )
		local topHeight = panel:GetHeaderHeight()
		local c = not panel:GetExpanded()
		draw.RoundedBoxEx(4, 0, 0, w, topHeight, Color(50, 100, 200), true, true, c, c)
		draw.RoundedBoxEx(8, 0, topHeight, w, h - topHeight + 5, Color(240, 240, 240), false, false, true, true)
	end

	local keyBinder = cpanel:KeyBinder( "Sound Emitter Key", mode.."_key" )
		keyBinder:SetToolTip("The keyboard key that can set on and off the sound emitter.")
	
	cpanel:PropSelect("Preset Models", mode.."_model", list.Get("MVSoundEmitterModel"), 2)
	cpanel:TextEntry( "Model:", mode.."_model" )

	local listView = vgui.Create( "DListView" )
		listView:SetSize( 80,200 )
		listView:SetMultiSelect( false )
		listView:AddColumn( "Preset Sounds" )
		for soundName, _ in pairs(list.Get("MVSoundEmitterExtSound")) do
			listView:AddLine( soundName )
		end
		listView:SortByColumn( 1 )
		local command = "mv_soundemitter_ext_sound"
		function listView:OnRowSelected( rowIndex, row )
			-- Get the soundname at this cell
			local snd = list.Get("MVSoundEmitterExtSound")[row:GetValue( 1 )][ command ]
			if not snd then return end
			ply:ConCommand( command.." "..snd )
		end
		cpanel:AddItem( listView )

	local panel = cpanel:TextEntry( "Sound:", mode.."_sound" )
		panel:SetToolTip( "A sound from the game content.\nSupports soundscripts, .mp3, .ogg, .wav." )
	
	
	local dForm = vgui.Create( "DForm", panel )
		cpanel:AddItem( dForm )
		dForm:SetLabel( "Sound manipulation" )
		dForm:SetPaintBackground( false )
		dForm:DockPadding( 0, 0, 0, 5 )
		function dForm:Paint(w, h)
			paint( self, w, h )
		end

		panel1, panel2 = vgui.Create( "DButton", dForm ), vgui.Create( "DButton", dForm )
			panel1:SetText( "Sound Preview" )
			panel1:SetImage( "icon32/unmuted.png" )
			panel1:SetToolTip( "Does not take loop/play length and fade in/out into account." )
			panel1:Dock( TOP )
			panel1.DoClick = function()
				if panel1.mySound then panel1.mySound:Stop() end
				local snd = CreateSound( ply, soundConVar:GetString() or "" )
				snd:SetDSP( dspConVar:GetInt() or 0 )
				snd:PlayEx( volumeConVar:GetFloat() or 1, pitchConVar:GetFloat() or 100 )
				panel1.mySound = snd
			end
			panel2:SetText( "Stop the Sound Preview" )
			panel2:SetImage( "icon32/muted.png" )
			panel2:DockMargin( 15, 0, 0, 0 )
			panel2:Dock( TOP )
			panel2.DoClick = function()
				if panel1.mySound then
					panel1.mySound:Stop()
					panel1.mySound = nil
				end
			end
			dForm:AddItem( panel1, panel2 )
		
		-- Helper button for stream radios
		if scripted_ents.Get( "base_streamradio" ) then
			local panel = vgui.Create( "DButton", dForm )
			panel:SetText( "Send to Stream Radio" )
			panel:SetImage( "icon16/phone_sound.png" )
			function panel:DoClick()
				RunConsoleCommand( "streamradio_streamurl",soundConVar:GetString() )
				ply:EmitSound( "ambient/levels/prison/radio_random"..math.random( 3, 14 )..".wav" )
			end
			dForm:AddItem( panel )
		end


	local dForm = vgui.Create( "DForm", panel )
		cpanel:AddItem( dForm )
		dForm:SetLabel( "Sound effects" )
		dForm:SetPaintBackground( false )
		dForm:DockPadding( 0, 0, 0, 5 )
		dForm:SetExpanded( false )
		function dForm:Paint(w, h)
			paint( self, w, h )
		end

		local panel = dForm:NumSlider( "Volume", mode.."_volume", 0, 1 )
			panel:SetToolTip( "The loudness of the sound, in proportion of max volume.\nThis doesn't affect the distance at which the sound is heard." )

		-- Valid sound level values are int 0 to 255 (https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/sp/src/public/soundflags.h#L53)
		local maxLevelConVar = GetConVar( "sv_mv_soundemitter_max_sndlvl" )
		local levelSlider = dForm:NumSlider( t.."sndlvl", mode.."_sndlvl", 0, 255, 0 )
			levelSlider:SetToolTip( "The sound's level, in decibels (dB).\nThis affects the distance at which the sound is heard.\nBelow 1 dB sounds play globally. Very high values can reduce volume." )
			function levelSlider:OnValueChanged( value )
				self:SetValue( math.Clamp( value, 0, self:GetMax() ) ) -- visual
				self:SetValue( math.SnapTo( value,1 ) )
			end
			
			function levelSlider:Think()
				local max = math.Clamp( maxLevelConVar:GetFloat(), 0, 255 )
				max = max > 0 and max or 255
				if self:GetMax() == max then return end
				self:SetMax( max )
			end
		
		pitchSlider = dForm:NumSlider( "Pitch", mode.."_pitch", 0, 255 )
			pitchSlider:SetToolTip( "The pitch percentage of the sound." )

		local scriptPitchCheck = dForm:CheckBox( t.."usescriptpitch", mode.."_usescriptpitch" )
			scriptPitchCheck:SetToolTip( "Use the (random) pitch that is saved in soundscripts.\nIf the pitch is random, shown value will be an average." )
			function scriptPitchCheck:OnChange( isChecked )
				pitchSlider:updatePitch()
			end

		function pitchSlider:updatePitch( snd )
			self:SetEnabled( true )
			if scriptPitchCheck:GetChecked() then
				local pitch = getSoundScriptMeanPitch( soundConVar:GetString() or "" )
				if pitch then
					self:SetValue( pitch )
					self:SetEnabled( false )
				end
			end
		end

		local panel = dForm:NumSlider( t.."dsp", mode.."_dsp", 0, 133, 0 )
			panel:SetToolTip( "Apply reverb, delay, stereo effect, tone, etc..\nCheck the wiki for more info.\nhttps://wiki.facepunch.com/gmod/DSP_Presets" )
			dForm:ControlHelp( "Leave this at 0 if you don't know what it is.")
	
	local dForm = vgui.Create( "DForm", panel )
		cpanel:AddItem( dForm )
		dForm:SetLabel( "Time-related options" )
		dForm:SetPaintBackground( false )
		dForm:DockPadding( 0, 0, 0, 5 )
		dForm:SetExpanded( false )
		function dForm:Paint(w, h)
			paint( self, w, h )
		end

		local delaySlider = dForm:NumSlider( t.."delay", mode.."_delay", 0, 100 )
			delaySlider:SetToolTip( "How many seconds to wait before starting the sound emitter." )

		lengthSlider = dForm:NumSlider( t.."length", mode.."_length", 0, 100 )
			lengthSlider:SetToolTip( "How many seconds before the sound stops by itself.\nSet to 0 or below for infinite length." )

		local autoCheck = dForm:CheckBox( t.."autolength", mode.."_autolength" )
			autoCheck:SetToolTip( "Set the play length to an approximation of the length of the sound.\nThis isn't always accurate." )	
			function autoCheck:OnChange( isChecked )
				lengthSlider:SetEnabled( not isChecked )
				lengthSlider:updateLength()
			end
			
		function lengthSlider:updateLength()
			if autoCheck:GetChecked() then
				local snd = soundConVar:GetString()
				local pitch = pitchSlider:GetValue()
				local prop = sound.GetProperties( snd )
				if prop then
					local s = prop.sound
					snd = istable(s) and s[1] or s
				end
				-- use 'Scratch' for min/max bypass
				self.Scratch:SetValue( MSECalculateDuration( snd or "", pitch ) )
				self:ValueChanged( self:GetValue() )
			end
		end

		local loopSlider = dForm:NumSlider( t.."looplength", mode.."_looplength", 0, 100 )
			loopSlider:SetToolTip( "How long before the sound emitter restarts, in seconds.\nSet to 0 or below for never (no looping)." )

		local sameCheck = dForm:CheckBox( t.."samelength", mode.."_samelength" )
			sameCheck:SetToolTip( "Set the Loop Length to the same duration as the Play Length.")
			function sameCheck:OnChange( isChecked )
				loopSlider:SetEnabled( not isChecked )
			end

		local fadeInSlider = dForm:NumSlider( t.."fadein", mode.."_fadein", 0, 10 )
			fadeInSlider:SetToolTip( "How many seconds it takes for the sound's volume to reach its max when played. Applies during loops." )

		local fadeOutSlider = dForm:NumSlider( t.."fadeout", mode.."_fadeout", 0, 10 )
			fadeOutSlider:SetToolTip( "How many seconds it takes for the sound's volume to drop to 0 when stopped. Applies during loops." )

		-- use 'Scratch' for min/max bypass
		function lengthSlider.Scratch:OnValueChanged( value )
			if sameCheck:GetChecked() then
				loopSlider.Scratch:SetValue( value )
				loopSlider:ValueChanged( value )
			end
		end
			

	local dForm = vgui.Create( "DForm", panel )
		cpanel:AddItem( dForm )
		dForm:SetLabel( "Activation options" )
		dForm:SetPaintBackground( false )
		dForm:DockPadding( 0, 0, 0, 5 )
		dForm:SetExpanded( false )
		function dForm:Paint(w, h)
			paint( self, w, h )
		end

		local checkbox = dForm:CheckBox( "Toggle", mode.."_toggle" )
			checkbox:SetToolTip( "Toggle turning the sound emitter on and off." )

		local panel = dForm:CheckBox( t.."nostoptoggle", mode.."_nostoptoggle" )
			panel:SetToolTip( "Toggling the sound emitter starts or restarts the sound, but never stops it.\nWorks only if '"..checkbox:GetText().."' is checked." )

		function checkbox:OnChange( isChecked )
			panel:SetEnabled( isChecked )
		end

		local panel = dForm:CheckBox( "Reverse", mode.."_reverse" )
			panel:SetToolTip( "If checked, the default state will be on instead of off." )

		local checkbox = dForm:CheckBox( t.."dmgactivate", mode.."_dmgactivate" )
			checkbox:SetToolTip( "The emitter will activate if something damages it." )

		local panel = dForm:CheckBox( t.."dmgtoggle", mode.."_dmgtoggle" )
			panel:SetToolTip( "If something damages the emitter it will toggle but only if '"..checkbox:GetText().."' is on." )
		
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
	
	if not ( self.GhostEntity and self.GhostEntity:IsValid() ) or ( self.GhostEntity:GetModel() ~= self:GetClientInfo( "model" ) ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end

	self:UpdateGhostMVSoundEmitter( self.GhostEntity, self:GetOwner() )

end
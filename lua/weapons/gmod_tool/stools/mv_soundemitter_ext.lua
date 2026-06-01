local mode = TOOL.Mode

TOOL.Category		= "Construction"
TOOL.Name			= "#Tool." .. mode .. ".name"

TOOL.ClientConVar[ "model" ]			= "models/props_lab/citizenradio.mdl"
TOOL.ClientConVar[ "sound" ] 			= "coast.siren_citizen"
TOOL.ClientConVar[ "length" ]			= "0"
TOOL.ClientConVar[ "looplength" ]		= "0"
TOOL.ClientConVar[ "delay" ]			= "0"
TOOL.ClientConVar[ "toggle" ]			= "0"
TOOL.ClientConVar[ "dmgactivate" ] 		= "0"
TOOL.ClientConVar[ "dmgtoggle" ] 		= "0"
TOOL.ClientConVar[ "volume" ]			= "1"
TOOL.ClientConVar[ "pitch"  ]			= "100"
TOOL.ClientConVar[ "key"    ] 			= "38"
TOOL.ClientConVar[ "autolength"  ]		= "0"
TOOL.ClientConVar[ "reverse" ]			= "0"
TOOL.ClientConVar[ "sndlvl" ]			= "75"
TOOL.ClientConVar[ "dsp" ]				= "1"
TOOL.ClientConVar[ "usescriptpitch" ] 	= "0"
TOOL.ClientConVar[ "nostoptoggle" ] 	= "0"
TOOL.ClientConVar[ "samelength" ] 		= "1"
TOOL.ClientConVar[ "fadein" ] 			= "0"
TOOL.ClientConVar[ "fadeout" ] 			= "0"

local soundConVar, pitchConVar, dspConVar, volumeConVar

cleanup.Register( "mv_soundemitter" )

-- Use this if you need more presets?
if file.Exists( "soundemitter_ext/custom_sound_presets.txt", "DATA" ) then
	local SoundPresets = util.KeyValuesToTable(file.Read( "soundemitter_ext/custom_sound_presets.txt", "DATA" ) )
	for key, value in pairs( SoundPresets ) do
		list.Set( "MVSoundEmitterExtSound", key, value )
	end
end


local function isMSE( ent )
	return isentity( ent ) and ent:IsValid() and ent:GetClass() == "mv_soundemitter"
end

if SERVER then
	local s, flags = game.SinglePlayer(), bit.bor( FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY )
	CreateConVar( "sbox_maxmv_soundemitters", 3, flags, "The maximum amount of sound emitters each player can have.", 0 )
	CreateConVar( "sv_mv_soundemitter_min_looplength", s and 0 or 0.15, flags, "The minimum duration of a loop.", 0 )
	CreateConVar( "sv_mv_soundemitter_max_sndlvl", s and 0 or 100, flags, "The maximum sound level, in decibel(s).", 0, 255 )
	CreateConVar( "sv_mv_soundemitter_check_dsp", s and 0 or 1, flags, "Forbid unwanted DSPs that play global sounds.", 0, 1 )
	s, flags = nil, nil
end

if CLIENT then

	local function refreshConVar()
		soundConVar 	 = GetConVar( mode .. "_sound" )
		volumeConVar	 = GetConVar( mode .. "_volume" )
		pitchConVar 	 = GetConVar( mode .. "_pitch" )
		dspConVar		 = GetConVar( mode .. "_dsp" )
	end
	-- lua refresh .. ..
	refreshConVar()

	hook.Add( "InitPostEntity", "mv_soundemitter_ext_init", function()
		-- store convars for sound preview in the menu
		refreshConVar()
	end)

	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
		{ name = "reload" }
	}

	local t = "tool." .. mode .. "."
	local function l( token_suffix, label )
		language.Add( t .. token_suffix, label )
	end

	l( "name", "Sound Emitter (+)" )
	l( "desc", "Create sound emitters" )
	l( "left", "Create and weld, or update a sound emitter" )
	l( "right", "Create or update a sound emitter" )
	l( "reload", "Copy settings or model" )

	l( "sound", "Sound" )
	l( "length", "Play Length" )
	l( "looplength", "Loop Length" )
	l( "delay", "Initial Delay" )
	l( "toggle", "Toggle" )
	l( "dmgactivate", "Activate when damaged" )
	l( "dmgtoggle", "Toggle when damaged" )
	l( "volume", "Volume" )
	l( "pitch", "Pitch" )
	l( "key", "Sound Emitter Key" )
	l( "nocollide", "No-collide" )
	l( "autolength", "Calculate length" )
	l( "reverse", "Reverse" )
	l( "sndlvl", "Sound Level" )
	l( "dsp", "Digital Signal Processing" )
	l( "usescriptpitch", "Use Soundscript Pitch" )
	l( "nostoptoggle", "Toggle always plays" )
	l( "samelength", "Use play length as loop length" )
	l( "fadein", "Fade-in duration" )
	l( "fadeout", "Fade-out duration" )
	t = nil
	l = nil

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
		for i, k in ipairs( dupeKeys ) do
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

		if t.dsp and GetConVar( "sv_mv_soundemitter_check_dsp" ):GetInt() ~= 0 then
			local forbidden = { [35] = true, [36] = true, [37] = true, [39] = true }
			if forbidden[t.dsp] then
				ply:ChatPrint( "This DSP is forbidden! Changed from " .. t.dsp .. " to 0." )
				t.dsp = 0
			end
		end

		-- Limit the pitch
		if t.pitch then t.pitch = math.Clamp(t.pitch, 0, 255) end

		-- Limit the loop length
		if t.looplength and t.looplength > 0 then
			local minLoopLength = GetConVar( "sv_mv_soundemitter_min_looplength" ):GetFloat() or 0 -- error if cvar doesn't exist
			if t.looplength < minLoopLength then
				if ply then ply:ChatPrint( ( "Loop length too short! Changed from %s to %.2f second(s)." ):format( t.looplength, minLoopLength ) ) end
				t.looplength = minLoopLength
			end
		end

		-- Limit the sound level.
		if t.sndlvl then
			local maxSndLvl = GetConVar( "sv_mv_soundemitter_max_sndlvl" ):GetFloat() or 100
			-- Sound levels <= 1 play at infinite distances.
			if maxSndLvl > 0 and ( t.sndlvl <= 1 or t.sndlvl > maxSndLvl ) then
				if ply then ply:ChatPrint( ( "Sound level too high! Changed from %s to %.2f decibel(s)" ):format( t.sndlvl, maxSndLvl ) ) end
				t.sndlvl = maxSndLvl
			end
			t.sndlvl = math.Clamp( t.sndlvl, 0, 255 ) -- valid range
		end

		for duName, value in pairs( t ) do
			if value ~= nil then
				local name = emitterProperties[duName]
				if name then emitter["Set" .. name]( emitter, value ) end
				emitter[duName] = value
			end
		end

		if t.nocollide then emitter:SetCollisionGroup( COLLISION_GROUP_WORLD ) end
		if t.reverse then emitter:PreEmit() end

	end


	local function MakeMVSoundEmitter(  ply, pos, ang, ... ) -- look at dupeKeys table for ... args order !

		if not ply:CheckLimit( "mv_soundemitters" ) then return false end

		-- Get the emitter properties table
		local t = ( type( ... ) == "table" ) and ... or toMSEProperties( ... )

		if not ( t.model and util.IsValidModel( t.model ) ) then
			ply:ChatPrint( "Invalid model!" )
			return false
		end

		local emitter = ents.Create( "mv_soundemitter" ) or NULL
		if not emitter:IsValid() then return false end

		emitter:SetPos( pos )
		emitter:SetAngles( ang )
		emitter:SetModel( t.model )
		emitter:Spawn()
		updateMSE( emitter, ply, t )

		ply:AddCount( "mv_soundemitters", emitter )
		ply:AddCleanup( "mv_soundemitter", emitter )

		return emitter
	end

	duplicator.RegisterEntityClass( "mv_soundemitter", MakeMVSoundEmitter, "pos", "ang", unpack( dupeKeys ) )


	function TOOL:LeftClick( trace, do_weld )

		local ent = trace.Entity
		if ent and ent:IsPlayer() then return false end
		if do_weld == nil then do_weld = true end

		-- If there's no physics object then we can't constraint it.
		if do_weld and not util.IsValidPhysicsObject( ent, trace.PhysicsBone ) then return false end

		local ply = self:GetOwner()

		local t = toMSEProperties(
			self:GetClientInfo( "model" ),
			self:GetClientInfo( "sound" ),
			self:GetClientNumber( "length" ),
			self:GetClientNumber( "looplength" ),
			self:GetClientNumber( "delay" ),
			self:GetClientBool( "toggle" ),
			self:GetClientBool( "dmgactivate" ),
			self:GetClientBool( "dmgtoggle" ),
			self:GetClientNumber( "volume" ),
			self:GetClientNumber( "pitch" ),
			self:GetClientNumber( "key" ),
			false, -- nocollide isn't used yet
			self:GetClientBool( "autolength" ),
			self:GetClientBool( "reverse" ),
			self:GetClientNumber( "sndlvl" ),
			self:GetClientNumber( "dsp" ),
			self:GetClientBool( "usescriptpitch" ),
			self:GetClientBool( "nostoptoggle" ),
			self:GetClientBool( "samelength" ),
			self:GetClientNumber( "fadein" ),
			self:GetClientNumber( "fadeout" )
		)

		if isMSE( ent ) and ent:GetPlayer() == ply then

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

		undo.Create( "mv_soundemitter" )
			undo.AddEntity( emitter )

			if ent and do_weld then
				local weld = constraint.Weld( emitter, ent, trace.PhysicsBone, 0, 0, true, true )

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

		if not isentity( ent ) or not ent:IsValid() then return false end

		local pre = mode .. "_"
		local ply = self:GetOwner()
		local model = ent:GetModel()
		if not isMSE( ent ) then
			if model then
				ply:ConCommand( ( "%smodel %s" ):format( pre, model ) )
				return true
			end
			return false
		end

		for duName, name in pairs( emitterProperties ) do
			local getter = name and ent["Get" .. name]
			local val
			if getter then val = getter( ent ) end
			if val == nil then val = ent[duName] end -- dupekey fallback
			if val ~= nil then
				if type(val) == "number" then val = math.Round(val, 2) end
				ply:ConCommand( ( "%s%s %s" ):format( pre, duName, val ) )
			end
		end

		-- Fix for copying original addon sound emitters which always return 0 for key.
		local key = ent:GetKey()
		if ( not key ) or ( key == 0 and key ~= ent.key ) then
			ply:ConCommand( ("%skey %s" ):format( pre, ent.key ) )
		end

		return true

	end


end


local cvarList = TOOL:BuildConVarList()

function TOOL.BuildCPanel(cPanel)

	cPanel:ToolPresets( mode, cvarList )

	local t = "#tool." .. mode .. "."
	local function l( token_suffix )
		return language.GetPhrase( t .. token_suffix )
	end
	local pre = mode .. "_"
	local ply = LocalPlayer()
	local previewButton, stopButton, pitchSlider, lengthSlider

	cvars.AddChangeCallback( pre .. "sound", function( convar_name, value_old, value_new )
		pitchSlider:updatePitch()
		lengthSlider:updateLength()
	end, mode )

	cvars.AddChangeCallback( pre .. "pitch", function( convar_name, value_old, value_new )
		lengthSlider:updateLength()
	end, mode )

	local col_gray = Color( 240, 240, 240 )

	local function paint( panel, w, h )
		local margin = 5
		draw.RoundedBoxEx( 4, margin, margin, w - 2 * margin, h - margin, col_gray, true, true, true, true )
	end

	local propertySheet = vgui.Create( "DPropertySheet" )
	cPanel:AddItem( propertySheet )
	propertySheet:Dock( TOP )
	propertySheet:SetTall( 340 )
	propertySheet:SetBGColor( color_black )
	propertySheet:SetPadding( 0 )

	local function createSheet( label, icon, panel )
		panel = panel or vgui.Create( "DForm" )
			propertySheet:AddSheet( label, panel, icon )
			panel:SetPaintBackground( false )
			panel:DockPadding( 0, 0, 0, 5 )
			panel:SetExpanded( true )
			panel:Dock( TOP )
			panel:SetHeaderHeight( 0 )
			function panel:Paint( w, h ) paint( self, w, h ) end
		return panel
	end


	local soundNameSheet = createSheet( "Sound", "icon16/folder_find.png" )

		local sndList = vgui.Create( "DListView" )
		soundNameSheet:AddItem( sndList )
			sndList:SetSize( 80,200 )
			sndList:SetMultiSelect( false )
			sndList:AddColumn( "Preset Sounds" )
			for soundName, _ in pairs( list.Get( "MVSoundEmitterExtSound" ) ) do
				sndList:AddLine( soundName )
			end
			sndList:SortByColumn( 1 )
			local command = pre .. "sound"
			function sndList:OnRowSelected( rowIndex, row )
				-- Get the soundname at this cell
				local snd = list.Get( "MVSoundEmitterExtSound" )[row:GetValue( 1 )][ command ]
				if not snd then return end
				ply:ConCommand( command .. " " .. snd )
			end

		local soundTextEntry = soundNameSheet:TextEntry( l( "sound" ) .. ":", pre .. "sound" )
			soundTextEntry:SetTooltip( "A sound from the game content.\nSupports soundscripts, .mp3, .ogg, .wav." )

		-- Helper button for stream radios
		if scripted_ents.Get( "base_streamradio" ) then
			local streamRadioButton = vgui.Create( "DButton" )
			soundNameSheet:AddItem( streamRadioButton )
			streamRadioButton:SetText( "Send to Stream Radio" )
			streamRadioButton:SetImage( "icon16/phone_sound.png" )
			function streamRadioButton:DoClick()
				RunConsoleCommand( "streamradio_streamurl",soundConVar:GetString() )
				ply:EmitSound( "ambient/levels/prison/radio_random" .. math.random( 3, 14 ) .. ".wav" )
			end
		end


	local soundActivationSheet = createSheet( "Trigger", "icon16/transmit_edit.png", vgui.Create( "ControlPanel" ) )

		local keyBinder = soundActivationSheet:KeyBinder( l("key"), pre .. "key" )
			keyBinder:SetTooltip( "The keyboard key that can set on and off the sound emitter." )

		local toggleCB = soundActivationSheet:CheckBox( l( "Toggle" ), pre .. "toggle" )
			toggleCB:SetTooltip( "Toggle turning the sound emitter on and off." )

		local noStopToggleCB = soundActivationSheet:CheckBox( l( "nostoptoggle" ), pre .. "nostoptoggle" )
			noStopToggleCB:SetTooltip( "Toggling the sound emitter starts or restarts the sound, but never stops it.\nWorks only if '" .. toggleCB:GetText() .. "' is checked." )

		function toggleCB:OnChange( isChecked )
			noStopToggleCB:SetEnabled( isChecked )
		end

		local reverseCB = soundActivationSheet:CheckBox( l( "reverse" ), pre .. "reverse" )
			reverseCB:SetTooltip( "If checked, the default state will be on instead of off." )

		local dmgActivateCB = soundActivationSheet:CheckBox( l( "dmgactivate" ), pre .. "dmgactivate" )
			dmgActivateCB:SetTooltip( "The emitter will activate if something damages it." )

		local dmgToggleCB = soundActivationSheet:CheckBox( l( "dmgtoggle" ), pre .. "dmgtoggle" )
			dmgToggleCB:SetTooltip( "If something damages the emitter it will toggle but only if '" .. dmgActivateCB:GetText() .. "' is on." )

		function dmgActivateCB:OnChange( isChecked )
			dmgToggleCB:SetEnabled( isChecked )
		end


	local soundEffectsSheet = createSheet( "Effects", "icon16/control_equalizer_blue.png" )

		local volumeSlider = soundEffectsSheet:NumSlider( l( "volume" ) .. ":", pre .. "volume", 0, 1 )
			volumeSlider:SetTooltip( "The loudness of the sound.\nThis doesn't affect how far the sound can be heard." )

		-- Valid sound level values are int 0 to 255 (https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/sp/src/public/soundflags.h#L53)
		local maxLevelConVar = GetConVar( "sv_mv_soundemitter_max_sndlvl" )
		local levelSlider = soundEffectsSheet:NumSlider( l( "sndlvl" ) .. ":", pre .. "sndlvl", 0, 255, 0 )
			levelSlider:SetTooltip( "The sound's level, in decibels (dB).\nThis affects how far the sound can be heard.\nBelow 1 dB sounds play globally. Very high values can reduce volume." )
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

		pitchSlider = soundEffectsSheet:NumSlider( l( "pitch" ) .. ":", pre .. "pitch", 0, 255 )
			pitchSlider:SetTooltip( "The pitch percentage of the sound.\nSet to 100 for no modification." )

		local scriptPitchCheck = soundEffectsSheet:CheckBox( l( "usescriptpitch" ), pre .. "usescriptpitch" )
			scriptPitchCheck:SetTooltip( "Use the (random) pitch that is saved in soundscripts.\nIf the pitch is random, shown value will be an average.\nWorks only for soundscripts (sounds which don't end with .wav/.ogg/.mp3/...)" )
			function scriptPitchCheck:OnChange( isChecked )
				pitchSlider:updatePitch()
			end

		function pitchSlider:updatePitch( snd )
			self:SetEnabled( true )
			if scriptPitchCheck:GetChecked() then
				local pitch = MVSoundEmitter.GetSoundScriptMeanPitch( soundConVar:GetString() or "" )
				if pitch then
					self:SetValue( pitch )
					self:SetEnabled( false )
				end
			end
		end


		local dspBigHelp = soundEffectsSheet:Help( l( "dsp" ) .. ":" )
			dspBigHelp:SetTooltip( "Apply reverb, delay, stereo effect, tone, etc .. \nCheck the wiki for more info.\nhttps://wiki.facepunch.com/gmod/DSP_Presets" )

		local dspComboBox, dspComboBoxLabel = soundEffectsSheet:ComboBox( "", pre .. "dsp" )
			dspComboBoxLabel:SetWide( 0 )
			dspComboBox:Dock( TOP )
			dspComboBox:SetSortItems( false )
			for _, dsp in pairs( MVSoundEmitter.DSP ) do
				dspComboBox:AddChoice( MVSoundEmitter.DSPInfo[dsp].name, dsp, dsp == 1 )
			end

		local dspSlider = soundEffectsSheet:NumSlider( "Enter manually:", pre .. "dsp", 0, 133, 0 )
			local dspHelp = soundEffectsSheet:ControlHelp( "" )
			function dspSlider:OnValueChanged( dsp )
				local info = MVSoundEmitter.DSPInfo[dsp]
				local text = info and info.desc or "This DSP preset is invalid."
				if text == "" then text = "This DSP preset has unknown effects." end
				dspHelp:SetText( text )
			end

	local soundTimingSheet = createSheet( "Timing", "icon16/clock_edit.png" )

		local delaySlider = soundTimingSheet:NumSlider( l( "delay" ) .. ":", pre .. "delay", 0, 100 )
			delaySlider:SetTooltip( "How many seconds to wait before starting the sound emitter." )

		lengthSlider = soundTimingSheet:NumSlider( l( "length" ) .. ":", pre .. "length", 0, 100 )
			lengthSlider:SetTooltip( "How many seconds before the sound emitter turns off, when the sound is started.\nDuring loops, only the sound will stop, not the sound emitter.\nSet to 0 or below to never stop." )

		local autoCheck = soundTimingSheet:CheckBox( l( "autolength" ), pre .. "autolength" )
			autoCheck:SetTooltip( "Set the play length to an approximation of the length of the sound.\nThis isn't always accurate." )
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

		local loopSlider = soundTimingSheet:NumSlider( l( "looplength" ) .. ":", pre .. "looplength", 0, 100 )
			loopSlider:SetTooltip( "How often the sound replays, in seconds.\nSet to 0 or below for never (no looping)." )

		local sameCheck = soundTimingSheet:CheckBox( l( "samelength" ), pre .. "samelength" )
			sameCheck:SetTooltip( "Set the Loop Length to the same duration as the Play Length." )
			function sameCheck:OnChange( isChecked )
				loopSlider:SetEnabled( not isChecked )
			end

		local fadeInSlider = soundTimingSheet:NumSlider( l( "fadein" ) .. ":", pre .. "fadein", 0, 10 )
			fadeInSlider:SetTooltip( "How many seconds it takes for the sound's volume to reach its max anytime its played." )

		local fadeOutSlider = soundTimingSheet:NumSlider( l( "fadeout" ) .. ":", pre .. "fadeout", 0, 10 )
			fadeOutSlider:SetTooltip( "How many seconds it takes for the volume to drop to zero.\nFade out will begin:\n- (" .. l( "length" ) .. " - " .. l( "fadeout" ) .. ") second(s) after the sound's start\n- Whenever the sound is stopped manually." )

		function lengthSlider.Scratch:OnValueChanged( value )
			if sameCheck:GetChecked() then
				loopSlider.Scratch:SetValue( value )
				loopSlider:ValueChanged( value )
			end
		end


	previewButton, stopButton = vgui.Create( "DButton" ), vgui.Create( "DButton" )
		previewButton:SetText( "Sound Preview" )
		previewButton:SetImage( "icon32/unmuted.png" )
		previewButton:SetTooltip( "Only takes Sound Effects options into account." )
		previewButton:Dock( TOP )
		previewButton.DoClick = function()
			if previewButton.mySound then previewButton.mySound:Stop() end
			local snd = CreateSound( ply, soundConVar:GetString() or "" )
			snd:SetDSP( dspConVar:GetInt() or 0 )
			snd:PlayEx( volumeConVar:GetFloat() or 1, pitchConVar:GetFloat() or 100 )
			previewButton.mySound = snd
		end
		stopButton:SetText( "Stop the Sound Preview" )
		stopButton:SetImage( "icon32/muted.png" )
		stopButton:DockMargin( 15, 0, 0, 0 )
		stopButton:Dock( TOP )
		stopButton.DoClick = function()
			if previewButton.mySound then
				previewButton.mySound:Stop()
				previewButton.mySound = nil
			end
		end
		cPanel:AddItem( previewButton, stopButton )


	cPanel:PropSelect( "Sound emitter model", pre .. "model", list.Get( "MVSoundEmitterExtModel" ), 2)
	cPanel:TextEntry( "Model name:", pre .. "model" )

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

	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch + 90
	ent:SetAngles( ang )

	ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )

	ent:SetNoDraw( false )

end


function TOOL:Think()

	local ent = self.GhostEntity
	local model = self:GetClientInfo( "model" )
	if not ( ent and ent:IsValid() ) or ( ent:GetModel() ~= model ) then
		self:MakeGhostEntity( model, vector_origin, angle_zero )
	end

	self:UpdateGhostMVSoundEmitter( ent, self:GetOwner() )

end
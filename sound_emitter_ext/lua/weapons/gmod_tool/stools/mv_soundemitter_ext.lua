
local mode = TOOL.Mode

TOOL.Category		= "Construction"
TOOL.Name			= "#Tool."..mode..".name"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "model" ]		= "models/props_lab/citizenradio.mdl"
TOOL.ClientConVar[ "sound" ] 		= "coast.siren_citizen"
TOOL.ClientConVar[ "length" ]		= "-1"
TOOL.ClientConVar[ "autolength"  ]	= "0"
TOOL.ClientConVar[ "looping" ]		= "1"
TOOL.ClientConVar[ "delay" ]		= "0"
TOOL.ClientConVar[ "toggle" ]		= "0"
TOOL.ClientConVar[ "dmgactivate" ] 	= "0"
TOOL.ClientConVar[ "dmgtoggle" ] 	= "0"
TOOL.ClientConVar[ "key"    ] 		= "38"
TOOL.ClientConVar[ "volume" ]		= "100"
TOOL.ClientConVar[ "pitch"  ]		= "100"
TOOL.ClientConVar[ "reverse" ]		= "0"



if SERVER then
	if !ConVarExists("sbox_maxmv_soundemitters") then
		CreateConVar("sbox_maxmv_soundemitters",3)
	end
elseif CLIENT then

	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
		{ name = "reload" }
	}
	
	language.Add( "Tool."..mode..".name", "Sound Emitter (+)" )
	language.Add( "Tool."..mode..".desc", "Create a sound emitter" )
	language.Add( "Tool."..mode..".left", "Create or update a sound emitter" )
	language.Add( "Tool."..mode..".right", "Same as left click but welds the sound emitter." )
	language.Add( "Tool."..mode..".reload", "Copy settings or model." )

	language.Add( "SBoxLimit_modes", "You've hit the Sound Emitter limit!" )
	language.Add( "Undone_mode", "Undone Sound Emitter" )
	language.Add( "Cleanup_mode", "Sound Emitters" )
	language.Add( "Cleaned_mode", "Cleaned up all Sound Emitters" )
end

cleanup.Register( "mv_soundemitter" )


--DEPRECATED except if people modify the txt file

if file.Exists("soundemitter_ext/custom_sound_presets.txt", "DATA") then
	local SoundPresets = util.KeyValuesToTable(file.Read("soundemitter_ext/custom_sound_presets.txt", "DATA"))
	for key, value in pairs(SoundPresets) do
		list.Set( "MVSoundEmitterExtSound", key, value )
	end
end



/*----------------------------
--		   FUNCTIONS	    --
----------------------------*/

local function isMSE( emitter )
	return isentity( emitter) and emitter:IsValid() and ( emitter:GetClass() == "mv_soundemitter" )
end

if CLIENT then
	
	function TOOL:LeftClick( trace )	return not( trace.Entity and trace.Entity:IsPlayer() ) end
	function TOOL:RightClick( trace )	return self:LeftClick( trace ) end
	function TOOL:Reload( trace )		return isMSE( trace.Entity ) end

elseif SERVER then


	local function updateMSE( emitter, model, sound, length, looping, delay, toggle, dmgactivate, dmgtoggle, volume, pitch, key, ply, nocollide, autolength, reverse )

		if not isMSE( emitter ) then return end

		if ply and not emitter:GetPlayer():IsPlayer() then emitter:SetPlayer(ply) end

		if pitch then
			pitch = math.Clamp(pitch, 0, 255)
			if autolength and sound then
				length = ( pitch <= 0 ) and -1 or ( SoundDuration( sound ) * 100 / pitch ) -- pitch is in percentage
			end
		end	

		local emitterProperties = {
			sound 		= "Sound",
			length		= "Length",
			looping		= "Looping",
			delay		= "Delay",
			toggle		= "Toggle",
			dmgactivate	= "DamageActivate",
			dmgtoggle	= "DamageToggle",
			volume		= "Volume",
			pitch		= "Pitch",
			key			= "Key",
			autolength	= "AutoLength",
			reverse		= "Reverse"
		}

		local newProperties = { -- Keys used by the duplicator
			model		= model,
			sound 		= sound,
			length		= length,
			looping		= looping,
			delay		= delay,
			toggle		= toggle,
			dmgactivate	= dmgactivate,
			dmgtoggle	= dmgtoggle,
			volume		= volume,
			pitch		= pitch,
			key			= key,
			nocollide 	= nocollide,
			autolength 	= autolength,
			reverse 	= reverse
		}

		for duName, value in pairs( newProperties ) do
			if value ~= nil then
				local name = emitterProperties[duName]
				if name then emitter["Set"..name]( emitter, value ) end
				emitter[duName] = value
			end
		end

		if nocollide then emitter:GetPhysicsObject():EnableCollisions( false ) end

		if reverse then emitter:PreEmit() end

	end

	
	local function MakeMVSoundEmitter(  ply, pos, ang, model, sound, length, looping, delay, toggle, dmgactivate, dmgtoggle, volume, pitch, key, nocollide, autolength, reverse  )

		if not ply:CheckLimit( "mv_soundemitters" ) then return false end

		if not ( model and model ~= "" and util.IsModelLoaded( model ) ) then
			ply:ChatPrint("Invalid model!")
			-- ply:EmitSound("buttons/button10.wav")
			return false
		end

		local emitter = ents.Create( "mv_soundemitter" )
		if not emitter:IsValid() then return false end

		emitter:SetPos( pos )
		emitter:SetAngles( ang )
		emitter:SetModel( model )
		emitter:Spawn()
		updateMSE( emitter, nil, sound, length, looping, delay, toggle, dmgactivate, dmgtoggle, volume, pitch, key, ply, nocollide, autolength, reverse )

		ply:AddCount( "mv_soundemitters", emitter )
		ply:AddCleanup( "mv_soundemitter", emitter )

		DoPropSpawnedEffect( emitter )

		return emitter
	end


	duplicator.RegisterEntityClass( "mv_soundemitter", MakeMVSoundEmitter, "pos", "ang", "model", "sound", "length", "looping", "delay", "toggle", "dmgactivate", "dmgtoggle", "volume", "pitch", "key", "nocollide", "autolength", "reverse" )


	function TOOL:LeftClick( trace, do_weld )

		local ent = trace.Entity
		if ent and ent:IsPlayer() then return false end
		if do_weld == nil then do_weld = true end

		-- If there's no physics object then we can't constraint it.
		if do_weld and not util.IsValidPhysicsObject( ent, trace.PhysicsBone ) then return false end

		local ply = self:GetOwner() -- attempt to index local 'self' (a nil value) sometimes

		local model			= self:GetClientInfo( "model" )
		local sound			= self:GetClientInfo( "sound" )
		local length		= self:GetClientNumber( "length" )
		local looping		= self:GetClientBool( "looping" )
		local delay			= self:GetClientNumber( "delay" )
		local toggle		= self:GetClientInfo( "toggle" )
		local dmgactivate	= self:GetClientInfo( "dmgactivate" )
		local dmgtoggle		= self:GetClientInfo( "dmgtoggle" )
		local volume		= self:GetClientNumber( "volume" )
		local pitch 		= self:GetClientNumber( "pitch" )
		local key   		= self:GetClientNumber( "key" )
		local autolength	= self:GetClientBool( "autolength" )
		local reverse		= self:GetClientBool( "reverse" )
		
		if isMSE( ent ) and ( ent:GetPlayer() == ply ) then

			updateMSE( ent, model, sound, length, looping, delay, toggle, dmgactivate, dmgtoggle, volume, pitch, key, nil, nil, autolength, reverse )
			return true

		end

		local pos = trace.HitPos
		local ang = trace.HitNormal:Angle()
		ang.pitch = ang.pitch + 90

		local emitter = MakeMVSoundEmitter( ply, pos, ang, model, sound, length, looping, delay, toggle, dmgactivate, dmgtoggle, volume, pitch, key, false, autolength, reverse )

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
		if isMSE( ent ) then

			ply:ConCommand(mode.."_model "..tostring(ent:GetModel()))
			ply:ConCommand(mode.."_sound "..tostring(ent:GetSound()))
			ply:ConCommand(mode.."_length "..tostring(ent:GetLength()))
			ply:ConCommand(mode.."_looping "..tostring(ent:GetLooping()))
			ply:ConCommand(mode.."_delay "..tostring(ent:GetDelay()))
			ply:ConCommand(mode.."_toggle "..tostring(ent:GetToggle()))
			ply:ConCommand(mode.."_dmgactivate "..tostring(ent:GetDamageActivate()))
			ply:ConCommand(mode.."_dmgtoggle "..tostring(ent:GetDamageToggle()))
			ply:ConCommand(mode.."_volume "..tostring(ent:GetVolume()))
			ply:ConCommand(mode.."_pitch "..tostring(ent:GetPitch()))
			ply:ConCommand(mode.."_autolength "..tostring(ent:GetAutoLength()))
			ply:ConCommand(mode.."_reverse "..tostring(ent:GetReverse()))

			-- Fix for copying original addon sound emitters. Their getter function always return 0...
			local key = ent:GetKey()
			if ( not key ) or ( key == 0 and key ~= ent.key ) then key = ent.key end
			ply:ConCommand(mode.."_key "..tostring(key))
		
		elseif ent:GetModel() then

			ply:ConCommand(mode.."_model "..tostring(ent:GetModel()))
		
		end

		return true

	end


end


local cvarList = TOOL:BuildConVarList()

function TOOL.BuildCPanel(cpanel)

	cpanel:ToolPresets( mode, cvarList )

	local panel = cpanel:KeyBinder( "Sound Emitter Key", mode.."_key" )
		panel:SetToolTip("The keyboard key that sets on or off the sound emitter")
	
	cpanel:PropSelect("Model", mode.."_model", list.Get("MVSoundEmitterModel"))	
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
		panel:SetToolTip( "A in-game sound name. Can be a .wav sound path or a soundscript." )

	local panel = cpanel:NumSlider( "Volume", mode.."_volume", 0, 100 )
		panel:SetToolTip( "The loudness of the sound, in percentage of max volume." )

	local panel = cpanel:NumSlider( "Pitch", mode.."_pitch", 0, 255 )
		panel:SetToolTip( "The pitch percentage of the sound." )
	
	local panel = cpanel:NumSlider( "Play Length", mode.."_length", -1, 300 )
		panel:SetToolTip( "How long before the sound stops or repeats, in seconds.\nSet to below 0 for infinite." )

	local checkbox = cpanel:CheckBox( "Calculate length", mode.."_autolength" )
		checkbox:SetToolTip( "Set the play length to the approximate length of the sound.\nThis can be inaccurate for self-looping sounds." )
	
	function checkbox:OnChange( isChecked )
		panel:SetEnabled( not isChecked )
	end

	local panel = cpanel:NumSlider( "Initial Delay", mode.."_delay", 0, 100 )
		panel:SetToolTip( "How long to wait before playing the sound (seconds)." )

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


/*----------------------------
--		    MODELS		    --
----------------------------*/


list.Set( "MVSoundEmitterModel", "models/props_lab/citizenradio.mdl", {})
list.Set( "MVSoundEmitterModel", "models/Items/car_battery01.mdl", {})
list.Set( "MVSoundEmitterModel", "models/props_c17/TrapPropeller_Engine.mdl", {})
list.Set( "MVSoundEmitterModel", "models/props_c17/tv_monitor01.mdl", {})
list.Set( "MVSoundEmitterModel", "models/props_wasteland/SpeakerCluster01a.mdl", {})
list.Set( "MVSoundEmitterModel", "models/props_trainstation/payphone001a.mdl", {})
--list.Set( "MVSoundEmitterModel", "models/props_italian/gramophone.mdl", {})


/* enable these if you have them
list.Set( "MVSoundEmitterModel", "models/jaanus/thruster_megaphn.mdl", {})
list.Set( "MVSoundEmitterModel", "models/jaanus/thruster_shoop.mdl", {})
list.Set( "MVSoundEmitterModel", "models/jaanus/thruster_invisi.mdl", {})
*/
-- For the addon to remain compatible with older versions (including the original addon), it's important that:
-- 	Old properties (the ones up to nocollide) stay in the order in which they were in the original addon
-- 	New properties (the ones starting from autolength and after) are in the order in which they were implemented
-- 	Properties are not renamed
-- TL;DR you can add properties to the END of that table but do not modify what's already here in any way (be it renaming properties or changing their order)
MVSoundEmitter.duplicatorKeys = {
	"model",
	"sound",
	"length",
	"looplength",
	"delay",
	"toggle",
	"dmgactivate",
	"dmgtoggle",
	"volume",
	"pitch",
	"key",
	"nocollide",
	"autolength",
	"reverse",
	"sndlvl",
	"dsp",
	"usescriptpitch",
	"nostoptoggle",
	"samelength",
	"fadein",
	"fadeout",
	"pitchrandamp",
	"maxloopcount",
	-- new properties come here
}


-- Returns a table with keys duplicatorKeys and values ...
function MVSoundEmitter.ToSoundEmitterProperties( ... )
	local values = { ... }
	local properties = {}
	for i, duplicatorKey in ipairs( MVSoundEmitter.duplicatorKeys ) do
		properties[duplicatorKey] = values[i]
	end
	return properties
end


-- Those are the properties you want to use a setter function on when the emitter is created.
MVSoundEmitter.soundEmitterProperties = MVSoundEmitter.ToSoundEmitterProperties(
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
	"FadeOut",
	"PitchRandAmp",
	"MaxLoopCount"
)



function MVSoundEmitter.UpdateSoundEmitter( emitter, ply, properties )

	if not MVSoundEmitter.IsSoundEmitter( emitter ) then return end

	-- false might once have been saved as "0"
	local bool_props = { "toggle", "dmgactivate", "dmgtoggle", "nocollide", "autolength", "reverse", "usescriptpitch", "nostoptoggle", "samelength" }
	for _, prop in ipairs( bool_props ) do
		if properties[prop] == "0" or properties[prop] == 0 then
			properties[prop] = false
		end
	end

	if ply and not emitter:GetPlayer():IsPlayer() then
		emitter:SetPlayer(ply)
	end
	ply = emitter:GetPlayer()

	if properties.dsp and GetConVar( "sv_mv_soundemitter_check_dsp" ):GetInt() ~= 0 then
		local forbidden = { [35] = true, [36] = true, [37] = true, [39] = true }
		if forbidden[properties.dsp] then
			ply:ChatPrint( "This DSP is forbidden! Changed from " .. properties.dsp .. " to 0." )
			properties.dsp = 0
		end
	end

	-- Limit the pitch
	if properties.pitch then properties.pitch = math.Clamp( properties.pitch, 0, 255 ) end
	if properties.pitchrandamp then properties.pitchrandamp = math.Clamp( properties.pitchrandamp, 0, 255 ) end

	-- Limit the loop length
	if properties.looplength and properties.looplength > 0 then
		local minLoopLength = GetConVar( "sv_mv_soundemitter_min_looplength" ):GetFloat() or 0 -- error if cvar doesn't exist
		if properties.looplength < minLoopLength then
			if ply then ply:ChatPrint( ( "Loop length too short! Changed from %s to %.2f second(s)." ):format( properties.looplength, minLoopLength ) ) end
			properties.looplength = minLoopLength
		end
	end

	-- Limit the sound level.
	if properties.sndlvl then
		local maxSndLvl = GetConVar( "sv_mv_soundemitter_max_sndlvl" ):GetFloat() or 100
		-- Sound levels <= 1 play at infinite distances.
		if maxSndLvl > 0 and ( properties.sndlvl <= 1 or properties.sndlvl > maxSndLvl ) then
			if ply then ply:ChatPrint( ( "Sound level too high! Changed from %s to %.2f decibel(s)" ):format( properties.sndlvl, maxSndLvl ) ) end
			properties.sndlvl = maxSndLvl
		end
		properties.sndlvl = math.Clamp( properties.sndlvl, 0, 255 ) -- valid range
	end

	for duplicatorKey, value in pairs( properties ) do
		if value ~= nil then
			local name = MVSoundEmitter.soundEmitterProperties[duplicatorKey]
			if name then emitter["Set" .. name]( emitter, value ) end
			emitter[duplicatorKey] = value
		end
	end

	if properties.nocollide then emitter:SetCollisionGroup( COLLISION_GROUP_WORLD ) end
	if properties.reverse then emitter:PreEmit() end

end



function MVSoundEmitter.MakeSoundEmitter(  ply, pos, ang, ... ) -- look at duplicatorKeys table for ... args order !

	if not ply:CheckLimit( "mv_soundemitters" ) then return false end

	-- Get the emitter properties table
	local properties = ( type( ... ) == "table" ) and ... or MVSoundEmitter.ToSoundEmitterProperties( ... )

	if not ( properties.model and util.IsValidModel( properties.model ) ) then
		ply:ChatPrint( "Invalid model!" )
		return false
	end

	local emitter = ents.Create( "mv_soundemitter" ) or NULL
	if not emitter:IsValid() then return false end

	emitter:SetPos( pos )
	emitter:SetAngles( ang )
	emitter:SetModel( properties.model )
	emitter:Spawn()
	MVSoundEmitter.UpdateSoundEmitter( emitter, ply, properties )

	ply:AddCount( "mv_soundemitters", emitter )
	ply:AddCleanup( "mv_soundemitter", emitter )

	return emitter
end



duplicator.RegisterEntityClass( "mv_soundemitter", MVSoundEmitter.MakeSoundEmitter, "pos", "ang", unpack( MVSoundEmitter.duplicatorKeys ) )
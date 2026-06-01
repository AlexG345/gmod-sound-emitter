MVSoundEmitter = {}

-- Returns the average pitch of a sound script
function MVSoundEmitter.GetSoundScriptMeanPitch( name )

	local s = sound.GetProperties( name )
	return s and ( ( istable( s.pitch ) and ( s.pitch[1] + s.pitch[2] ) / 2 ) or s.pitch )

end


--------------
--  Models  --
--------------


local function f( models )
	for _, model in ipairs( models ) do
		list.Set( "MVSoundEmitterExtModel", model, {})
	end
end

f( {
	"models/props_lab/citizenradio.mdl",
	"models/Items/car_battery01.mdl",
	"models/props_c17/TrapPropeller_Engine.mdl",
	"models/props_c17/tv_monitor01.mdl",
	"models/props_wasteland/SpeakerCluster01a.mdl",
	"models/props_trainstation/payphone001a.mdl",
	"models/props_lab/reciever01a.mdl",
	"models/props_lab/reciever01b.mdl",
	"models/props_c17/consolebox01a.mdl",
	"models/props_c17/consolebox03a.mdl",
	"models/props_c17/consolebox05a.mdl",
	"models/props_lab/plotter.mdl",
	"models/props_trainstation/payphone_reciever001a.mdl",
} )

if IsMounted( "cstrike" ) then
	f( {
		"models/props/de_prodigy/desk_console1b.mdl",
		"models/props/de_inferno/bell_large.mdl",
		"models/props/de_inferno/bell_smallb.mdl",
		"models/props/cs_office/radio.mdl",
		"models/props/cs_office/radio_p1.mdl",
		"models/props/cs_militia/oldphone01.mdl",
	} )

end


--------------
--  Sounds  --
--------------


function f( tag, namedSounds )

	for _, namedSound in ipairs( namedSounds ) do
		local label = namedSound[1]
		if tag then label = tag .. " " .. label end
		list.Set(
			"MVSoundEmitterExtSound",
			label,
			{ mv_soundemitter_ext_sound = namedSound[2] }
		)
	end
end

if IsMounted( "portal" ) then
	f( "[Music] Portal -", {
		{ "4000 Degrees Kelvin", "music/portal_4000_degrees_kelvin.mp3" },
		{ "Android Hell", "music/portal_android_hell.mp3" },
		{ "No Cake for You", "music/portal_no_cake_for_you.mp3" },
		{ "Party Escort", "music/portal_party_escort.mp3" },
		{ "Procedural Jiggle Bone", "music/portal_procedural_jiggle_bone.mp3" },
		{ "Self Esteem Fund", "music/portal_self_esteem_fund.mp3" },
		{ "Stop what you are doing", "music/portal_stop_what_you_are_doing.mp3" },
		{ "Still Alive", "music/portal_still_alive.mp3" },
		{ "Subject Name Here", "music/portal_subject_name_here.mp3" },
		{ "Taste of Blood", "music/portal_taste_of_blood.mp3" },
		{ "You can't escape you know", "music/portal_you_cant_escape_you_know.mp3" },
	} )
end

if IsMounted( "tf2" ) then
	f( "[Music] TF2 -", {
		{ "Main Theme", "ui/gamestartup1.mp3" },
		{ "Shock and Awe", "ui/gamestartup2.mp3" },
		{ "Duty Calls", "ui/gamestartup3.mp3" },
		{ "The Art of War", "ui/gamestartup4.mp3" },
	} )
end

f( "[Music] HL1 -", {
	{ "song3", "music/HL1_song3.mp3" },
	{ "song5", "music/HL1_song5.mp3" },
	{ "song6", "music/HL1_song6.mp3" },
	{ "song9", "music/HL1_song9.mp3" },
	{ "song10", "music/HL1_song10.mp3" },
	{ "song11(startup vid)", "music/HL1_song11.mp3" },
	{ "song14", "music/HL1_song14.mp3" },
	{ "song15", "music/HL1_song15.mp3" },
	{ "song17", "music/HL1_song17.mp3" },
	{ "song19", "music/HL1_song19.mp3" },
	{ "song20", "music/HL1_song20.mp3" },
	{ "song21", "music/HL1_song21.mp3" },
	{ "song24", "music/HL1_song24.mp3" },
	{ "song25-Remix 3", "music/HL1song25_REMIX3.mp3" },
	{ "song26", "music/HL1_song26.mp3" },
} )

f( "[Music] HL2 -", {
	{ "intro", "music/HL2_intro.mp3" },
	{ "song0", "music/HL2_song0.mp3" },
	{ "song1", "music/HL2_song1.mp3" },
	{ "song2", "music/HL2_song2.mp3" },
	{ "song3", "music/HL2_song3.mp3" },
	{ "song4", "music/HL2_song4.mp3" },
	{ "song6", "music/HL2_song6.mp3" },
	{ "song7", "music/HL2_song7.mp3" },
	{ "song8", "music/HL2_song8.mp3" },
	{ "song10", "music/HL2_song10.mp3" },
	{ "song11", "music/HL2_song11.mp3" },
	{ "song12", "music/HL2_song12_long.mp3" },
	{ "song13", "music/HL2_song13.mp3" },
	{ "song14", "music/HL2_song14.mp3" },
	{ "song15(GunGame win)", "music/HL2_song15.mp3" },
	{ "song16", "music/HL2_song16.mp3" },
	{ "song17", "music/HL2_song17.mp3" },
	{ "song19", "music/HL2_song19.mp3" },
	{ "song20-submix0", "music/HL2_song20_submix0.mp3" },
	{ "song20-submix4", "music/HL2_song20_submix4.mp3" },
	{ "song23-SuitSong3", "music/HL2_song23_SuitSong3.mp3" },
	{ "song25-Teleporter", "music/HL2_song25_Teleporter.mp3" },
	{ "song26", "music/HL2_song26.mp3" },
	{ "song26-trainstation1", "music/HL2_song26_trainstation1.mp3" },
	{ "song27-trainstation2", "music/HL2_song27_trainstation2.mp3" },
	{ "song28", "music/HL2_song28.mp3" },
	{ "song29", "music/HL2_song29.mp3" },
	{ "song30", "music/HL2_song30.mp3" },
	{ "song31", "music/HL2_song31.mp3" },
	{ "song32", "music/HL2_song32.mp3" },
	{ "song33", "music/HL2_song33.mp3" },
	{ "radio1", "music/radio1.mp3" },
	{ "Ravenholm", "music/Ravenholm_1.mp3" },
} )

if IsMounted( "hl2" ) then
	f( "[Music] Ep1 -", {
		{ "song1", "music/VLVX_song1.mp3" },
		{ "song2", "music/VLVX_song2.mp3" },
		{ "song4", "music/VLVX_song4.mp3" },
		{ "song8", "music/VLVX_song8.mp3" },
		{ "song11", "music/VLVX_song11.mp3" },
		{ "song12", "music/VLVX_song12.mp3" },
		{ "song18", "music/VLVX_song18.mp3" },
		{ "song19a", "music/VLVX_song19a.mp3" },
		{ "song19b", "music/VLVX_song19b.mp3" },
		{ "song21", "music/VLVX_song21.mp3" },
		{ "Combine Battle", "ep_song8" },
		{ "Elevator Showdown", "ep_song9" },
		{ "Hospital Part 2", "ep_song10" },
	} )

	f( "[Music] Ep2 -", {
		{ "song0", "music/VLVX_song0.mp3" },
		{ "song3", "music/VLVX_song3.mp3" },
		{ "song9", "music/VLVX_song9.mp3" },
		{ "song15", "music/VLVX_song15.mp3" },
		{ "song20", "music/VLVX_song20.mp3" },
		{ "song22", "music/VLVX_song22.mp3" },
		{ "song23", "music/VLVX_song23.mp3" },
		{ "song23ambient", "music/VLVX_song23ambient.mp3" },
		{ "song24", "music/VLVX_song24.mp3" },
		{ "song25", "music/VLVX_song25.mp3" },
		{ "song26", "music/VLVX_song26.mp3" },
		{ "song27", "music/VLVX_song27.mp3" },
		{ "song28", "music/VLVX_song28.mp3" },
	} )
end

f( nil, {
	{ "No Sound", "common/null.wav" }
} )

f( "[Siren]", {
	{ "APC Alarm", "d1_trainstation.apc_alarm_loop1" },
	{ "Alarm Bell", "d1_canals.Floodgate_AlarmBellLoop" },
	{ "Beta HL2 Siren", "ambient/alarms/city_siren_loop2.wav" },
	{ "Bunker Siren", "coast.bunker_siren1" },
	{ "Combine Bank Alarm 1", "Streetwar.d3_c17_10a_siren" },
	{ "Combine Bank Alarm 2", "Streetwar.d3_c17_10b_alarm1" },
	{ "Combine Scanner Alarm", "NPC_CScanner.DiveBomb" },
	{ "Distant Citadel Siren", "Trainyard.distantsiren" },
	{ "Helicopter Crash Alarm", "NPC_AttackHelicopter.CrashingAlarm1" },
	{ "Helicopter Damaged Alarm", "NPC_AttackHelicopter.BadlyDamagedAlert" },
	{ "Helicopter Megabomb Alert", "NPC_AttackHelicopter.MegabombAlert" },
	{ "Turret Alert", "NPC_FloorTurret.Alert" },
	{ "Teleport Alarm", "k_lab.teleport_alarm" },
} )

f( "[Music]", {
	{ "Suit Song 3", "song23" },
	{ "Song 25 Remix", "song_credits_2" },
	{ "GMan Radio", "d1_trainstation.RadioMusic" },
} )

f( "[SFX - Misc]", {
	{ "Zombie Breathe", "NPC_PoisonZombie.Moan1" },
	{ "Idle Zombies", "Zombie.Idle" },
	{ "Helicopter Rotor", "NPC_CombineGunship.RotorSound" },
	{ "Heartbeat", "k_lab.teleport_heartbeat" },
	{ "Breathing", "k_lab.teleport_breathing" },
	{ "Playground Memory", "d1_trainstation.playground_memory" },
	{ "Crying", "d1_trainstation.cryingloop" },
} )

f( "[SFX - Vehicle]", {
	{ "ATV Engine Start", "ATV_engine_start" },
	{ "ATV Engine Idle", "ATV_engine_idle" },
	{ "ATV Engine Gear 1", "ATV_firstgear" },
	{ "ATV Engine Gear 2", "ATV_secondgear" },
	{ "ATV Engine Gear 3", "ATV_thirdgear" },
	{ "ATV Engine Gear 4", "ATV_fourthgear" },
	{ "ATV Engine Stop", "ATV_engine_stop" },
	{ "ATV Engine Reverse", "ATV_reverse" },
	{ "ATV Engine Turbo", "ATV_turbo_on" },
	{ "Crane Engine Start", "Crane_engine_start" },
	{ "Crane Engine Idle", "Crane_engine_idle" },
	{ "Crane First Gear", "Crane_firstgear" },
	{ "Crane Magnet Creak", "Crane_magnet_creak" },
	{ "Airboat Engine Start", "Airboat_engine_start" },
	{ "Airboat Engine Idle", "Airboat_engine_idle" },
	{ "Airboat Engine Full Throttle", "Airboat_engine_fullthrottle" },
	{ "Airboat Fan Idle", "Airboat_fan_idle" },
	{ "Airboat Fan Full Throttle", "Airboat_fan_fullthrottle" },
	{ "Airboat Engine Stop", "Airboat_engine_stop" },
	{ "APC Engine Start", "apc_engine_start" },
	{ "APC Engine Idle", "apc_engine_idle" },
	{ "APC Engine Gear 1", "apc_firstgear" },
	{ "APC Engine Stop", "apc_engine_stop" },
} )


-------------------
--  DSP Presets  --
-------------------

-- yes this is crappy
MVSoundEmitter.DSP = {
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
	10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
	20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
	30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
	40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
	50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
	100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
	110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
	120, 121, 122, 123, 124, 125, 126, 127, 128, 129,
	130, 131, 132, 133
}

MVSoundEmitter.DSPInfo = {
	[0] = { name = "NULL PRESET", desc = "The default, non-processed sound. Disables map-area-specific DSP effects." },
	[1] = { name = "AUTO PRESET", desc = "The default processing according to your position in the map." },
	[2] = { name = "Metallic S", desc = "Decreases stereo separation and has a slight echo." },
	[3] = { name = "Metallic M", desc = "Decreases stereo separation. Appears to have 2 delay effects, one quick and one slow." },
	[4] = { name = "Metallic L", desc = "Decreases stereo separation. Appears to have 2 delay effects, as well as a large reverb. Lower frequencies tend to 'bounce' much more." },
	[5] = { name = "Tunnel S", desc = "Small tunnel, such as an air vent. The sound 'bounces' very quickly, similar to Brite S, but with a more convincing effect." },
	[6] = { name = "Tunnel M", desc = "Medium tunnel, such as a narrow train tube." },
	[7] = { name = "Tunnel L", desc = "Large tunnel. Tends to have a 150hz ring." },
	[8] = { name = "Chamber S", desc = "Clean sound with a slight reverb and long echo." },
	[9] = { name = "Chamber M", desc = "Same as Chamber S, with more noticeable effects." },
	[10] = { name = "Chamber L", desc = "Same as Chamber M, with cleaner, more direct sound." },
	[11] = { name = "Brite S", desc = "Small tunnel with thin metal walls. Tends to have a 100hz ring. Similar to HL1's air vent processing." },
	[12] = { name = "Brite M", desc = "Medium chamber with a 500hz ring." },
	[13] = { name = "Brite L", desc = "Powdery, suppressed effect with a 300hz ring." },
	[14] = { name = "Water S", desc = "Muffles higher frequencies as if underwater." },
	[15] = { name = "Water M", desc = "Muffles mid-to-high frequencies as if underwater." },
	[16] = { name = "Water L", desc = "Same as Water M, with much more echo." },
	[17] = { name = "Concrete S", desc = "Decreases stereo separation and gives the sound some bounce." },
	[18] = { name = "Concrete M", desc = "Decreases stereo separation and muffles lower frequencies." },
	[19] = { name = "Concrete L", desc = "Mostly indistinguishable from Concrete M." },
	[20] = { name = "Outside S", desc = "" },
	[21] = { name = "Outside M", desc = "" },
	[22] = { name = "Outside L", desc = "" },
	[23] = { name = "Cavern S", desc = "" },
	[24] = { name = "Cavern M", desc = "" },
	[25] = { name = "Cavern L", desc = "" },
	[26] = { name = "Weird 1", desc = "Loud echo with increased high frequencies." },
	[27] = { name = "Weird 2", desc = "The exact same as Weird 1." },
	[28] = { name = "Weird 3", desc = "The exact same as Weird 1." },
	[29] = { name = "Weird 4", desc = "The exact same as Weird 1." },
	[30] = { name = "Lowpass 1", desc = "\"FACING AWAY\" Decreases high frequencies." },
	[31] = { name = "Lowpass 2", desc = "\"FACING AWAY + 80ms delay\" Decreases high frequencies even more. Sound is delayed by 80ms" },
	[32] = { name = "Explosion Ring 1", desc = "Briefly muffles all noise and returns to the previous active preset after a short time." },
	[33] = { name = "Explosion Ring 2", desc = "The exact same as Explosion Ring 1." },
	[34] = { name = "Explosion Ring 3", desc = "The exact same as Explosion Ring 1." },
	[35] = { name = "Shock Muffle 1", desc = "The high-pitched ringing noise heard when taking explosive damage. Returns to the previous active preset after a short time." },
	[36] = { name = "Shock Muffle 2", desc = "The exact same as Shock Muffle 1." },
	[37] = { name = "Shock Muffle 3", desc = "The exact same as Shock Muffle 1." },
	[38] = { name = "Distorted Speaker", desc = "Extreme distortion and compression, played through a cheap speaker." },
	[39] = { name = "Strider Pre-Fire", desc = "A brief, 1-second buzzing noise that muffles other sound and fades away." },
	[40] = { name = "Spatial Delay", desc = "\"PLAYER SPATIAL (WALL) DELAY\" Sound is delayed by 100ms." },
	[41] = { name = "Spatial 1", desc = "No effect" },
	[42] = { name = "Spatial 2", desc = "No effect" },
	[43] = { name = "Spatial 3", desc = "No effect" },
	[44] = { name = "Test Preset 1", desc = "Speeds up all sound by 10% and has a slight bitcrushed tone." },
	[45] = { name = "Test Preset 2", desc = "Slows down all sound by 10% and has a slight bitcrushed tone." },
	[46] = { name = "Test Preset 3", desc = "All sound under a certain volume is muted. Sounds fade in slightly." },
	[47] = { name = "Test Preset 4", desc = "All sounds are repeated a few times in quick succession." },
	[48] = { name = "Test Preset 5", desc = "Similar to Test Preset 3, with a higher sound threshold and quicker fade-in." },
	[49] = { name = "Test Preset 6", desc = "No effect" },
	[50] = { name = "Unnamed", desc = "No effect" },
	[51] = { name = "Unnamed", desc = "No effect" },
	[52] = { name = "Unnamed", desc = "No effect" },
	[53] = { name = "Unnamed", desc = "No effect" },
	[54] = { name = "Unnamed", desc = "No effect" },
	[55] = { name = "Seaker Louder", desc = "Mutes low-to-mid frequencies and applies distortion." },
	[56] = { name = "Speaker Very Small", desc = "Keeps only high frequencies and applies slight distortion." },
	[57] = { name = "Loudspeaker", desc = "Similar to Speaker Louder, with less distortion and more echo." },
	[58] = { name = "Speaker Small", desc = "Similar to Speaker Very Small, with slightly more mid frequencies." },
	[59] = { name = "Speaker Very Small", desc = "Almost the exact same as 56." },

	-- Internal Templates (100+)
	[100] = { name = "Unnamed", desc = "" },
	[101] = { name = "Unnamed", desc = "" },
	[102] = { name = "ROOM EMPTY SMALL BRIGHT", desc = "" },
	[103] = { name = "ROOM EMPTY HUGE DULL", desc = "" },
	[104] = { name = "ROOM DIFFUSE SMALL BRIGHT", desc = "" },
	[105] = { name = "ROOM DIFFUSE HUGE DULL", desc = "" },
	[106] = { name = "DUCT EMPTY SMALL BRIGHT", desc = "" },
	[107] = { name = "DUCT EMPTY HUGE DULL", desc = "" },
	[108] = { name = "DUCT DIFFUSE SMALL BRIGHT", desc = "" },
	[109] = { name = "DUCT DIFFUSE HUGE DULL", desc = "" },
	[110] = { name = "HALL EMPTY SMALL BRIGHT", desc = "" },
	[111] = { name = "HALL EMPTY HUGE DULL", desc = "" },
	[112] = { name = "HALL DIFFUSE SMALL BRIGHT", desc = "" },
	[113] = { name = "HALL DIFFUSE HUGE DULL", desc = "" },
	[114] = { name = "TUNNEL EMPTY SMALL BRIGHT", desc = "" },
	[115] = { name = "TUNNEL EMPTY HUGE DULL", desc = "" },
	[116] = { name = "TUNNEL DIFFUSE SMALL BRIGHT", desc = "" },
	[117] = { name = "TUNNEL DIFFUSE HUGE DULL", desc = "" },
	[118] = { name = "STREET EMPTY SMALL BRIGHT", desc = "" },
	[119] = { name = "STREET EMPTY HUGE DULL", desc = "" },
	[120] = { name = "STREET DIFFUSE SMALL BRIGHT", desc = "" },
	[121] = { name = "STREET DIFFUSE HUGE DULL", desc = "" },
	[122] = { name = "ALLEY EMPTY SMALL BRIGHT", desc = "" },
	[123] = { name = "ALLEY EMPTY HUGE DULL", desc = "" },
	[124] = { name = "ALLEY DIFFUSE SMALL BRIGHT", desc = "" },
	[125] = { name = "ALLEY DIFFUSE HUGE DULL", desc = "" },
	[126] = { name = "COURTYARD EMPTY SMALL BRIGHT", desc = "" },
	[127] = { name = "COURTYARD EMPTY HUGE DULL", desc = "" },
	[128] = { name = "COURTYARD DIFFUSE SMALL BRIGHT", desc = "" },
	[129] = { name = "COURTYARD DIFFUSE HUGE DULL", desc = "" },
	[130] = { name = "OPENSPACE EMPTY SMALL BRIGHT", desc = "" },
	[131] = { name = "OPENSPACE EMPTY HUGE DULL", desc = "" },
	[132] = { name = "OPENSPACE DIFFUSE SMALL BRIGHT", desc = "" },
	[133] = { name = "OPENSPACE DIFFUSE HUGE DULL", desc = "" }
}
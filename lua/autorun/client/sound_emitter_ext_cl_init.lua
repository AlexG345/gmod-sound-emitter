function getSoundScriptMeanPitch( soundName )

    local s = sound.GetProperties( soundName )
    return s and ( ( istable(s.pitch) and ( s.pitch[1] + s.pitch[2] ) / 2 ) or s.pitch )
    
end

local function f( model )
	if not model then return end
	list.Set( "MVSoundEmitterModel", model, {})
end

f( "models/props_lab/citizenradio.mdl" )
f( "models/Items/car_battery01.mdl" )
f( "models/props_c17/TrapPropeller_Engine.mdl" )
f( "models/props_c17/tv_monitor01.mdl" )
f( "models/props_wasteland/SpeakerCluster01a.mdl" )
f( "models/props_trainstation/payphone001a.mdl" )
f( "models/props_lab/reciever01a.mdl" )
f( "models/props_lab/reciever01b.mdl" )
f( "models/props_c17/consolebox01a.mdl" )
f( "models/props_c17/consolebox03a.mdl" )
f( "models/props_c17/consolebox05a.mdl" )
f( "models/props_lab/plotter.mdl" )
f( "models/props_trainstation/payphone_reciever001a.mdl" )

local function f( tag, label, sound )
	if not ( label and sound ) then return end
	if tag then label = tag.." "..label end
	list.Set( "MVSoundEmitterExtSound", label, {
		mv_soundemitter_ext_sound = sound
	})
end

if IsMounted("portal") then
	local t = "[Music] Portal -"
	f(t, "4000 Degrees Kelvin", "music/portal_4000_degrees_kelvin.mp3")
	f(t, "Android Hell", "music/portal_android_hell.mp3")
	f(t, "No Cake for You", "music/portal_no_cake_for_you.mp3")
	f(t, "Party Escort", "music/portal_party_escort.mp3")
	f(t, "Procedural Jiggle Bone", "music/portal_procedural_jiggle_bone.mp3")
	f(t, "Self Esteem Fund", "music/portal_self_esteem_fund.mp3")
	f(t, "Stop what you are doing", "music/portal_stop_what_you_are_doing.mp3")
	f(t, "Still Alive", "music/portal_still_alive.mp3")
	f(t, "Subject Name Here", "music/portal_subject_name_here.mp3")
	f(t, "Taste of Blood", "music/portal_taste_of_blood.mp3")
	f(t, "You can't escape you know", "music/portal_you_cant_escape_you_know.mp3")
end

if IsMounted("tf2") then
	t = "[Music] TF2 -"
	f(t, "Main Theme", "ui/gamestartup1.mp3")
	f(t, "Shock and Awe", "ui/gamestartup2.mp3")
	f(t, "Duty Calls", "ui/gamestartup3.mp3")
	f(t, "The Art of War", "ui/gamestartup4.mp3")
end

t = "[Music] HL1 -"
f(t, "song3", "music/HL1_song3.mp3")
f(t, "song5", "music/HL1_song5.mp3")
f(t, "song6", "music/HL1_song6.mp3")
f(t, "song9", "music/HL1_song9.mp3")
f(t, "song10", "music/HL1_song10.mp3")
f(t, "song11(startup vid)", "music/HL1_song11.mp3")
f(t, "song14", "music/HL1_song14.mp3")
f(t, "song15", "music/HL1_song15.mp3")
f(t, "song17", "music/HL1_song17.mp3")
f(t, "song19", "music/HL1_song19.mp3")
f(t, "song20", "music/HL1_song20.mp3")
f(t, "song21", "music/HL1_song21.mp3")
f(t, "song24", "music/HL1_song24.mp3")
f(t, "song25-Remix 3", "music/HL1song25_REMIX3.mp3")
f(t, "song26", "music/HL1_song26.mp3")

t = "[Music] HL2 -"
f(t, "intro", "music/HL2_intro.mp3")
f(t, "song0", "music/HL2_song0.mp3")
f(t, "song1", "music/HL2_song1.mp3")
f(t, "song2", "music/HL2_song2.mp3")
f(t, "song3", "music/HL2_song3.mp3")
f(t, "song4", "music/HL2_song4.mp3")
f(t, "song6", "music/HL2_song6.mp3")
f(t, "song7", "music/HL2_song7.mp3")
f(t, "song8", "music/HL2_song8.mp3")
f(t, "song10", "music/HL2_song10.mp3")
f(t, "song11", "music/HL2_song11.mp3")
f(t, "song12", "music/HL2_song12_long.mp3")
f(t, "song13", "music/HL2_song13.mp3")
f(t, "song14", "music/HL2_song14.mp3")
f(t, "song15(GunGame win)", "music/HL2_song15.mp3")
f(t, "song16", "music/HL2_song16.mp3")
f(t, "song17", "music/HL2_song17.mp3")
f(t, "song19", "music/HL2_song19.mp3")
f(t, "song20-submix0", "music/HL2_song20_submix0.mp3")
f(t, "song20-submix4", "music/HL2_song20_submix4.mp3")
f(t, "song23-SuitSong3", "music/HL2_song23_SuitSong3.mp3")
f(t, "song25-Teleporter", "music/HL2_song25_Teleporter.mp3")
f(t, "song26", "music/HL2_song26.mp3")
f(t, "song26-trainstation1", "music/HL2_song26_trainstation1.mp3")
f(t, "song27-trainstation2", "music/HL2_song27_trainstation2.mp3")
f(t, "song28", "music/HL2_song28.mp3")
f(t, "song29", "music/HL2_song29.mp3")
f(t, "song30", "music/HL2_song30.mp3")
f(t, "song31", "music/HL2_song31.mp3")
f(t, "song32", "music/HL2_song32.mp3")
f(t, "song33", "music/HL2_song33.mp3")
f(t, "radio1", "music/radio1.mp3")
f(t, "Ravenholm", "music/Ravenholm_1.mp3")

if IsMounted("hl2") then
	t = "[Music] Ep1 -"
	f(t, "song1", "music/VLVX_song1.mp3")
	f(t, "song2", "music/VLVX_song2.mp3")
	f(t, "song4", "music/VLVX_song4.mp3")
	f(t, "song8", "music/VLVX_song8.mp3")
	f(t, "song11", "music/VLVX_song11.mp3")
	f(t, "song12", "music/VLVX_song12.mp3")
	f(t, "song18", "music/VLVX_song18.mp3")
	f(t, "song19a", "music/VLVX_song19a.mp3")
	f(t, "song19b", "music/VLVX_song19b.mp3")
	f(t, "song21", "music/VLVX_song21.mp3")
	f(t, "Combine Battle", "ep_song8")
	f(t, "Elevator Showdown", "ep_song9")
	f(t, "Hospital Part 2", "ep_song10")

	t = "[Music] Ep2 -"
	f(t, "song0", "music/VLVX_song0.mp3")
	f(t, "song3", "music/VLVX_song3.mp3")
	f(t, "song9", "music/VLVX_song9.mp3")
	f(t, "song15", "music/VLVX_song15.mp3")
	f(t, "song20", "music/VLVX_song20.mp3")
	f(t, "song22", "music/VLVX_song22.mp3")
	f(t, "song23", "music/VLVX_song23.mp3")
	f(t, "song23ambient", "music/VLVX_song23ambient.mp3")
	f(t, "song24", "music/VLVX_song24.mp3")
	f(t, "song25", "music/VLVX_song25.mp3")
	f(t, "song26", "music/VLVX_song26.mp3")
	f(t, "song27", "music/VLVX_song27.mp3")
	f(t, "song28", "music/VLVX_song28.mp3")
end

t = "[Siren]"
f("No Sound", "common/null.wav")
f(t, "APC Alarm", "d1_trainstation.apc_alarm_loop1")
f(t, "Alarm Bell", "d1_canals.Floodgate_AlarmBellLoop")
f(t, "Beta HL2 Siren", "ambient/alarms/city_siren_loop2.wav")
f(t, "Bunker Siren", "coast.bunker_siren1")
f(t, "Combine Bank Alarm 1", "Streetwar.d3_c17_10a_siren")
f(t, "Combine Bank Alarm 2", "Streetwar.d3_c17_10b_alarm1")
f(t, "Combine Scanner Alarm", "NPC_CScanner.DiveBomb")
f(t, "Distant Citadel Siren", "Trainyard.distantsiren")
f(t, "Helicopter Crash Alarm", "NPC_AttackHelicopter.CrashingAlarm1")
f(t, "Helicopter Damaged Alarm", "NPC_AttackHelicopter.BadlyDamagedAlert")
f(t, "Helicopter Megabomb Alert", "NPC_AttackHelicopter.MegabombAlert")
f(t, "Turret Alert", "NPC_FloorTurret.Alert")
f(t, "Teleport Alarm", "k_lab.teleport_alarm")

t = "[Music]"
f(t, "Suit Song 3", "song23")
f(t, "Song 25 Remix", "song_credits_2")
f(t, "GMan Radio", "d1_trainstation.RadioMusic")

t = "[SFX - Misc]"
f(t, "Zombie Breathe", "NPC_PoisonZombie.Moan1")
f(t, "Idle Zombies", "Zombie.Idle")
f(t, "Helicopter Rotor", "NPC_CombineGunship.RotorSound")
f(t, "Heartbeat", "k_lab.teleport_heartbeat")
f(t, "Breathing", "k_lab.teleport_breathing")
f(t, "Playground Memory", "d1_trainstation.playground_memory")
f(t, "Crying", "d1_trainstation.cryingloop")

t = "[SFX - Vehicle]"
f(t, "ATV Engine Start", "ATV_engine_start")
f(t, "ATV Engine Idle", "ATV_engine_idle")
f(t, "ATV Engine Gear 1", "ATV_firstgear")
f(t, "ATV Engine Gear 2", "ATV_secondgear")
f(t, "ATV Engine Gear 3", "ATV_thirdgear")
f(t, "ATV Engine Gear 4", "ATV_fourthgear")
f(t, "ATV Engine Stop", "ATV_engine_stop")
f(t, "ATV Engine Reverse", "ATV_reverse")
f(t, "ATV Engine Turbo", "ATV_turbo_on")
f(t, "Crane Engine Start", "Crane_engine_start")
f(t, "Crane Engine Idle", "Crane_engine_idle")
f(t, "Crane First Gear", "Crane_firstgear")
f(t, "Crane Magnet Creak", "Crane_magnet_creak")
f(t, "Airboat Engine Start", "Airboat_engine_start")
f(t, "Airboat Engine Idle", "Airboat_engine_idle")
f(t, "Airboat Engine Full Throttle", "Airboat_engine_fullthrottle")
f(t, "Airboat Fan Idle", "Airboat_fan_idle")
f(t, "Airboat Fan Full Throttle", "Airboat_fan_fullthrottle")
f(t, "Airboat Engine Stop", "Airboat_engine_stop")
f(t, "APC Engine Start", "apc_engine_start")
f(t, "APC Engine Idle", "apc_engine_idle")
f(t, "APC Engine Gear 1", "apc_firstgear")
f(t, "APC Engine Stop", "apc_engine_stop")
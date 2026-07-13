MVSoundEmitter = {}

function MVSoundEmitter.CalculateSoundDuration( soundName, pitch )

	return pitch > 0 and SoundDuration( soundName ) * 100 / pitch or 0

end


function MVSoundEmitter.IsSoundEmitter( ent )
	return isentity( ent ) and ent:IsValid() and ent:GetClass() == "mv_soundemitter"
end
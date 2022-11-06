function onBeatHit()
    if curBeat == 192 then
	    for i=0,4 do
		    setPropertyFromGroup('playerStrums', i, 'texture', 'PIXELNOTE_assets');
		end
	    for i=0,4 do
		    setPropertyFromGroup('opponentStrums', i, 'texture', 'PIXELNOTE_assets');
		end
	    for i = 0, getProperty('unspawnNotes.length')-1 do
		    setPropertyFromGroup('unspawnNotes', i, 'texture', 'PIXELNOTE_assets');
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashTexture', 'PIXELnoteSplashes');
        end
	end
end
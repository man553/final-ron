function setDefault(id)
    _G['defaultStrum'..id..'X'] = getActorX(id)
end
function update (elapsed)
    local currentBeat = (songPos / 1000)*(bpm/60)

    for i=0,7 do
        setActorX(_G['defaultStrum'..i..'X'] + 8 * math.sin((currentBeat + i*0.25) * math.pi), i)
        setActorY(defaultStrum0Y + 18 * math.cos((currentBeat + i*2.5) * math.pi), i)
    end
end
-- r
function stepHit(step)
    if curStep == 768 then
		for i=0,3 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 675,getActorAngle(i), bpm, 'setDefault')
		end
		for i =4,7 do 
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 275,getActorAngle(i), bpm, 'setDefault')
		end
    end
end
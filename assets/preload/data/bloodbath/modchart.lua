local windowmove = false
local cameramove = false

function setDefault(id)
    _G['defaultStrum'..id..'X'] = getActorX(id)
end

function start (song)

end

function update(elapsed)
    local currentBeat = (songPos / 1000)*(bpm/60)
    if windowmove then
        setWindowPos(24 * math.sin(currentBeat * math.pi) + 327, 24 * math.sin(currentBeat * 3) + 160)
    end
    if cameramove then
        camHudAngle = 10 * math.sin((currentBeat/6) * math.pi)
        cameraAngle = 2 * math.sin((currentBeat/6) * math.pi)
    end

end

function stepHit(step)
    if curStep == 258 then
        windowmove = true
		for i=0,3 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 1250,getActorAngle(i)+359, 1, 'setDefault')
		end
		for i =4,7 do 
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 275,getActorAngle(i), 1, 'setDefault')
		end
        cameramove = true
    end
    if (curStep == 518) then
        windowmove = false
        cameramove = false
    end
    if curStep == 768 then
        windowmove = true
        cameramove = true
    end  
end
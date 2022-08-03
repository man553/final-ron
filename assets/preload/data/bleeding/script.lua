local windowmove = false
local cameramove = false
local WHATTHEFUCK = false
local WTFending = false
local intensecameramove = false

function update(elapsed)
    local currentBeat = (songPos / 1000)*(bpm/60)
    if windowmove then
        setWindowPos(24 * math.sin(currentBeat * math.pi) + 327, 24 * math.sin(currentBeat * 3) + 160)
    end
    if cameramove then
        camHudAngle = 22 * math.sin((currentBeat/4) * math.pi)
        cameraAngle = 4 * math.sin((currentBeat/4) * math.pi)
    end
    if intensecameramove then
        camHudAngle = 45 * math.sin((currentBeat/2) * math.pi)
        cameraAngle = 9 * math.sin((currentBeat/2) * math.pi)
    end
    if WHATTHEFUCK then
        camHudAngle = 90 * math.sin((currentBeat/2) * math.pi)
        cameraAngle = 18 * math.sin((currentBeat/2) * math.pi)
    end
    if WTFending then
        camHudAngle = 360 * math.sin((currentBeat/8) * math.pi)
        cameraAngle = 27 * math.sin((currentBeat/2) * math.pi)
    end
end

function stepHit(step)
    if curStep == 256 then
        windowmove = true
        cameramove = true
    end
    if curStep == 512 then
        windowmove = false
        cameramove = false
    end
    if curStep == 768 then
		for i=0,3 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 1250,getActorAngle(i)+359, 1, 'setDefault')
		end
		for i =4,7 do 
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 275,getActorAngle(i), 1, 'setDefault')
		end
        windowmove = true
        cameramove = false
		intensecameramove = true
    end  
	if curStep == 896 then
		intensecameramove = false
		WHATTHEFUCK = true
	end
	if curStep == 1024 then
		WHATTHEFUCK = false
		WTFending = true
	end
	if curStep == 1040 then
		WTFending = false
	end
	if curStep == 1296 then
		windowmove = false
		cameramove = false
		intensecameramove = false
	end
end
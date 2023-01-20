function setDefault(id)
    _G['defaultStrum'..id..'X'] = getActorX(id)
end

function start (song)
    for i=0,3 do
        tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 1250,getActorAngle(i), 0.5, 'setDefault')
    end
    for i =4,7 do 
        tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 275,getActorAngle(i), 0.5, 'setDefault')
    end
end
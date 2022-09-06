function start(song)

end

function stepHit(step)
    if curStep >= 27 and curStep < 32 then
        setCamZoom(1.5)
        tweenCamZoom(2,0.2)
    end
    if curStep >= 75 and curStep < 80 then
        setCamZoom(0.5)
        tweenCamZoom(2,0.2)
    end
    if curStep == 475 then
        setCamZoom(2)
        tweenCamZoom(2,0.2)
        setHudPosition(50000,50000)
    end
    if curStep == 480 then
        setCamZoom(1)
        tweenCamZoom(2,0.2)
        setHudPosition(0,0)
    end
    if curStep >= 861 and curStep < 864 then
        setCamZoom(0.2)
        tweenCamZoom(2,0.2)
    end
end
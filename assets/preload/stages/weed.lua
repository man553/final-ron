cx = 0;
cy = 0;

function onCreate()
    local hx = 3148 / 2;
    local hy = 1664 / 2;
    cx = -1000 + hx;
    cy = -300 + hy;

    makeLuaSprite('background', 'weed', cx, cy)
    setProperty('background.offset.x', hx);
    setProperty('background.offset.y', hy);
    addLuaSprite('background', false)
end
fr = 0
function onUpdate(elapsed)
    fr = fr + elapsed;

    setProperty('background.scale.x', (1 + math.cos(fr) / 4) * 1)
    setProperty('background.scale.y', (1 + math.cos(fr + 1) / 4) * 1)

    setProperty('rbg.scale.x', 1 + math.cos(fr*3) / 6)
    setProperty('rbg.scale.y', 1 + math.cos(fr*3 + 2) / 6)
    setProperty('rbg.angle', math.sin(fr*3) * 8);
    setProperty('rbg.x', cx + math.sin(fr*3) * 200);
    setProperty('rbg.y', cy + math.cos(fr*3) * 200);
end

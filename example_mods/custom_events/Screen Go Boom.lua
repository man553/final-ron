function onCreate()
    makeAnimatedLuaSprite("robloxboom", "robloxboom", 150, -250)
    addAnimationByPrefix("robloxboom", "boom", "boom", 20, false)
    addLuaSprite("robloxboom")
    setObjectCamera("robloxboom", "other")

    setProperty("robloxboom.visible", false)
end

function onEvent(name, duration)
    if name == "Screen Go Boom" then
        setProperty("robloxboom.visible", true)
        local fps = (12)
        objectPlayAnimation("robloxboom", "boom", true)
        setProperty("robloxboom.animation.curAnim.frameRate", fps) 
		playSound('explosion')
    end
end
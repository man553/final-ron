function onEvent(name, value1, value2)
   if name == 'imageflash' then
		makeLuaSprite('image', value1, getRandomInt(200,1000), getRandomInt(100,600));
		addLuaSprite('image', true);
		doTweenColor('hello', 'image', 'FFFFFFFF', 0.1, 'quartIn');
		setObjectCamera('image', 'other');
		runTimer('wait', value2);
		playSound('error')
    end
end 
    
function onTimerCompleted(tag, loops, loopsleft)
    if tag == 'wait' then
    doTweenAlpha('byebye', 'image', 0, 0.1, 'linear');
    end
 end
    
function onTweenCompleted(tag)
    if tag == 'byebye' then
    removeLuaSprite('image', true);
    end
end

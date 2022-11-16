function onCreate()
	-- background shit
	makeLuaSprite('sky', 'madRonV1_sky', -600, -100);
	setLuaSpriteScrollFactor('stageback', 0.9, 0.9);

	makeLuaSprite('ground', 'madRonV1_ground', -600, -100);
	setLuaSpriteScrollFactor('stagefront', 0.9, 0.9);
	scaleObject('madRon_ground', 1.1, 1.1);

	addLuaSprite('sky', false);
	addLuaSprite('ground', false);

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end
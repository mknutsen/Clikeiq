

-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

-- local gfx <const> = playdate.graphics
print("enter")
function cb()
	playdate.graphics.drawRect(100, 50, 75, 25) 
		print("callback")
end

playdate.graphics.drawRect(0, 0, 10, 10) 
local channel = playdate.sound.channel.new()
local synth = playdate.sound.synth.new()
local delay = playdate.sound.bitcrusher.new()
delay:setMix(60)
delay:setAmount(.5)
delay:setUndersampling(0.5)
synth:setWaveform(playdate.sound.kWaveSine)
synth:setFinishCallback(cb)
channel:addSource(synth)
channel:addEffect(delay)
synth:playMIDINote(50, 1, 1)
-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()

	-- Poll the d-pad and move our player accordingly.
	-- (There are multiple ways to read the d-pad; this is the simplest.)
	-- Note that it is possible for more than one of these directions
	-- to be pressed at once, if the user is pressing diagonally.

	if playdate.buttonIsPressed( playdate.kButtonUp ) then
		synth:playMIDINote(80, 1, 0.1)
	end
	if playdate.buttonIsPressed( playdate.kButtonRight ) then
		synth:playMIDINote(60, 1, 0.1)
	end
	if playdate.buttonIsPressed( playdate.kButtonLeft ) then
		synth:playMIDINote(70, 1, 0.1)
	end
	if playdate.buttonIsPressed( playdate.kButtonDown ) then
		synth:playMIDINote(50, 1, 0.1)
	end
	-- if playdate.buttonIsPressed( playdate.kButtonRight ) then
	-- 	playerSprite:moveBy( 2, 0 )
	-- end
	-- if playdate.buttonIsPressed( playdate.kButtonDown ) then
	-- 	playerSprite:moveBy( 0, 2 )
	-- end
	-- if playdate.buttonIsPressed( playdate.kButtonLeft ) then
	-- 	playerSprite:moveBy( -2, 0 )
	-- end

	-- Call the functions below in playdate.update() to draw sprites and keep
	-- timers updated. (We aren't using timers in this example, but in most
	-- average-complexity games, you will.)

	-- gfx.sprite.update()
	playdate.timer.updateTimers()

end


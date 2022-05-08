

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
local channel = playdate.sound.channel.new()

local synthNoise = playdate.sound.synth.new()
synthNoise:setWaveform(playdate.sound.kWaveNoise)
channel:addSource(synthNoise)
local synthSin = playdate.sound.synth.new()
synthSin:setWaveform(playdate.sound.kWaveSine)
channel:addSource(synthSin)
local synthSaw = playdate.sound.synth.new()
synthSaw:setWaveform(playdate.sound.kWaveSawtooth)
channel:addSource(synthSaw)
local synthTriangle = playdate.sound.synth.new()
synthTriangle:setWaveform(playdate.sound.kWaveTriangle)
channel:addSource(synthTriangle)

local mixHalf = 0.5
local crush = playdate.sound.bitcrusher.new()
crush:setMix(mixHalf)
crush:setAmount(mixHalf)
crush:setUndersampling(mixHalf)

local delayLenSec = 5
local levelHalf = 0.5 -- theoretically level is 0-100 cant find confirmation tho
local delayLine = playdate.sound.delayline.new(.5)
delayLine:setMix(0.7)
delayLine:setFeedback(0.1)
delayLine:addTap(0.3)
delayLine:addTap(0.2)
delayLine:addTap(0.1)
-- delay taps

local overdrive =playdate.sound.overdrive.new()
overdrive:setMix(mixHalf)
overdrive:setGain(levelHalf)
overdrive:setLimit(levelHalf)

local filter = playdate.sound.twopolefilter.new(playdate.sound.kFilterBandPass)
filter:setMix(mixHalf)
filter:setFrequency(200)
filter:setResonance(mixHalf)
-- filter:setGain()
-- filter:setType()

local ringmod = playdate.sound.ringmod.new()
ringmod:setMix(mixHalf)
ringmod:setFrequency(200)


-- channel:addEffect(crush)
channel:addEffect(delayLine)
-- channel:addEffect(overdrive)
-- channel:addEffect(filter)
-- channel:addEffect(ringmod)

local baseNoteSin = 50 -- near middle c
local baseNoteTriangle = 50 -- near middle c
local baseNoteSaw = 50 -- near middle c
local baseNoteNoise = 50 -- near middle c

local spread = 12 -- one octave
-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function draw()
	local x = math.random(400)
	local y = math.random(200)
	local w = math.random(300)
	local h = math.random(100)
	playdate.graphics.drawRect(x, y, w, h) 
end


local noiseButton = playdate.kButtonUp
local sawButton = playdate.kButtonLeft
local sinButton = playdate.kButtonRight
local triangleButton = playdate.kButtonDown

local octaveUp = playdate.kButtonA
local octaveDown = playdate.kButtonB

function playdate.update()

	-- Poll the d-pad and move our player accordingly.
	-- (There are multiple ways to read the d-pad; this is the simplest.)
	-- Note that it is possible for more than one of these directions
	-- to be pressed at once, if the user is pressing diagonally.

	local crank = playdate.getCrankPosition()
	local crankModify =  (spread * (crank / 360))
	local buttonPressed = false
	
	-- saw octave up and down
	if (playdate.buttonIsPressed(octaveUp) and playdate.buttonJustPressed(sawButton)) then
		baseNoteSaw += 12
	end
	
	if (playdate.buttonIsPressed(octaveDown) and playdate.buttonJustPressed(sawButton)) then
		baseNoteSaw -= 12
	end
	
	if (playdate.buttonJustPressed(sawButton) and not (playdate.buttonIsPressed(octaveUp) or playdate.buttonIsPressed(octaveDown))) then
		note = baseNoteSaw + crankModify 
		synthSaw:playMIDINote(note, 1, 0.1)
		draw()
	end
	
	-- triangle octave up and down
	if (playdate.buttonJustPressed(octaveUp) and playdate.buttonJustPressed(triangleButton)) then
		baseNoteTriangle += 12
	end
	
	if (playdate.buttonJustPressed(octaveDown) and playdate.buttonJustPressed(triangleButton)) then
		baseNoteTriangle -= 12
	end
	
	if (playdate.buttonJustPressed(triangleButton) and not (playdate.buttonIsPressed(octaveUp) or playdate.buttonIsPressed(octaveDown))) then
		note = baseNoteTriangle + crankModify 
		synthTriangle:playMIDINote(note, 1, 0.1)
		draw()
	end
	
	-- noise octave up and down
	if (playdate.buttonIsPressed(octaveUp) and playdate.buttonJustPressed(noiseButton)) then
		baseNoteNoise += 12
	end
	
	if (playdate.buttonIsPressed(octaveDown) and playdate.buttonJustPressed(noiseButton)) then
		baseNoteNoise -= 12
	end
	
	if (playdate.buttonJustPressed(noiseButton) and not (playdate.buttonIsPressed(octaveUp) or playdate.buttonIsPressed(octaveDown))) then
		note = baseNoteNoise + crankModify 
		synthNoise:playMIDINote(note, 1, 0.1)
		draw()
	end

	-- sin octave up and down
	if (playdate.buttonIsPressed(octaveUp) and playdate.buttonJustPressed(sinButton)) then
		baseNoteSin += 12
	end
	
	if (playdate.buttonIsPressed(octaveDown) and playdate.buttonJustPressed(sinButton)) then
		baseNoteSin -= 12
	end
	
	if (playdate.buttonJustPressed(sinButton) and not (playdate.buttonIsPressed(octaveUp) or playdate.buttonIsPressed(octaveDown))) then
		note = baseNoteSin + crankModify 
		synthSin:playMIDINote(note, 1, 0.1)
		draw()
	end


	playdate.timer.updateTimers()

end


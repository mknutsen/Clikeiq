

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

local crush = playdate.sound.bitcrusher.new()
crush:setMix(60)
crush:setAmount(.5)
crush:setUndersampling(0.5)
channel:addEffect(crush)

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

function playdate.update()

	-- Poll the d-pad and move our player accordingly.
	-- (There are multiple ways to read the d-pad; this is the simplest.)
	-- Note that it is possible for more than one of these directions
	-- to be pressed at once, if the user is pressing diagonally.

	local crank = playdate.getCrankPosition()
	local crankModify =  (spread * (crank / 360))
	local buttonPressed = false
	if playdate.buttonIsPressed( playdate.kButtonUp ) then
		if playdate.buttonIsPressed(playdate.kButtonA) then
			baseNoteNoise += 1
		elseif playdate.buttonIsPressed(playdate.kButtonB) then
			baseNoteNoise -= 1
		else
			note = baseNoteNoise + crankModify 
			synthNoise:playMIDINote(note, 1, 0.1)
			draw()
		end
	end
	if playdate.buttonIsPressed( playdate.kButtonRight ) then
		if playdate.buttonIsPressed(playdate.kButtonA) then
			baseNoteSin += 1
		elseif playdate.buttonIsPressed(playdate.kButtonB) then
			baseNoteSin -= 1
		else
			note = baseNoteSin + crankModify 
			synthSin:playMIDINote(note, 1, 0.1)
			draw()
		end
	end
	if playdate.buttonIsPressed( playdate.kButtonLeft ) then
		if playdate.buttonIsPressed(playdate.kButtonA) then
			baseNoteSaw += 1
		elseif playdate.buttonIsPressed(playdate.kButtonB) then
			baseNoteSaw -= 1
		else
			note = baseNoteSaw + crankModify 
			synthSaw:playMIDINote(note, 1, 0.1)
			draw()
		end
	end
	if playdate.buttonIsPressed( playdate.kButtonDown ) then
		if playdate.buttonIsPressed(playdate.kButtonA) then
			baseNoteTriangle += 1
		elseif playdate.buttonIsPressed(playdate.kButtonB) then
			baseNoteTriangle -= 1
		else
			note = baseNoteTriangle + crankModify 
			synthTriangle:playMIDINote(note, 1, 0.1)
			draw()
		end
	end


	playdate.timer.updateTimers()

end




-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import "CoreLibs/timer"
import "CoreLibs/nineslice"


spread = 12 -- one octave
baseNoteSin = 60 -- near middle c

sequence = playdate.sound.sequence.new()
trackTable = {}
--[[ NOT INTUITIVE
instruments supercede synths even though theyre both sources.
If i make an synth, add it to a channel, and then add the synth to an instrument
the channel has no control over the instrument which has its own volume control.
]]--

-- order is imoportant because the order they index in
-- getTrack is the order they appear in the section names

function makeTrack(waveform)
	local synth = playdate.sound.synth.new()
	synth:setWaveform(waveform)
	local track = playdate.sound.track.new()
	local instrument = playdate.sound.instrument.new()
	instrument:addVoice(synth)
	track:setInstrument(instrument)
	sequence:addTrack(track)
	local channel = playdate.sound.channel.new()
	channel:addSource(instrument)
end



synthSaw = playdate.sound.synth.new()
synthSaw:setWaveform(playdate.sound.kWaveSaw)
trackSaw = playdate.sound.track.new()
instrumentSaw = playdate.sound.instrument.new()
instrumentSaw:addVoice(synthSaw)
trackSaw:setInstrument(instrumentSaw)
sequence:addTrack(trackSaw)
channelSaw = playdate.sound.channel.new()
channelSaw:addSource(instrumentSaw)

synthTriangle = playdate.sound.synth.new()
synthTriangle:setWaveform(playdate.sound.kWaveTriangle)
trackTriangle = playdate.sound.track.new()
instrumentTriangle = playdate.sound.instrument.new()
instrumentTriangle:addVoice(synthTriangle)
trackTriangle:setInstrument(instrumentTriangle)
sequence:addTrack(trackTriangle)
channelTriangle = playdate.sound.channel.new()
channelTriangle:addSource(instrumentTriangle)

synthNoise = playdate.sound.synth.new()
synthNoise:setWaveform(playdate.sound.kWaveNoise)
trackNoise = playdate.sound.track.new()
instrumentNoise = playdate.sound.instrument.new()
instrumentNoise:addVoice(synthNoise)
trackNoise:setInstrument(instrumentNoise)
sequence:addTrack(trackNoise)
channelNoise = playdate.sound.channel.new()
channelNoise:addSource(instrumentNoise)



-- channel = playdate.sound.channel.new()
-- channel:addEffect(delayLine)
-- channel:addSource(synthSin)

delayLenSec = 5
levelHalf = 0.5 -- theoretically level is 0-100 cant find confirmation tho
delayLine = playdate.sound.delayline.new(.3)
delayLine:setMix(0.5)
delayLine:setFeedback(0.1)
-- delayLine:addTap(0.3)
delayLine:addTap(0.2)
delayLine:addTap(0.1)
-- channelNoise:addEffect(delayLine)playdate.sound.addEffect(delayLine)
-- instrumentNoise:addEffect(delayLine)/


filter = playdate.sound.twopolefilter.new(playdate.sound.kFilterLowPass)
filter:setMix(.8)
filter:setFrequency(600)
filter:setResonance(0.5)
playdate.sound.addEffect(filter)

sequence:setTempo(2)
sequence:setLoops(1, 8)
sequence:play()

function dump(o)
   if type(o) == 'table' then
	  local s = '{ '
	  for k,v in pairs(o) do
		 if type(k) ~= 'number' then k = '"'..k..'"' end
		 s = s .. '['..k..'] = ' .. dump(v) .. ','
	  end
	  return s .. '} '
   else
	  return tostring(o)
   end
end

settingsRowNameTable = {}
settingsRowNameTable[1] = "-"
settingsRowNameTable[2] = "+"
settingsRowNameTable[3] = "DEL"
settingsRowNameTable[4] = "OD"
settingsRowNameTable[5] = "1F"
settingsRowNameTable[6] = "2F"
settingsRowNameTable[7] = "BC"
settingsRowNameTable[8] = "RING"

sectionNameTable = {}
sectionNameTable[1] = "Sin"
sectionNameTable[2] = "Saw"
sectionNameTable[3] = "Triangle"
sectionNameTable[4] = "Noise"

baseNoteTable = {}
baseNoteTable[1] = 50
baseNoteTable[2] = 50
baseNoteTable[3] = 50
baseNoteTable[4] = 50

function settingsButton(section, column)
	local track = getTrack(section)
	if column == 1 then -- octave down
		baseNoteTable[section] -= 12
	elseif column == 2 then -- octave up
		baseNoteTable[section] += 12
	elseif column == 3 then -- add delay
	elseif column == 4 then -- add overdrive
	elseif column == 5 then -- add unipolar filter
	elseif column == 6 then -- add bipolar filter
	elseif column == 7 then -- add bitcrush
	elseif column == 8 then -- add ring mod
		
	end
	
end

gridview = playdate.ui.gridview.new(44, 44)
gridview:setNumberOfColumns(8)
gridview:setNumberOfRows(2,2,2,2)
gridview:setSectionHeaderHeight(24)
gridview:setContentInset(1, 4, 1, 4)
gridview:setCellPadding(4, 4, 4, 4)
gridview.changeRowOnColumnWrap = false
gridview:setScrollPosition(2,2)

function stepActive(track, step)
	local notes = track:getNotes(step)
	return not (next(notes) == nil)
end

function getSectionName(sectionNumber)
	return sectionNameTable[sectionNumber]
end

function getTrack(sectionNumber)
	return sequence:getTrackAtIndex(sectionNumber)
end

function stepRemove(track, step)
	--[[ {
		[1] = { ["velocity"] = 1.0,["length"] = 1,["step"] = 1,["note"] = 50.0,} ,
		[2] = { ["velocity"] = 1.0,["length"] = 1,["step"] = 4,["note"] = 50.0,} ,} 
	--]]
	local notes = track:getNotes()
	for key,value in pairs(notes) do
		if (value["step"] == step) then
			table.remove(notes, key)
		end
	end
	-- print(dump(notes))
	track:setNotes(notes)	
end


function gridview:drawCell(section, row, column, selected, x, y, width, height)
	local isStepActive = false
	if row == 2 then
		local track = getTrack(section)
		isStepActive = stepActive(track, column)
	end
	
	local xMod = 4
	local widthMod = -8
	local z = 0
	
	if selected then
		xMod = -2
		widthMod = 4
		z = 3
	end
	if isStepActive then
		playdate.graphics.fillCircleInRect(x + xMod, y + xMod, width + widthMod, height + widthMod, z)
	else
		playdate.graphics.drawCircleInRect(x + xMod, y + xMod, width + widthMod, height + widthMod, z)
	end
	local cellText = ""..row.."-"..column
	if row == 1 then
		cellText = settingsRowNameTable[column]
	end
	playdate.graphics.drawTextInRect(cellText, x, y+14, width, 20, nil, nil, kTextAlignment.center)
end

function gridview:drawSectionHeader(section, x, y, width, height)
	playdate.graphics.drawText(getSectionName(section) .. "*", x + 10, y + 8)
end



function playdate.update()
	if gridview.needsDisplay == true then
		playdate.graphics.clear()
		gridview:drawInRect(0, 0, 400, 240)
	end
	
	if playdate.buttonJustPressed(playdate.kButtonUp) then
		gridview:selectPreviousRow(false)
	end
	
	if playdate.buttonJustPressed(playdate.kButtonDown) then
		gridview:selectNextRow(false)
	end
	
	if playdate.buttonJustPressed(playdate.kButtonLeft) then
		gridview:selectPreviousColumn(false)
	end
	
	if playdate.buttonJustPressed(playdate.kButtonRight) then
		gridview:selectNextColumn(false)
	end
	
	if playdate.buttonJustPressed(playdate.kButtonA) then
		local section, row, column = gridview:getSelection()
		if row == 1 then
			settingsButton(section, column)
		elseif row == 2 then
			local track = getTrack(section)
			local isStepActive = stepActive(track, column)
			if isStepActive then
				stepRemove(track, column)
			else
				local crank = playdate.getCrankPosition()
				local crankModify =  (spread * (crank / 360))
				local baseNote = baseNoteTable[section]
				track:addNote(column, baseNote + crankModify, 1)
			end
		end
	end
	-- listview:drawInRect(220, 20, 160, 210)
	playdate.timer:updateTimers()
end


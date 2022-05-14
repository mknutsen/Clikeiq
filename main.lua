

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

needsRedrawBool = false
gridview = playdate.ui.gridview.new(44, 44)
gridview:setNumberOfColumns(16)
gridview:setNumberOfRows(2,2,2,2)
gridview:setSectionHeaderHeight(24)
gridview:setContentInset(1, 4, 1, 4)
gridview:setCellPadding(4, 4, 4, 4)
gridview.changeRowOnColumnWrap = false
gridview:setScrollPosition(2,2)

sequence = playdate.sound.sequence.new()

settingsRowNameTable = {}
settingsRowNameTable[1] = "SEQ"
settingsRowNameTable[2] = "OCT"
settingsRowNameTable[3] = "DEL"
settingsRowNameTable[4] = "OD"
settingsRowNameTable[5] = "1F"
settingsRowNameTable[6] = "2F"
settingsRowNameTable[7] = "BC"
settingsRowNameTable[8] = "RING"
settingsRowNameTable[9] = "BPM" -- will be global

-- this is the order of keys that will generally be used
-- note lua generally doesn't zero index this isn't my fault

SYNTH_STR = "SYNTH"
TRACK_STR = "TRACK"
INSTRUMENT_STR = "INSTRUMENT"
CHANNEL_STR = "CHANNEL"
DELAY_STR = "DEL"
OVERDRIVE_STR = "OD"
UNIPOLE_FILTER_STR = "1F"
BIPOLAR_FILTER_STR = "2F"
BITCRUSH_STR = "BC"
RINGMOD_STR = "RING"
STATE_STR = "STATE"
NOTE_STR = "NOTE"
NAME_STR = "NAME"

spread = 12 -- one octave
baseNoteSin = 60 -- near middle c


trackTable = {}
--[[ NOT INTUITIVE
instruments supercede synths even though theyre both sources.
If i make an synth, add it to a channel, and then add the synth to an instrument
the channel has no control over the instrument which has its own volume control.
]]--

-- order is imoportant because the order they index in
-- getTrack is the order they appear in the section names

function makeTrack(number)
	
	-- set screen state to sequencer
	-- indexing in settingsRowNameTable
	trackTable[number][STATE_STR] = 1
	-- set note to middle c
	trackTable[number][NOTE_STR] = 60
	
	trackTable[number][TRACK_STR] = playdate.sound.track.new()
	trackTable[number][INSTRUMENT_STR] = playdate.sound.instrument.new()
	trackTable[number][INSTRUMENT_STR]:addVoice(trackTable[number][SYNTH_STR])
	trackTable[number][TRACK_STR]:setInstrument(trackTable[number][INSTRUMENT_STR])
	trackTable[number][CHANNEL_STR] = playdate.sound.channel.new()
	trackTable[number][CHANNEL_STR]:addSource(trackTable[number][INSTRUMENT_STR])
	
	trackTable[number][BITCRUSH_STR] = playdate.sound.bitcrusher.new()
	trackTable[number][BITCRUSH_STR]:setMix(0)
	trackTable[number][BITCRUSH_STR]:setAmount(0.5)
	trackTable[number][BITCRUSH_STR]:setUndersampling(0.5)
	trackTable[number][CHANNEL_STR]:addEffect(trackTable[number][BITCRUSH_STR])
	
	trackTable[number][DELAY_STR] = playdate.sound.delayline.new(.5)
	trackTable[number][DELAY_STR]:setMix(0)
	trackTable[number][DELAY_STR]:setFeedback(0.1)
	trackTable[number][DELAY_STR]:addTap(0.3)
	trackTable[number][DELAY_STR]:addTap(0.2)
	trackTable[number][DELAY_STR]:addTap(0.1)
	trackTable[number][CHANNEL_STR]:addEffect(trackTable[number][DELAY_STR])
	
	trackTable[number][OVERDRIVE_STR] = playdate.sound.overdrive.new()
	trackTable[number][OVERDRIVE_STR]:setMix(0)
	trackTable[number][OVERDRIVE_STR]:setGain(0.5)
	trackTable[number][OVERDRIVE_STR]:setLimit(0.5)
	trackTable[number][CHANNEL_STR]:addEffect(trackTable[number][OVERDRIVE_STR])
	
	trackTable[number][BIPOLAR_FILTER_STR] = playdate.sound.twopolefilter.new(playdate.sound.kFilterBandPass)
	trackTable[number][BIPOLAR_FILTER_STR]:setMix(0)
	trackTable[number][BIPOLAR_FILTER_STR]:setFrequency(200)
	trackTable[number][BIPOLAR_FILTER_STR]:setResonance(0.5)
	trackTable[number][CHANNEL_STR]:addEffect(trackTable[number][BIPOLAR_FILTER_STR])
	
	trackTable[number][RINGMOD_STR] = playdate.sound.ringmod.new()
	trackTable[number][RINGMOD_STR]:setMix(0)
	trackTable[number][RINGMOD_STR]:setFrequency(200)
	trackTable[number][CHANNEL_STR]:addEffect(trackTable[number][RINGMOD_STR])
	
	sequence:addTrack(trackTable[number][TRACK_STR])
end

function getCrankModify()
	local crank = playdate.getCrankPosition()
	return  (spread * (crank / 360))
end

function main()
	sequence:setTempo(2)
	sequence:setLoops(1, 16)
	
	trackTable[1] = {}
	trackTable[2] = {}
	trackTable[3] = {}
	trackTable[4] = {}
	
	-- Give them all names
	trackTable[1][NAME_STR] = "Sin"
	trackTable[2][NAME_STR] = "Saw"
	trackTable[3][NAME_STR] = "Triangle"
	trackTable[4][NAME_STR] = "Noise"
	
	-- give them all their wave form
	trackTable[1][SYNTH_STR] = playdate.sound.synth.new(playdate.sound.kWaveSine)
	trackTable[2][SYNTH_STR] = playdate.sound.synth.new(playdate.sound.kWaveSawtooth)
	trackTable[3][SYNTH_STR] = playdate.sound.synth.new(playdate.sound.kWaveTriangle)
	trackTable[4][SYNTH_STR] = playdate.sound.synth.new(playdate.sound.kWaveNoise)

	-- set all the other values to the default
	makeTrack(1)
	makeTrack(2)
	makeTrack(3)
	makeTrack(4)
	
	
	myInputHandlers = {
		-- ab are inputs
		AButtonUp = function()
			local section, row, column = gridview:getSelection()
			if row == 1 then
				settingsButton(section, column)
			elseif row == 2 then
				local track = getTrack(section)
				local isStepActive = stepActive(track, column)
				if isStepActive then
					stepRemove(track, column)
				else
					local noteToPlay = trackTable[section][NOTE_STR] + getCrankModify()
					track:addNote(column, noteToPlay , 1)
				end
			end
			needsRedrawBool= true
		end,
		
		BButtonUp = function()
			
		end,
		--  directional buttons are for navigation
		downButtonUp = function()
			gridview:selectNextRow(false)
		end,
		
		leftButtonUp = function()
			gridview:selectPreviousColumn(false)
		end,
		
		rightButtonUp = function()
			gridview:selectNextColumn(false)
		end,
		
		upButtonUp = function()
			gridview:selectPreviousRow(false)
		end,
	}
	
	-- add input handlers to global state
	playdate.inputHandlers.push(myInputHandlers)
	-- run the sequence
	sequence:play()
end


function settingsButton(section, column)
	trackTable[section][STATE_STR] = column
	needsRedrawBool = true
end

function stepActive(track, step)
	local notes = track:getNotes(step)
	return not (next(notes) == nil)
end

function getSectionName(sectionNumber)
	return trackTable[sectionNumber][NAME_STR]
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
		playdate.graphics.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
		playdate.graphics.fillCircleInRect(x + xMod, y + xMod, width + widthMod, height + widthMod, z)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
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

function needsRedraw()
	needsRedrawOld = needsRedrawBool
	needsRedrawBool = false
	return needsRedrawBool
end

function playdate.update()
	if gridview.needsDisplay == true or needsRedraw() then
		playdate.graphics.clear()
		gridview:drawInRect(0, 0, 400, 240)
	end
	playdate.timer:updateTimers()
end

main()




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

bitCrusherRowNameTable = {}
bitCrusherRowNameTable[1] = "setMix"
bitCrusherRowNameTable[2] = "setAmount"
bitCrusherRowNameTable[3] = "setUndersampling"

overdriveRowNameTable = {}
overdriveRowNameTable[1] = "Mix"
overdriveRowNameTable[2] = "Gain"
overdriveRowNameTable[3] = "Limit"
overdriveRowNameTable[4] = "Offset"

unipolarFilterRowNameTable = {}
unipolarFilterRowNameTable[1] = "Mix"
unipolarFilterRowNameTable[2] = "Freq"

bipolarFilterRowNameTable = {}
bipolarFilterRowNameTable[1] = "Type"
bipolarFilterRowNameTable[2] = "Mix"
bipolarFilterRowNameTable[3] = "Frequency"
bipolarFilterRowNameTable[4] = "Resonance"
bipolarFilterRowNameTable[5] = "Gain"

ringModulatorRowNameTable = {}
ringModulatorRowNameTable[1] = "Mix"
ringModulatorRowNameTable[2] = "Frequency"

delayRowNameTable = {}
delayRowNameTable[1] = "Mix"
delayRowNameTable[2] = "Tap"
delayRowNameTable[3] = "Feedback"

octaveRowNameTable = {}
octaveRowNameTable[1] = "-"
octaveRowNameTable[2] = "+"

filterTypes = {}
filterTypes[1] = playdate.sound.kFilterLowPass
filterTypes[2] = playdate.sound.kFilterHighPass
filterTypes[3] = playdate.sound.kFilterBandPass
filterTypes[4] = playdate.sound.kFilterNotch
filterTypes[5] = playdate.sound.kFilterPEQ
filterTypes[6] = playdate.sound.kFilterLowShelf
filterTypes[7] = playdate.sound.kFilterHighShelf

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
EFFECTS_SETTINGS_STR = "FX"

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
	
	trackTable[number][EFFECTS_SETTINGS_STR] = {}
	trackTable[number][EFFECTS_SETTINGS_STR][1] = {  } -- SEQ
	trackTable[number][EFFECTS_SETTINGS_STR][2] = { 0 } -- OCT
	trackTable[number][EFFECTS_SETTINGS_STR][3] = { 0,0,0 } -- DEL
	trackTable[number][EFFECTS_SETTINGS_STR][4] = { 0,0,0 } -- OD
	trackTable[number][EFFECTS_SETTINGS_STR][5] = { 0,0,0,0 } -- 1F
	trackTable[number][EFFECTS_SETTINGS_STR][6] = { 0,0 } -- 2F
	trackTable[number][EFFECTS_SETTINGS_STR][7] = { 0,0,0,0,0 } -- BC
	trackTable[number][EFFECTS_SETTINGS_STR][8] = { 0,0 } -- RING
	trackTable[number][EFFECTS_SETTINGS_STR][9] = { 0,0,0 } -- BPM
	
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

function getCrankPos()
	local crank = playdate.getCrankPosition()
	return (crank / 360)
end

function getCrankModify()
	return getCrankPos() * spread
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
				rowTwoButton(section, column)
			end
			print("UPDATING")
			needsRedrawBool= true
			playdate.update()
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
		
		cranked = function (change, acceleratedChange)
			print("grapnks")
			local section, row, column = gridview:getSelection()
			local crank = getCrankPos()
			if row == 2 then
				local state = trackTable[section][STATE_STR]
				trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
				needsRedrawBool= true
				playdate.update()
			end
			
		end
	}
	
	-- add input handlers to global state
	playdate.inputHandlers.push(myInputHandlers)
	-- run the sequence
	sequence:play()
end
function rowTwoButton(section, column)
	local state <const> = trackTable[section][STATE_STR]
	local crank <const> = getCrankPos()
	
	if state == 1 then --SEQ
		local track = getTrack(section)
		local isStepActive = stepActive(track, column)
		if isStepActive then
			stepRemove(track, column)
		else
			local noteToPlay = trackTable[section][NOTE_STR] + crank * 12
			track:addNote(column, noteToPlay , 1)
		end
		
	elseif state == 2 then --OCT
		if column == 1 then
			trackTable[section][NOTE_STR] -= 12
		
		elseif column == 2 then
			trackTable[section][NOTE_STR] += 12
		end
	elseif state == 3 then --DEL
		
		if column == 1 then -- 1 Mix
		end
		if column == 2 then -- 2 Tap
		end
		if column == 3 then -- 3 Feedback
		end
			
	elseif state == 4 then -- OD
		
		-- overdriveRowNameTable = {}
		if column == 1 then -- 1 Mix
			trackTable[section][OVERDRIVE_STR]:setMix(crank)
		end
		if column == 2 then -- 2 Gain
			trackTable[section][OVERDRIVE_STR]:setGain(crank)
		end
		if column == 3 then -- 3 Limit
			trackTable[section][OVERDRIVE_STR]:setLimit(crank)
		end
		if column == 4 then -- 4 Offset
			trackTable[section][OVERDRIVE_STR]:setOffset(crank)
		end
	elseif state == 5 then -- 1F
		
	elseif state == 6 then -- 2F
		if column == 1 then -- 1 Type
			local typeSelected <const> = filterTypes[1 + math.floor(crank * 6)]
			trackTable[section][BIPOLAR_FILTER_STR]:setType(typeSelected)

		end
		if column == 2 then -- 2 Mix
			trackTable[section][BIPOLAR_FILTER_STR]:setMix(crank)
		end
		if column == 3 then -- 3 Frequency
			trackTable[section][BIPOLAR_FILTER_STR]:setFrequency(crank)
		end
		if column == 4 then -- 4 Resonance
			trackTable[section][BIPOLAR_FILTER_STR]:setResonance(crank)
		end
		if column == 5 then -- 5 Gain
			trackTable[section][BIPOLAR_FILTER_STR]:setGain(crank)
		end
		
	elseif state == 7 then -- BC
		
		-- bitCrusherRowNameTable = {}
		if column == 1 then -- 1 setMix
			trackTable[section][BITCRUSH_STR]:setMix(crank)
		end
		if column == 2 then -- 2 setAmount
			trackTable[section][BITCRUSH_STR]:setAmount(crank)
		end
		if column == 3 then -- 3 setUndersampling
			trackTable[section][BITCRUSH_STR]:setUndersampling(crank)
		end
		
	elseif state == 8 then -- RING
		
		if column == 1 then -- 1 Mix
		end
		if column == 2 then -- 2 Frequency
		end
		
	elseif state == 9 then -- BPM
		
	end
	
end

function settingsButton(section, column)
	trackTable[section][STATE_STR] = column
	needsRedrawBool = true
	playdate.update()
end

function stepActive(track, step)
	local notes = track:getNotes(step)
	return not (next(notes) == nil)
end

function getStep(track, step)
	return track:getNotes(step)
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

function makeFillPattern(fillPercent)
	local value = math.floor(0xff - (0xff * fillPercent))
	-- print(dump({ value,value,value,value,value,value,value,value, }))
	return { value,value,value,value,value,value,value,value, }
end

function gridview:drawCell(section, row, column, selected, x, y, width, height)
	local isStepActive = false
	local track = getTrack(section)
	local state = trackTable[section][STATE_STR]
	
	local xMod = 4
	local widthMod = -8
	local z = 0
	
	if selected then
		xMod = -2
		widthMod = 4
		z = 3
	end
	
	local fillPercent = 0
	cellText = " "
	print("412", cellText)

	if row == 1 then
		cellText = settingsRowNameTable[column]
		print("415", cellText)
	elseif row == 2 then
		if state == 1 then --SEQ
			local notes = track:getNotes(column)
			if (notes ~= nil and notes[1] ~= nil) then
				local note = notes[1]["note"]
				local high = 70
				local low = 30
				fillPercent =  (note - low) / (high - low)
			end
			cellText = ""..row.."-"..column
			print("444", cellText)
			tableSelected = {}
		elseif state == 2 then --OCT
			tableSelected = octaveRowNameTable
			tableSelected[3] = ""..trackTable[section][NOTE_STR].."-"
			
		elseif state == 3 then --DEL
			tableSelected = delayRowNameTable
				
		elseif state == 4 then -- OD
			tableSelected = overdriveRowNameTable
				
		elseif state == 5 then -- 1F
			tableSelected = unipolarFilterRowNameTable
		elseif state == 6 then -- 2F
			tableSelected = bipolarFilterRowNameTable
		elseif state == 7 then -- BC
			tableSelected = bitCrusherRowNameTable
		elseif state == 8 then -- RING
			tableSelected = ringModulatorRowNameTable
		elseif state == 9 then -- BPM
			-- tableSelected = ringModulatorRowNameTable
		end
		if  tableSelected ~= nil and tableSelected[column] ~= nil then
			cellText = tableSelected[column]
			print("445", cellText, trackTable[section][EFFECTS_SETTINGS_STR][state][column])
			if trackTable[section][EFFECTS_SETTINGS_STR][state][column] ~= nil then
				print("fill percent", trackTable[section][EFFECTS_SETTINGS_STR][state][column])
				fillPercent = trackTable[section][EFFECTS_SETTINGS_STR][state][column]
			end
		end
	end
	
	playdate.graphics.setPattern(makeFillPattern(fillPercent))
	playdate.graphics.fillCircleInRect(x + xMod, y + xMod, width + widthMod, height + widthMod, z)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawCircleInRect(x + xMod, y + xMod, width + widthMod, height + widthMod, z)
	playdate.graphics.drawTextInRect(cellText, x, y+14, width, 20, nil, nil, kTextAlignment.center)
	print(section, row, column, cellText)
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


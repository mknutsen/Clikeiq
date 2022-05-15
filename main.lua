

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

soloMode = false
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
settingsRowNameTable[10] = "ADSR"
settingsRowNameTable[11] = "SOLO"

bitCrusherRowNameTable = {}
bitCrusherRowNameTable[1] = "mix"
bitCrusherRowNameTable[2] = "amount"
bitCrusherRowNameTable[3] = "under"

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

bpmRowNameTable = {}
bpmRowNameTable[1] = "-"
bpmRowNameTable[2] = "+"

adsrRowNameTable = {}
adsrRowNameTable[1] = "A"
adsrRowNameTable[2] = "D"
adsrRowNameTable[3] = "S"
adsrRowNameTable[4] = "R"

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
	trackTable[number][EFFECTS_SETTINGS_STR][7] = { 0,0,0 } -- BC
	trackTable[number][EFFECTS_SETTINGS_STR][8] = { 0,0 } -- RING
	trackTable[number][EFFECTS_SETTINGS_STR][9] = {  } -- bpm
	trackTable[number][EFFECTS_SETTINGS_STR][10] = { 0,0,0,0 } -- ADSR
	trackTable[number][EFFECTS_SETTINGS_STR][11] = { } -- solo
	
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
	trackTable[number][CHANNEL_STR]:addEffect(trackTable[number][DELAY_STR])
	
	trackTable[number][OVERDRIVE_STR] = playdate.sound.overdrive.new()
	trackTable[number][OVERDRIVE_STR]:setMix(0)
	trackTable[number][OVERDRIVE_STR]:setGain(0.5)
	trackTable[number][OVERDRIVE_STR]:setLimit(0.5)
	trackTable[number][CHANNEL_STR]:addEffect(trackTable[number][OVERDRIVE_STR])
	
	trackTable[number][UNIPOLE_FILTER_STR] = playdate.sound.onepolefilter.new()
	trackTable[number][UNIPOLE_FILTER_STR]:setMix(0)
	trackTable[number][UNIPOLE_FILTER_STR]:setParameter(0)
	trackTable[number][CHANNEL_STR]:addEffect(trackTable[number][UNIPOLE_FILTER_STR])
	
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
			if soloMode then
				trackTable[section][INSTRUMENT_STR]:allNotesOff()
			else
				if row == 1 then
					settingsButton(section, column)
				elseif row == 2 then
					rowTwoButton(section, column)
				end
				-- print("UPDATING")
				needsRedrawBool= true
			end
		end,
		AButtonDown = function()
			if soloMode then
				local section, row, column = gridview:getSelection()
				trackTable[section][INSTRUMENT_STR]:playMIDINote(trackTable[section][NOTE_STR])
			end
		end,
		
		BButtonUp = function()
			if soloMode then
				soloMode = false
				local section, row, column = gridview:getSelection()
				trackTable[section][STATE_STR] = 1
				gridview:scrollToCell(section, 1, 1)
				gridview:setSelection(section, 1, 1)
			end
		end,
		--  directional buttons are for navigation
		downButtonUp = function()
			if not soloMode then
				gridview:selectNextRow(false)
			end
		end,
		
		leftButtonUp = function()
			if not soloMode then
				gridview:selectPreviousColumn(false)
			end
		end,
		
		rightButtonUp = function()
			if not soloMode then
				gridview:selectNextColumn(false)
			end
		end,
		
		upButtonUp = function()
			if not soloMode then
				gridview:selectPreviousRow(false)
			end
		end,
		cranked = function(change, acceleratedChange)
			if soloMode then
				local section, row, column = gridview:getSelection()
				noteChanged = 12 * (change / 360)
				trackTable[section][NOTE_STR] += noteChanged
				if playdate.buttonIsPressed(playdate.kButtonA) then
					trackTable[section][INSTRUMENT_STR]:playMIDINote(trackTable[section][NOTE_STR])
				end
				
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
	-- print("crank", crank)
	
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
			trackTable[section][DELAY_STR]:setMix(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 2 then -- 2 Tap
			trackTable[section][DELAY_STR]:addTap(crank * 0.5)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = 1
		end
		if column == 3 then -- 3 Feedback
			trackTable[section][DELAY_STR]:setFeedback(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
			
	elseif state == 4 then -- OD
		
		-- overdriveRowNameTable = {}
		if column == 1 then -- 1 Mix
			trackTable[section][OVERDRIVE_STR]:setMix(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 2 then -- 2 Gain
			trackTable[section][OVERDRIVE_STR]:setGain(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 3 then -- 3 Limit
			trackTable[section][OVERDRIVE_STR]:setLimit(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 4 then -- 4 Offset
			trackTable[section][OVERDRIVE_STR]:setOffset(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
	elseif state == 5 then -- 1F
		
		if column == 1 then -- 1 mix
			trackTable[section][UNIPOLE_FILTER_STR]:setMix(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
			
		elseif column == 2 then -- 1 parameter
			trackTable[section][UNIPOLE_FILTER_STR]:setParameter(4000 * crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		
	elseif state == 6 then -- 2F
		if column == 1 then -- 1 Type
			local typeSelected <const> = filterTypes[1 + math.floor(crank * 6)]
			trackTable[section][BIPOLAR_FILTER_STR]:setType(typeSelected)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank

		end
		if column == 2 then -- 2 Mix
			trackTable[section][BIPOLAR_FILTER_STR]:setMix(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 3 then -- 3 Frequency
			trackTable[section][BIPOLAR_FILTER_STR]:setFrequency(crank * 4000)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 4 then -- 4 Resonance
			trackTable[section][BIPOLAR_FILTER_STR]:setResonance(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 5 then -- 5 Gain
			trackTable[section][BIPOLAR_FILTER_STR]:setGain(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		
	elseif state == 7 then -- BC
		
		-- bitCrusherRowNameTable = {}
		if column == 1 then -- 1 setMix
			trackTable[section][BITCRUSH_STR]:setMix(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 2 then -- 2 setAmount
			trackTable[section][BITCRUSH_STR]:setAmount(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 3 then -- 3 setUndersampling
			trackTable[section][BITCRUSH_STR]:setUndersampling(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		
	elseif state == 8 then -- RING
		
		if column == 1 then -- 1 Mix
			trackTable[section][RINGMOD_STR]:setMix(crank)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		if column == 2 then -- 2 Frequency
			trackTable[section][RINGMOD_STR]:setFrequency(crank * 4000)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
		
	elseif state == 9 then -- BPM
		local tempo = sequence:getTempo()
		if column == 1 then
			tempo -= 1
		elseif column == 2 then
			tempo += 1
		end
		if tempo <= 1 then
			tempo = 1
		end
		sequence:setTempo(tempo)
		sequence:play()
	elseif state == 10 then -- ADSR
		adsrValue = 2 * crank -- crank controls up to 2 seconds
		if column == 1 then -- attack
			trackTable[section][SYNTH_STR]:setAttack(adsrValue)	
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		elseif column == 2 then -- decay
			trackTable[section][SYNTH_STR]:setDecay(adsrValue)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		elseif column == 3 then -- sustain
			trackTable[section][SYNTH_STR]:setSustain(adsrValue)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		elseif column == 4 then -- release
			trackTable[section][SYNTH_STR]:setRelease(adsrValue)
			trackTable[section][EFFECTS_SETTINGS_STR][state][column] = crank
		end
	end
	
end

function settingsButton(section, column)
	trackTable[section][STATE_STR] = column
	if column == 11 then
		soloMode = true
	end
	gridview:scrollToCell(section, 2, 1)
	gridview:setSelection(section, 2, 1)
	needsRedrawBool = true
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
	local value = math.floor(0xff * fillPercent)
	if value > 255 then
		value = 255
	end
	if value < 0 then
		value = 0
	end
	-- print(dump({ value,value,value,value,value,value,value,value, }))
	return { 0,0,0,0,0,0,0,0, value,value,value,value,value,value,value,value,}
end

function percent(amount, low, high)
	return (amount - low) / (high - low)
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
	-- print("412", cellText)

	if row == 1 then
		cellText = settingsRowNameTable[column]
		if column == state then
			fillPercent = 0.01
		end
		-- print("415", cellText)
	elseif row == 2 then
		if state == 1 then --SEQ
			local notes = track:getNotes(column)
			if (notes ~= nil and notes[1] ~= nil) then
				fillPercent =  percent(notes[1]["note"], 30, 70)
				-- print("abc123 1", fillPercent, section, row, column)
			end
			cellText = ""..section.."-"..column
			-- print("444", cellText)
			tableSelected = {}
		elseif state == 2 then --OCT
			tableSelected = octaveRowNameTable
			tableSelected[3] = ""..trackTable[section][NOTE_STR].."!"
			
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
			tableSelected = bpmRowNameTable
			tableSelected[3] = ""..sequence:getTempo().." B)"		
		elseif state == 10 then -- ADSR
			tableSelected = adsrRowNameTable
		end

		if  tableSelected ~= nil and tableSelected[column] ~= nil then
			cellText = tableSelected[column]
			-- print("445", cellText, trackTable[section][EFFECTS_SETTINGS_STR][state][column])
			if trackTable[section][EFFECTS_SETTINGS_STR][state] ~= nil and trackTable[section][EFFECTS_SETTINGS_STR][state][column] ~= nil then
				-- print("fill percent", trackTable[section][EFFECTS_SETTINGS_STR][state][column])
				-- print("abc123 2", fillPercent, section, row, column)
				fillPercent = trackTable[section][EFFECTS_SETTINGS_STR][state][column]
			end
		end
	end
	
	-- print("abc123 final", fillPercent, section, row, column)
	playdate.graphics.setPattern(makeFillPattern(fillPercent))
	playdate.graphics.fillCircleInRect(x + xMod, y + xMod, width + widthMod, height + widthMod, z)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawCircleInRect(x + xMod, y + xMod, width + widthMod, height + widthMod, z)
	playdate.graphics.drawTextInRect(cellText, x, y+14, width, 20, nil, nil, kTextAlignment.center)
	-- print(section, row, column, cellText)
end

function gridview:drawSectionHeader(section, x, y, width, height)
	playdate.graphics.drawText(getSectionName(section) .. "*", x + 10, y + 8)
end

function needsRedraw()
	needsRedrawOld = needsRedrawBool
	needsRedrawBool = false
	return needsRedrawOld
end

function playdate.update()
	if gridview.needsDisplay == true or needsRedraw() then
		playdate.graphics.clear()
		gridview:drawInRect(0, 0, 400, 240)
	end
	playdate.timer:updateTimers()
end

main()


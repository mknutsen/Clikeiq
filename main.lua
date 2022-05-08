

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


local spread = 12 -- one octave
local baseNoteSin = 50 -- near middle c


local synthSin = playdate.sound.synth.new()
synthSin:setWaveform(playdate.sound.kWaveSine)

-- local channel = playdate.sound.channel.new()
-- channel:addEffect(delayLine)
-- channel:addSource(synthSin)

local delayLenSec = 5
local levelHalf = 0.5 -- theoretically level is 0-100 cant find confirmation tho
local delayLine = playdate.sound.delayline.new(.5)
delayLine:setMix(0.7)
delayLine:setFeedback(0.1)
delayLine:addTap(0.3)
delayLine:addTap(0.2)
delayLine:addTap(0.1)
playdate.sound.addEffect(delayLine)

local sequence = playdate.sound.sequence.new()
sequence:setTempo(2)
local track = playdate.sound.track.new()
sequence:addTrack(track)
track:setInstrument(synthSin)

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


local gfx = playdate.graphics
local gridview = playdate.ui.gridview.new(44, 44)
-- gridview.backgroundImage = playdate.graphics.nineSlice.new('shadowbox', 4, 4, 45, 45)
gridview:setNumberOfColumns(8)
-- gridview:setNumberOfRows(2, 4, 3, 5) -- number of sections is set automatically
gridview:setNumberOfRows(1) -- number of sections is set automatically
-- gridview.backgroundImage = playdate.graphics.nineSlice.new('scrollbg', 20, 23, 92, 28)
gridview:setSectionHeaderHeight(24)
gridview:setContentInset(1, 4, 1, 4)
gridview:setCellPadding(4, 4, 4, 4)
gridview.changeRowOnColumnWrap = false
gridview:setScrollPosition(2,2)

-- local n = track:getNotes(1)
-- print(dump(n))
-- print(next(n) == nil)

function stepActive(track, step)
	local notes = track:getNotes(step)
	return not (next(notes) == nil)
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
	local isStepActive = stepActive(track, column)
	-- stepActive = false
	
	local xMod = 4
	local widthMod = -8
	local z = 0
	
	if selected then
		xMod = -2
		widthMod = 4
		z = 3
	end
	if isStepActive then
		gfx.fillCircleInRect(x + xMod, y + xMod, width + widthMod, height + widthMod, z)
	else
		gfx.drawCircleInRect(x + xMod, y + xMod, width + widthMod, height + widthMod, z)
	end
	local cellText = ""..row.."-"..column
	gfx.drawTextInRect(cellText, x, y+14, width, 20, nil, nil, kTextAlignment.center)
end

function gridview:drawSectionHeader(section, x, y, width, height)
	gfx.drawText("*SECTION ".. section .. "*", x + 10, y + 8)
end



function playdate.update()
	if gridview.needsDisplay == true then
		playdate.graphics.clear()
		gridview:drawInRect(0, 0, 400, 200)
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
		local isStepActive = stepActive(track, column)
		if isStepActive then
			stepRemove(track, column)
		else
			local crank = playdate.getCrankPosition()
			local crankModify =  (spread * (crank / 360))
			track:addNote(column, baseNoteSin + crankModify, 1)
		end
	end
	-- listview:drawInRect(220, 20, 160, 210)
	playdate.timer:updateTimers()
end


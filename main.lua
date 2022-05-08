

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



local gfx = playdate.graphics
local gridview = playdate.ui.gridview.new(44, 44)
-- gridview.backgroundImage = playdate.graphics.nineSlice.new('shadowbox', 4, 4, 45, 45)
gridview:setNumberOfColumns(8)
gridview:setNumberOfRows(2, 4, 3, 5) -- number of sections is set automatically
gridview:setSectionHeaderHeight(24)
gridview:setContentInset(1, 4, 1, 4)
gridview:setCellPadding(4, 4, 4, 4)
gridview.changeRowOnColumnWrap = false
gridview:setScrollPosition(2,2)

function gridview:drawCell(section, row, column, selected, x, y, width, height)
	if selected then
		gfx.drawCircleInRect(x-2, y-2, width+4, height+4, 3)
	else
		gfx.drawCircleInRect(x+4, y+4, width-8, height-8, 0)
	end
	local cellText = ""..row.."-"..column
	gfx.drawTextInRect(cellText, x, y+14, width, 20, nil, nil, kTextAlignment.center)
end

function gridview:drawSectionHeader(section, x, y, width, height)
	gfx.drawText("*SECTION ".. section .. "*", x + 10, y + 8)
end



function playdate.update()
	if gridview.needsDisplay == true then
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
	-- listview:drawInRect(220, 20, 160, 210)
	playdate.timer:updateTimers()
end


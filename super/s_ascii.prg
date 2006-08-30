Function asciitable(bAction,cTitle,nStart)
local nRow := row(),nCol := col()
local nTop    := 0
local nLeft   := 0
local nBottom := 16
local nRight  := 65
local aGrid := grid()
local nChar := 0

sbcenter(@nTop,@nLeft,@nBottom,@nRight)

nChar := PSTABMENU(nTop,nLeft,nBottom,nRight,aGrid,cTitle,nStart)
devpos(nRow,nCol)
if nChar > 0
  if bAction#nil
    eval(bAction,chr(nChar))
  endif
endif
return nChar

//--------------------------------------------------------------

static function grid
local aGrid := array(255)
local iCount
for iCount := 1 to 255
   aGrid[iCount] := chr(iCount)
next
return  aGrid


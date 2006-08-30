
FUNCTION mfields(cTitle,nTop,nLeft,nBottom,nRight)
local nBoxDepth,nSelection,cFieldName,nOldCursor
local cUnderScreen,aFieldList

*- if no DBf, we're gone
IF !used()
  RETURN ''
ENDIF

*- save cursor status, set cursor off
nOldCursor = setcursor(0)

*- put them in an array
aFieldList := array( fcount() )
AFIELDS(aFieldList)

*- if we haven't been given coordinates, figure some out
IF Pcount() < 5
  nBoxDepth := ROUND(fcount()/2,0)
  nTop      := MAX(2, 12-nBoxDepth)
  nBottom   := MIN(22,12+nBoxDepth+1)
  nLeft     := 30
  nRight    := 50
ENDIF

*- draw the box
cUnderScreen=makebox(nTop,nLeft,nBottom,nRight,sls_popcol())

*- display the cTitle
IF Pcount() > 0
  @nTop,nLeft+1 SAY '['+cTitle+']'
ENDIF

*- do an achoice on the array
nSelection = SACHOICE(nTop+1,nLeft+1,nBottom-1,nRight-1,aFieldList)

*- was a field selected?
cFieldName  = IIF(nSelection > 0, aFieldList[nSelection],'')

*- close the box
unbox(cUnderScreen)

*- set cursor on
SETCURSOR(nOldCursor)

*- return the selection
RETURN cFieldName


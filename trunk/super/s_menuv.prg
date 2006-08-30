FUNCTION menu_v(cTitle,cOption1,cOption2,cOption3,cOption4,cOption5,;
                cOption6,cOption7,cOption8,cOption9,cOption10,cOption11,;
                cOption12,cOption13,cOption14,cOption15 )

local nTop,nLeft,nBottom,nright,nSelection,nOptionCount
local cUnderScreen,nLongest
local nIterator,nOldCursor
local aOptions := {cOption1,cOption2,cOption3,cOption4,cOption5,;
                cOption6,cOption7,cOption8,cOption9,cOption10,cOption11,;
                cOption12,cOption13,cOption14,cOption15 }

nOldCursor := setcursor(0)

*- how many nOptionCount - maximum 15
nOptionCount := pcount()-1
nOptionCount := MIN(nOptionCount,15)
asize(aOptions,nOptionCount)

nLongest := LEN(cTitle)
FOR nIterator = 1 TO nOptionCount
  nLongest = MAX(nLongest,LEN(aOptions[nIterator]) )
NEXT

*figure out the box dimensions  and draw the box
nTop      :=5
nBottom   := 6+nOptionCount
nLeft     := INT((79-nLongest)/2 - 1)
nright    := nLeft+nLongest+2
cUnderScreen :=makebox(nTop,nLeft,nBottom,nRight,sls_popcol())
@nTop,nLeft+1 SAY cTitle color sls_popcol()

*- loop through and @prompt the nOptionCount
FOR nIterator = 1 TO nOptionCount
   @5+nIterator,nLeft+2 PROMPT aOptions[nIterator]
NEXT

*- get the selection
MENU TO nSelection

*- hit the road, jack
unbox(cUnderScreen)

*- set cursor back
SETCURSOR(nOldCursor)
RETURN nSelection



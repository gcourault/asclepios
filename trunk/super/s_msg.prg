FUNCTION msg(cMsg1,cMsg2,cMsg3,cMsg4,cMsg5,cMsg6,cMsg7,cMsg8,cMsg9)
local nMessageLines,nIterator,nTop,nLeft,nBottom
local nRight,cUnderScreen,nOldCursor
LOCAL nTimeout,lIsTimer,nLongest
LOCAL aMessages

*- save cursor status, set cursor off
nOldCursor = setcursor(0)

*- how many paramaters passed (maximum 9)
IF VALTYPE(cMsg1) == "N"
  lIsTimer      := .T.
  nTimeout      := cMsg1
  nMessageLines := MIN(Pcount()-1,8)
  aMessages     := {cMsg2,cMsg3,cMsg4,cMsg5,cMsg6,cMsg7,cMsg8,cMsg9}
ELSE
  lIsTimer      := .F.
  nTimeout      := 0
  nMessageLines := MIN(Pcount(),9)
  aMessages     := {cMsg1,cMsg2,cMsg3,cMsg4,cMsg5,cMsg6,cMsg7,cMsg8,cMsg9}
ENDIF
asize(aMessages,nMessagelines)

*- whats the longest string
nLongest = MAX(bigelem(aMessages)+1,16)

*- figure the window coordinates
nTop            := 8
* if no lIsTimer value, leave blank line before "Press a key...", else no space
nBottom         := IIF(nTimeout=0,nTop+nMessageLines+3,nTop+nMessageLines+1)
nLeft           := INT((79-nLongest)/2 - 1)
nRight          := nLeft+nLongest+2

*- draw a box
cUnderScreen = makebox(nTop,nLeft,nBottom,nRight,sls_popcol())

* display the message
FOR nIterator = 1 TO nMessageLines
  @8+nIterator,nLeft+2 SAY aMessages[nIterator]
NEXT
* now the results of the lIsTimer value
IF nTimeout = 0
  @ nBottom-1,nLeft+2 SAY "Pulse una Tecla ..."
  *- wait
  INKEY(0)
ELSE
  INKEY(nTimeout)
ENDIF 
*- leave
unbox(cUnderScreen)

*- set cursor on, if that's where it was
SETCURSOR(nOldCursor)
RETURN ''


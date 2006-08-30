FUNCTION messyn(cMessage,expParam1,expParam2,expParam3,expParam4)
local  nParamCount,cPrompt1,cPrompt2,nTop,nBottom,nLeft,nRight
local  nPromptLength,nMessageLength,nBoxLength
local  nColumn1,nColumn2,nSelection,lYesorNo,cUnderScreen,nOldCursor

nParamCount = Pcount()
IF nParamCount < 1
  RETURN ''
ENDIF

*- save cursor status, set cursor off
nOldCursor = setcursor(0)

*- set up defaults for prompts
cPrompt1 := "SI"
cPrompt2 := "NO"

*- default nTop, nLeft
nTop     := 0
nLeft    := 0

*- if there are at least 3 params
IF nParamCount > 2
  IF valtype(expParam1)=="C"
    *- if the second param is character
    *- these must be prompts
    cPrompt1 := expParam1
    cPrompt2 := expParam2
    
    *- and if there are 5 params
    *- the other two params must be dimensions
    IF nParamCount = 5
      nTop  := expParam3
      nLeft := expParam4
    ENDIF
  ELSE
    *- if the second param is not character
    *- these must be dimensions
    nTop  := expParam1
    nLeft := expParam2
    
    *- and if there are 5 params, the other two nParamCount must
    *- be prompts
    IF nParamCount = 5
      cPrompt1 := expParam3
      cPrompt2 := expParam4
    ENDIF
  ENDIF
ENDIF

*- figure out the prompt, message, and box lengths
nPromptLength   := 2+LEN(cPrompt1)+2+LEN(cPrompt2)+2
nMessageLength  := 2+LEN(cMessage)+2
nBoxLength      := MAX(nPromptLength,nMessageLength)

*- finish up the box dimensions
nBottom         := nTop+3
nRight          := nLeft+nBoxLength

if nTop==0 .and. nLeft==0
  sbcenter(@nTop,@nLeft,@nBottom,@nRight)
endif

*- where do we place our 2 prompts
nColumn1        := INT( nLeft+INT((nBoxLength-(nPromptLength-4))/2) )
nColumn2        := nColumn1+LEN(cPrompt1)+2

*- ok, draw the box, do the prompts, and MENU TO
cUnderScreen    := makebox(nTop,nLeft,nBottom,nRight,sls_popcol())
nSelection      := 1
@nTop+1,nLeft+1 SAY cMessage
@nTop+2,nColumn1 PROMPT cPrompt1
@nTop+2,nColumn2 PROMPT cPrompt2
MENU TO nSelection

*- if the first prompt is selected, return .t. - otherwise return .f.
*- thus escape returns .f.
IF nSelection = 1
  lYesorNo = .T.
ELSE
  lYesorNo = .F.
ENDIF

*- clean up and leave
unbox(cUnderScreen)

*- set cursor on, if that's where it was
SETCURSOR(nOldCursor)

RETURN lYesorNo



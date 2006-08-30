FUNCTION plswait(lBoxOn,cMessage,nTop,nLeft,nBottom,nRight)
local  cInColor,nLenMessage
static nsTop,nsLeft,nsBottom,nsRight,cUnder

IF !VALTYPE(cMessage)=="C"
  cMessage := "Un momento por favor..."
ENDIF

nLenMessage := MIN(LEN(cMessage),76)
cMessage    := LEFT(cMessage,nLenMessage)

IF lBoxOn
  IF nTop#nil.and. nLeft#nil .and. nRight#nil .and. nBottom#nil
    nsTop    := nTop
    nsLeft   := nLeft
    nsBottom := nBottom
    nsRight  := nRight
  ELSE
    nsTop    := 10
    nsBottom := 12
    nsLeft   := INT((79-nLenMessage)/2 - 1)
    nsRight  := nsLeft+nLenMessage+2
  ENDIF
ENDIF
IF lBoxOn
  cInColor  := Setcolor()
  cUnder    :=makebox(nsTop,nsLeft,nsBottom,nsRight,sls_popcol())
  @nsTop+1,nsLeft+1 SAY cMessage color sls_popcol()
  Setcolor(cInColor)
ELSE
  unbox(cUnder)
  cUnder   := nil
  nsTop    := nil
  nsLeft   := nil
  nsBottom := nil
  nsRight  := nil
ENDIF
RETURN ''





//use customer
//mfieldstype("LN")
//------------------------------------------------------
FUNCTION mfieldsType(cType,cTitle,nTop,nLeft,nBottom,nRight)
local nBoxDepth,nSelection,cFieldName,nOldCursor,i
local cUnderScreen
local aFieldList    := aFieldsType(cType)

IF !used() .or. len(aFieldList)=0
  RETURN ''
ENDIF
nOldCursor := setcursor(0)
*- if we haven't been given coordinates, figure some out
IF nTop==nil.or.nLeft==nil.or.nBottom==nil.or.nRight==nil
  nBoxDepth := ROUND(fcount()/2,0)
  nTop      := MAX(2, 12-nBoxDepth)
  nBottom   := MIN(22,12+nBoxDepth+1)
  nLeft     := 30
  nRight    := 50
ENDIF
cUnderScreen :=makebox(nTop,nLeft,nBottom,nRight,sls_popcol())
*- display the cTitle
IF cTitle#nil
  @nTop,nLeft+1 SAY '['+cTitle+']'
ENDIF

nSelection = SACHOICE(nTop+1,nLeft+1,nBottom-1,nRight-1,aFieldList)

cFieldName  := IIF(nSelection > 0, aFieldList[nSelection],'')
unbox(cUnderScreen)
SETCURSOR(nOldCursor)
RETURN cFieldName


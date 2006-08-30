FUNCTION popread(lBelow,m1,v1,p1,m2,v2,p2,m3,v3,p3,m4,v4,p4,m5,v5,p5,m6,v6,p6)
local nReadCount,nTop,nLeft,nRight,nBottom
local cThiscolor,cOldColor,nTempWidth
local nIter,string,nBoxWidth,cUnder,nPcount,nStartSays,nOldCursor
local aSets := {{m1,v1,p1,{|_1|v1:=iif(_1#nil,_1,v1)} },;
                {m2,v2,p2,{|_1|v2:=iif(_1#nil,_1,v2)} },;
                {m3,v3,p3,{|_1|v3:=iif(_1#nil,_1,v3)} },;
                {m4,v4,p4,{|_1|v4:=iif(_1#nil,_1,v4)} },;
                {m5,v5,p5,{|_1|v5:=iif(_1#nil,_1,v5)} },;
                {m6,v6,p6,{|_1|v6:=iif(_1#nil,_1,v6)} }}
local getlist := {}


nPcount    := Pcount()-1
nStartSays   := 1
cOldColor  := Setcolor()
*cThiscolor := Setcolor()
cThiscolor := sls_popcol()

IF VALTYPE(m1)=="N"
  nPcount    := nPcount-3
  asize(asets,nPcount)
  nTop       := m1
  nLeft      := v1
  cThiscolor := p1
  nStartSays := 2
ENDIF

nReadCount   := INT(nPcount/3)
nReadCount   := MIN(nReadCount,5)

nBoxWidth    := 4
FOR nIter = nStartSays TO nReadCount+nStartSays-1
  nTempWidth := IIF(lBelow,;
      MAX(LEN(aSets[nIter,1]),LEN(TRANS(aSets[nIter,2],aSets[nIter,3])))+2,;
      LEN(aSets[nIter,1])+LEN(TRANS(aSets[nIter,2],aSets[nIter,3]))+4)
  nBoxWidth = MAX(nBoxWidth,nTempWidth)
NEXT
nBoxWidth = MIN(nBoxWidth,75)

*- figure window dimensions
IF !(VALTYPE(nTop)+VALTYPE(nLeft)=="NN")
  IF lBelow
    nTop := INT((24-nReadCount*2)/2)-1
  ELSE
    nTop := INT((24-nReadCount)/2)-1
  ENDIF
  nLeft  := INT((79-nBoxWidth)/2)+1
ENDIF
nRight = nLeft+nBoxWidth+1
nBottom = IIF(lBelow,nTop+(nReadCount*2)+1,nTop+nReadCount+1)

*- draw window
cUnder  :=makebox(nTop,nLeft,nBottom,nRight,cThisColor)

*- turn cursor on
nOldCursor = setcursor()
SET CURSOR ON

*- put cursor at starting position
devpos(nTop,nLeft)

*- loop through and put up says/gets/pictures , then READ
FOR nIter= nStartSays TO nReadCount+nStartSays-1
  @ROW()+1,nLeft+2 SAY aSets[nIter,1]
  IF lBelow
    @ROW()+1,nLeft+2 GET aSets[nIter,2] PICT aSets[nIter,3]
  ELSE
    @ROW(),COL()+2 GET aSets[nIter,2]  PICT aSets[nIter,3]
  ENDIF
NEXT
READ
FOR nIter= nStartSays TO nReadCount+nStartSays-1
  eval(aSets[nIter,4],aSets[nIter,2])
NEXT

*- put things back as they were
SETCURSOR(nOldCursor)
Setcolor(cOldColor)
unbox(cUnder)
RETURN ''


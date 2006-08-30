FUNCTION one_read(cM1,cV1,cP1,cM2,cV2,cP2,cM3,cV3,cP3,cM4,cV4,cP4)
LOCAL aParams := { {cM1,cV1,cP1},{cM2,cV2,cP2},{cM3,cV3,cP3},{cM4,cV4,cP4} }
LOCAL nTop:=0,nLeft:=0
LOCAL nBottom,nRight
LOCAL nLength, nDepth
LOCAL i,cBox
LOCAL nOldCursor
LOCAL cMacro
memvar getlist

asize(aParams,INT(pcount()/3) )
nRight  := 20
nBottom := len(aParams)+2

for i = 1 to len(aParams)
  nRight  := max(nRight ,len(aParams[i,1])+2)
  nRight  := max(nRight ,len(trans(&( aParams[i,2]),aParams[i,3] ))+2)
next
nRight  := min(nRight ,78)

sbcenter(@nTop,@nLeft,@nBottom,@nRight)

cBox := makebox(nTop,nLeft,nBottom,nRight,sls_popcol() )
nOldCursor := setcursor(1)

FOR i = 1 to len(aParams)
  cMacro := aParams[i,2]
  @nTop+i,nLeft+1 say aParams[i,1] get &cMacro picture aParams[i,3]
NEXT
READ

SETCURSOR(nOldCursor)
unbox(cbox)
RETURN ''




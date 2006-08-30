FUNCTION makebox(nTop,nLeft,nBottom,nRight,cColorString,nShadowPos)
local cSaveUnder
local nRealTop,nRealLeft,nRealBottom,nRealRight


IF valtype(nShadowPos)<>"N"
  *- use default shadow nShadowPos
  nShadowPos = sls_shadpos()
ENDIF 

*- find out what area to savescreen, taking shadow into account
nRealTop    := nTop
nRealLeft   := nLeft
nRealBottom := nBottom
nRealRight  := nRight
DO CASE
CASE nShadowPos = 1 .and. nBottom <Maxrow() .and. nLeft > 0
  nRealLeft   := MAX(0,nLeft-1)
  nRealBottom := MIN(maxrow(),nBottom+1)
CASE nShadowPos = 3 .and. nBottom <Maxrow() .and. nRight < Maxcol()
  nRealBottom = MIN(maxrow(),nBottom+1)
  nRealRight = MIN(maxcol(),nRight+1)
CASE nShadowPos = 9 .and. nTop > 0 .and. nRight < Maxcol()
  nRealTop = MAX(0,nTop-1)
  nRealRight = MIN(maxcol(),nRight+1)
CASE nShadowPos = 7 .and. nTop > 0 .and. nLeft > 0
  nRealTop = MAX(0,nTop-1)
  nRealLeft = MAX(0,nLeft-1)
ENDCASE

*- determine colors
IF valtype(cColorString) <> "C"
  cColorString = Setcolor()
ENDIF
*- set color and store old setting to cSaveUnder
cSaveunder := padr(Setcolor(cColorString),30)

*- store the screen, plus the dimensions to a cSaveUnder

cSaveUnder += str(nRealTop,2,0)+str(nRealLeft,2,0)+str(nRealBottom,2,0)+str(nRealRight,2,0)
cSaveunder += Savescreen(nRealTop,nRealLeft,nRealBottom,nRealRight)

*- explode it?
IF sls_xplode()
  xbxx(nTop,nLeft,nBottom,nRight,cColorString,nShadowPos,sls_shadatt(),sls_frame(),50)
ELSE
  xbxx(nTop,nLeft,nBottom,nRight,cColorString,nShadowPos,sls_shadatt(),sls_frame())
ENDIF

*- return the cSaveUnder containing the screen, dimensions, and colors
*- which will be used by unbox to restore the screen and colors
RETURN cSaveUnder

*: EOF: S_MAKEB.PRG


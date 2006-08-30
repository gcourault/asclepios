FUNCTION unbox(cSavedScreen,nTop,nLeft,nBottom,nRight,bRest)

local nBoxTop,nBoxRight,nBoxBottom,nBoxLeft,cBoxDimChunk
local cActualScreen,cColorChunk
local bRestScreen

static bSRestScreen

if bSRestScreen#nil
   bRestScreen :=  bSRestscreen
elseif sls_xplode()
   bRestScreen := {|t,l,b,r,s|bxx_imbox(t,l,b,r,s)}
else
   bRestScreen := {|t,l,b,r,s|restscreen(t,l,b,r,s)}
endif


*- if 5 params passed,
IF VALTYPE(bRest)=="B"  // block passed
   bSRestscreen := bRest
ELSEIF VALTYPE(bRest)=="C"
   bSRestscreen := NIL
ELSEIF Pcount() == 5
   EVAL(bRestscreen,nTop,nLeft,nBottom,nRight,cSavedScreen)
   *- assume a full screen restore
ELSEIF Pcount() = 2
   nBoxTop   :=  0
   nBoxLeft  :=  0
   nBoxBottom   :=  maxrow()
   nBoxRight :=  maxcol()
   EVAL(bRestscreen,0,0,maxrow(),maxcol(),cSavedScreen)
   *- extract color, dimensions and screen from the string.
ELSE
   cBoxDimChunk    := SUBST(cSavedScreen,31,8)
   cColorChunk     := TRIM(SUBST(cSavedScreen,1,30))
   cActualScreen   := SUBST(cSavedScreen,39)
   nBoxTop         := VAL(SUBST(cBoxDimChunk,1,2))
   nBoxLeft        := VAL(SUBST(cBoxDimChunk,3,2))
   nBoxBottom      := VAL(SUBST(cBoxDimChunk,5,2))
   nBoxRight       := VAL(SUBST(cBoxDimChunk,7,2))
   EVAL(bRestscreen,nBoxTop,nBoxLeft,nBoxBottom,nBoxRight,cActualScreen)
   Setcolor(cColorChunk)
ENDIF
RETURN nil


static function bxx_imbox(nTop,nLeft,nBottom,nRight,cScreen)
local nRows,nColumns,cScreen2

nRows    := nBottom-nTop+1
nColumns := nRight-nLeft+1

do while nRows > 5 .and. nColumns > 9
*   dispbegin()
   cScreen2  := savescreen(nTop+2,nLeft+2,nBottom-2,nRight-2)
   restscreen(nTop,nLeft,nBottom,nRight,cScreen)
   nTop      += 2
   nBottom   -= 2
   nLeft     += 2
   nRight    -= 2
   cScreen   := savescreen(nTop,nLeft,nBottom,nRight)
   restscreen(nTop,nLeft,nBottom,nRight,cScreen2)
*   dispend()
   nRows    := nBottom-nTop+1
   nColumns := nRight-nLeft+1
enddo
restscreen(nTop,nLeft,nBottom,nRight,cScreen)
return nil


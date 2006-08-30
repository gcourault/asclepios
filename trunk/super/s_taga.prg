#include "inkey.ch"
#define GOINGDOWN 1
#define GOINGUP   2

FUNCTION TAGARRAY(aArray,cTitle,cMark,aLogical)
LOCAL aTagged := {}
LOCAL cTagScreen
LOCAL oTagTBrowse
LOCAL nElement := 1
local nTaggedItems := 0
local nTop,nLeft,nBottom,nRight
local nLastKey,i
local nFoundTagged
local nDirection  := GOINGDOWN

aLogical := iif(aLogical#nil,aLogical,array(len(aArray)))

if (len(aLogical) != len(aArray) )
  asize(aLogical,len(aArray))
endif
//aeval(aLogical,{|e| e := iif(e == NIL,.f.,e)})
afillnil(aLogical,.f.)

for i = 1 to len(aLogical)
  if aLogical[i]
    aadd(aTagged,i)
    nTaggedItems++
  endif
next


IF aArray#nil .and. LEN(aArray)>0 .and.  AMATCHES(aArray,{|e|valtype(e)=="U"})=0

  nTop    := 5
  nLeft   := 15
  nBottom := 20
  nRight  := 65

  cMark := IIF(cMark#NIL,cMark,"û")
  *- DRAW THE BOX
  cTagScreen=MAKEBOX(nTop,nLeft,nBottom,nRight,SLS_POPCOL())
  if cTitle#NIL
    @nTop+1,nLeft+1 say cTitle
    @nTop+2,nLeft+1 to nTop+2,nRight-1
  endif
  @nBottom-2,nLeft+1 to nBottom-2,nRight-1
  @nBottom-1,nLeft+1 say chr(24)+' '+chr(25)+' '+chr(26)+' '+chr(27)+'  espacio=MARCA  L=LIMPIA  F10=FIN'

  *- BUILD THE TBROWSE OBJECT
  oTagTbrowse := TBROWSENEW(iif(cTitle#nil,nTop+3,nTop+1),nLeft+1,nBottom-3,nRight-1)
  oTagTbrowse:COLSEP := "³"

  *- ADD THE TBCOLUMNS
  oTagTbrowse:ADDCOLUMN(tbColumnNew(nil,{||IIF(IS_IT_TAG(nElement,aTagged) ,padc(cMark,5),space(5))} ))
  oTagTbrowse:ADDCOLUMN(tbColumnNew(nil,{||padr(aArray[nElement],35)} ))
  oTagTbrowse:SKIPBLOCK := {|N|AASKIP(N,@nElement,LEN(aArray))}
  oTagTBrowse:goBottomBlock := {|| nElement := len(aArray)}
  oTagTbrowse:goTopBlock    := {|| nElement := 1}


  DO WHILE .T.
     WHILE !oTagTbrowse:STABILIZE()
     END
     nLastKey := INKEY(0)

     do case
     CASE nLastKey = K_UP          && UP ONE ROW
       oTagTbrowse:UP()
       nDirection := GOINGUP
     CASE nLastKey = K_PGUP        && UP ONE PAGE
       oTagTbrowse:PAGEUP()
       nDirection := GOINGUP
     CASE nLastKey = K_HOME        && HOME
       oTagTbrowse:GOTOP()
       nDirection := GOINGDOWN
     CASE nLastKey = K_DOWN        && DOWN ONE ROW
       oTagTbrowse:DOWN()
       nDirection := GOINGDOWN
     CASE nLastKey = K_PGDN        && DOWN ONE PAGE
       oTagTbrowse:PAGEdOWN()
       nDirection := GOINGDOWN
     CASE nLastKey = K_END         && END
       oTagTbrowse:GOBOTTOM()
       nDirection := GOINGUP
     case nLastKey = 32
       *- LOOK FOR RECORD # IN ARRAY
       nFoundTagged = aSCAN(aTagged,nElement)
       if nFoundTagged > 0
         aDEL(aTagged,nFoundTagged)
         nTaggedItems--
         ASIZE(aTagged,nTaggedItems)
       else
         aadd(aTagged,nElement)
         nTaggedItems++
       endif
       oTagTbrowse:REFRESHCURRENT()
       IF nDirection == GOINGUP
          oTagTbrowse:up()
       ELSE
          oTagTbrowse:down()
       ENDIF
     case nLastKey = K_F10
       EXIT
     case nLastKey = 75 .or. nLastKey = 107
       ASIZE(aTagged,0)
       nTaggedItems  := 0
       oTagTbrowse:REFRESHALL()
     endcase
  ENDDO
  unbox(cTagScreen)
ENDIF
afill(aLogical,.f.)
for i = 1 to len(aTagged)
   aLogical[aTagged[i]] := .t.
next

return aTagged


STATIC function IS_IT_TAG(nItemNum,aTagged)
return (Ascan(aTagged,nItemNum)> 0)

static function afillnil(aIn,expFill)
local i
for i = 1 to len(aIn)
  if aIn[i]==nil
    aIn[i] := expFill
  endif
next
return nil



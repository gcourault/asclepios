// slight behavior change - boxes are 1 character wider.

#include "inkey.ch"
#define   A_BOXTOPBAR     1
#define   A_TOPBARCOLOR   2
#define   A_MENUBOXCOLOR  3
#define   A_MENUBOXFRAME  4
#define   A_SHADOWPOS     5
#define   A_SHADOWATT     6
#define   A_MENUBARROW    7

FUNCTION pulldn(nSelection,acOptions,aAttributes,aColumns)
local aTitles       := {}
local aBoxOptions   := {}
local aColumnPos    := {}
local i
local cOldColor,cTopLine,nOldCursor
local cTitleTrigs,nSepSpace,nTitleLine,nLastBox,nCurrBox,nStartElement
local nBoxLen,nBoxRows,nLenTitle
local nBoxLeft,nBoxRight,nBoxTop,nBoxBottom
local cThisBox
local nLastKey,nReturn
local lMainDone := .f.

nSelection := MAX(1.01,nSelection)

cTitleTrigs := parsearrays(acOptions,aTitles,aBoxOptions)

IF VALTYPE(aAttributes) <> "A"
  aAttributes := array(7)
  aAttributes[A_BOXTOPBAR   ] := .T.
  aAttributes[A_TOPBARCOLOR ] := Setcolor()
  aAttributes[A_MENUBOXCOLOR] := Setcolor()
  aAttributes[A_MENUBOXFRAME] := sls_frame()
  aAttributes[A_SHADOWPOS   ] := 0
  aAttributes[A_SHADOWATT   ] := 0
  aAttributes[A_MENUBARROW  ] := 0
ENDIF


cOldColor := Setcolor(aAttributes[A_TOPBARCOLOR])
cTopLine := Savescreen(aAttributes[A_MENUBARROW],0,;
           aAttributes[A_MENUBARROW]+2,79)

IF aAttributes[A_BOXTOPBAR]
  DISPBOX(aAttributes[A_MENUBARROW],0,aAttributes[A_MENUBARROW]+2,79,;
               aAttributes[A_MENUBOXFRAME])
ENDIF

*- get menu aTitles,positions
nLenTitle := 0
for i = 1 TO LEN(aTitles)
  nLenTitle  += LEN(aTitles[i])
NEXT

nSepSpace  := INT((77-nLenTitle)/(LEN(acOptions)+1))

nTitleLine := IIF(aAttributes[A_BOXTOPBAR],aAttributes[A_MENUBARROW]+1,;
              aAttributes[A_MENUBARROW])

IF aColumns ==nil
  aColumns := array(len(aTitles))
  aColumns[1] :=nSepSpace+1
  @nTitleLine,aColumns[1] say aTitles[1]
  FOR i = 2 TO LEN(acOptions)
    aColumns[i] = aColumns[i-1]+LEN(aTitles[i-1])+nSepSpace
    @nTitleLine,aColumns[i] SAY aTitles[i]
  NEXT
ELSE
  FOR i = 1 TO LEN(acOptions)
    @nTitleLine,aColumns[i] say aTitles[i]
  NEXT
ENDIF


*- init last menu #, current menu # , and starting element
nLastBox        := LEN(acOptions)
nCurrBox        := MAX(INT(nSelection),1)
nStartElement   := ROUND(MAX((nSelection-nCurrBox)*100,1),0)

Setcolor(aAttributes[A_MENUBOXCOLOR])
*- main loop
nOldCursor = setcursor(0)
WHILE !lMainDone
  nBoxLen    := bigelem(aBoxOptions[nCurrBox])
  nBoxRows   := len(aBoxOptions[nCurrBox])
  // nBoxRows   := MIN(20,len(aBoxOptions[nCurrBox]) )  // old

  nBoxLeft   := aColumns[nCurrBox]
  nBoxLeft   := nBoxLeft-(MAX(nBoxLeft+nBoxLen-76,0))
  nBoxRight  := nBoxLeft+nBoxLen+3
  nBoxTop    := nTitleLine+1
  nBoxBottom := nBoxTop + nBoxRows+1
  
  *- save the screen
  cThisBox = Savescreen(nBoxTop-1,nBoxLeft-1,nBoxBottom+1,nBoxRight+1)

  *- hilite the first letter of the menu title
  IF aAttributes[A_TOPBARCOLOR]==aAttributes[A_MENUBOXCOLOR]
    @nTitleLine,aColumns[nCurrBox] say left(aTitles[nCurrBox],1) color "+W/N"
  ELSE
    @nTitleLine,aColumns[nCurrBox] say left(aTitles[nCurrBox],1)
  ENDIF

  *- draw the menu box
  IF nBoxRows > 0
    bxx(nBoxTop,nBoxLeft,nBoxBottom,nBoxRight,SETCOLOR(),;
       aAttributes[A_SHADOWPOS],aAttributes[A_SHADOWATT],;
       aAttributes[A_MENUBOXFRAME])
    
       nLastKey := BRZARRAY(aBoxOptions[nCurrBox],;
                   nBoxTop+1,nBoxLeft+1,nBoxBottom-1,nBoxRight-1,;
                   nStartElement,cTitleTrigs)
    
  ELSE
       nLastKey := INKEY(0)
       if nLastKey==13 .or. upper(chr(nLastKey))==subst(cTitleTrigs,nCurrBox,1)
         nLAstKey := 1010
       elseif upper(chr(nLastKey))$cTitleTrigs
         nLastKey := 2000+at(upper(chr(nLastkey)),cTitleTrigs)
       endif
  ENDIF
  *- restore the screen and colors
  Restscreen(nBoxTop-1,nBoxLeft-1,nBoxBottom+1,nBoxRight+1,cThisBox)
  
  *- if a selection was made, return the menu and option in the form menu.option
  do case
  case nLastKey==K_LEFT
     nCurrBox := iif(nCurrBox=1,len(aTitles),nCurrBox-1)
     nStartElement := 1
  case nLastKey==K_RIGHT
     nCurrBox := iif(nCurrBox=len(aTitles),1,nCurrBox+1)
     nStartElement := 1
  case nLastKey > 2000   // a title key
     nCurrBox := nLastKey-2000
     nStartElement := 1
  case nLastKey > 1000    // an element selected
     nLastKey -=1000
     nReturn    := nCurrBox+(nLastKey/100)
     lMainDone := .t.
  case nLastKey==K_ESC
     nReturn := 0
     lMainDone := .t.
  endcase

ENDDO
*- clean up, return value
Restscreen(aAttributes[A_MENUBARROW],0,;
           aAttributes[A_MENUBARROW]+2,79,cTopLine)
Setcolor(cOldColor)
SETCURSOR (nOldCursor)
RETURN nReturn


//--------------------------------------------------------------
STATIC FUNCTION BRZARRAY(aArray,nTop,nLeft,nBott,nright,nStart,cTitleTrigs)
LOCAL cTagScreen
LOCAL oBrowse
LOCAL nElement := 1
local nLastKey,cLastKey
local nWidth := nRight-nLeft-1
local nFound
local ldone  := .f.
local bKeyBlock
oBrowse := TBROWSENEW(ntop,nLeft,nBott,nright)
oBrowse:colsep := ""

*- ADD THE TBCOLUMNS
oBrowse:ADDCOLUMN(tbColumnNew(nil,{||padr(aArray[nElement],nWidth)} ))
oBrowse:skipblock  := {|n|aaskip(n,@nElement,LEN(aArray))}
oBrowse:gotopblock := {||agotop(nElement,oBrowse)}
oBrowse:gobottomblock := {||agobot(nElement,LEN(aArray),oBrowse)}

if nStart>1
  agoto(nStart,nElement,oBrowse)
endif
WHILE !lDone
   WHILE !oBrowse:STABILIZE()
   END
   nLastKey := INKEY(0)
   do case
   CASE nLastKey = K_UP
    if nElement>1         && UP ONE ROW
     oBrowse:UP()
    else
     oBrowse:GOBOTTOM()
    endif
   CASE nLastKey = K_PGUP        && UP ONE PAGE
     oBrowse:PAGEUP()
   CASE nLastKey = K_HOME        && HOME
     oBrowse:GOTOP()
   CASE nLastKey = K_DOWN        && DOWN ONE ROW
     if nElement <len(aArray)
       oBrowse:DOWN()
     else
       oBrowse:GOTOP()
     endif
   CASE nLastKey = K_PGDN        && DOWN ONE PAGE
     oBrowse:PAGEdOWN()
   CASE nLastKey = K_END         && END
     oBrowse:GOBOTTOM()
   case (cLastKey:=upper(chr(nLastKey)))$"ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890"
        nFound := ASCAN(aArray,{|e|upper(LEFT(e,1))==cLastKey},nElement)
        if nFound==0 .and. nElement > 1
          nFound := ASCAN(aArray,{|e|upper(LEFT(e,1))==cLastKey})
        endif
        if nFound > 0
          agoto(nFound,nElement,oBrowse)
          nLastKey := nFound+1000
          lDone := .t.
        elseif cLastkey$cTitleTrigs
          nLastKey := 2000+at(cLastKey,cTitleTrigs)
          lDone := .t.
        endif
   case nLastKey = K_ENTER
          nLastKey := nElement+1000
          lDone := .t.
   case nLastKey = K_LEFT .or. nLastKey = K_RIGHT .or. nLastKey = K_ESC
          lDone := .t.
          EXIT
   case  ( (bKeyBlock := SetKey(nLastKey)) <> NIL )
         Eval(bKeyBlock, "PULLDN", nil, aArray[nElement])

   endcase
ENDDO
return nLastKey

//-----------------------------------------------
static proc agoTop(nElement,oBrz)
local nTemp := nElement
while nTemp > 1
  oBrz:up()
  nTemp--
end
return
//-----------------------------------------------
static proc agoBot(nElement,nLen,oBrz)
local nTemp := nElement
while nTemp < nLen
  oBrz:down()
  nTemp++
end
while !oBrz:stabilize()
end
return

//===============================================================
static function agoto(nNew,nCurrent,oBrowz)
local nIter
local nDiff := ABS(nNew-nCurrent)
if nNew > nCurrent
  for nIter := 1 to nDiff
    oBrowz:down()
    while !oBrowz:stabilize()
    end
  next
else
  for nIter := 1 to nDiff
    oBrowz:up()
    while !oBrowz:stabilize()
    end
  next
endif
return nil

//===============================================================
static function parsearrays(aInDef,aTitles,aBoxes)
local aAll,cPreMacro
local i
local cTFirst := ""
for i = 1 to len(aInDef)
  cPreMacro := "["+strtran(aIndef[i],":","],[")+"]"
  aAll      := &( "{"+cPreMacro+"}" )
  aadd(aTitles,aAll[1])
  cTFirst += left(aTitles[i],1)
  adel(aAll,1)
  asize(aAll,len(aAll)-1)
  aadd(aBoxes,aAll)
next
return ( cTFirst )



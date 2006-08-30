#include "inkey.ch"

FUNCTION mchoice(aOptions,nTop,nLeft,nBottom,nRight,cTitle,lAlpha,nStart,nRow)

LOCAL lAlphaSelects, cFirstLetters
LOCAL nIterator,nArrayLength
LOCAL cUnderScreen,nOldCursor
local nLastKey,cLastKey,nFound
local nElement := 1
local oTb

*- set cursor off
nOldCursor   := setcursor(0)
nArrayLength := aleng(aOptions)
dodim(@nTop,@nLeft,@nBottom,@nRight,aOptions)

if valtype(cTitle)=="C"
    if len(cTitle) > ((nRight-nLeft)-1)
        cTitle = left(cTitle,nRight-nLeft-1)
    endif
endif

IF nArrayLength> 0
  cFirstLetters := ''
  FOR nIterator = 1 TO nArrayLength
    cFirstLetters += UPPER(LEFT(aOptions[nIterator],1))
  NEXT
  
  lAlphaSelects := iif(lAlpha#nil,lAlpha,.f.)
  
  *- figure out the box dimensions and draw it
  nBottom       := MIN(nBottom,nArrayLength+nTop+1)
  cUnderScreen  :=makebox(nTop,nLeft,nBottom,nRight,sls_popcol())
  @nTop,nLeft+1 SAY IIF(cTitle#nil,cTitle,'')
  oTb:= tBrowseNew(nTop+1,nLeft+1,nBottom-1,nRight-1)
  oTb:addcolumn(tbcolumnNew(nil,{||aOptions[nElement]}))
  oTb:getcolumn(1):width := sbcols(nLeft,nRight,.f.)
  oTb:Skipblock  := {|n|aaskip(n,@nElement,len(aOptions))}
  oTb:goTopBlock := {||nElement := 1}
  oTb:goBottomBlock := {||nElement := len(aOptions)}

 if nStart#nil .and. nStart <= len(aOptions)
   if nRow#nil
     oTb:RowPos := nRow
     nElement := nStart
     oTb:configure()
   else
     bgoto(nStart,nElement,oTb)
   endif
 endif

  while .t.
    while !oTb:stabilize()
    end
    nLastKey := inkey(0)
    do case
    CASE nLastKey = K_UP          && UP ONE ROW
      if nElement > 1
        oTb:UP()
      else
        oTb:gobottom()
      endif
    CASE nLastKey = K_DOWN        && DOWN ONE ROW
      if nElement < len(aOptions)
        oTb:DOWN()
      else
        oTb:gotop()
      endif
    CASE nLastKey = K_PGUP        && UP ONE PAGE
      oTb:PAGEUP()
    CASE nLastKey = K_HOME        && HOME
      oTb:GOTOP()
    CASE nLastKey = K_PGDN        && DOWN ONE PAGE
      oTb:PAGEdOWN()
    CASE nLastKey = K_END         && END
      oTb:GOBOTTOM()
    CASE nLastKey = K_ENTER       && ENTER
      exit
    CASE nLastKey = K_ESC
      nElement := 0
      EXIT
    case (cLastKey:=upper(chr(nLastkey)))$cFirstLetters
        IF cLastkey==upper(left(aOptions[nElement],1)) .and. lAlphaSelects
          exit
        else
          nFound := at(cLastKey,subst(cFirstLetters,nElement+1))
          nFound := iif(nFound> 0,nFound+nElement,nFound)
          if nFound==0 .and. nElement > 1
            nFound := at(cLastKey,cFirstLetters)
          endif
          if nFound > 0
            if nFound<>nElement
              bgoto(nFound,nElement,oTb)
            endif
            if lAlphaSelects
              exit
            endif
          endif
        endif
    endcase
  end
  unbox(cUnderScreen)
else
   nElement := 0
ENDIF
SETCURSOR(nOldCursor)
nRow := oTb:rowpos
RETURN nElement

//===============================================================
static function bgoto(nNew,nCurrent,oTb)
local nIter
local nDiff := ABS(nNew-nCurrent)
dispbegin()
if nNew > nCurrent
  for nIter := 1 to nDiff
    oTb:down()
    while !oTb:stabilize()
    end
  next
else
  for nIter := 1 to nDiff
    oTb:up()
    while !oTb:stabilize()
    end
  next
endif
dispend()
return nil


//--------------------------------------------------------------
static func findbigest(aItems)
local aBiggest := 0
local i
for i = 1 to len(aItems)
  aBiggest := max(aBiggest,len(trans(aItems[i],"")))
next
return aBiggest


//--------------------------------------------------------------
static function dodim(nTop,nLeft,nBottom,nRight,aItems)
local nLongest := findbigest(aItems)
if nTop==nil.or.nLeft==Nil
  nTop     := 0
  nLeft    := 0
  nBottom  := min(len(aItems)+2,maxrow())
  nRight   := min(nLongest+2,maxcol())
  sbcenter(@nTop,@nLeft,@nBottom,@nRight)
elseif nBottom==nil .or. nRight==nil
  nBottom  := min(nTop+len(aItems)+2,maxrow())
  nRight   := min(nLeft+nLongest+2,maxcol())
endif
nBottom    := min(nBottom,nTop+len(aItems)+2)
return nLongest


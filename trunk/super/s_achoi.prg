#include "inkey.ch"
function sachoice(nTop,nLeft,nBottom,nRight,aOptions,bKeyBlock,nStart,nRow)

LOCAL lAlphaSel, cFirst
LOCAL nIterator
LOCAL nLastKey,cLastKey,nFound
local nElement := 1
local oTb
nStart := iif(nStart#nil,nStart,1)

IF len(aOptions)> 0
  cFirst := ''
  FOR nIterator = 1 TO len(aOptions)
    if valtype(aOptions[nIterator])=="C"
      cFirst += UPPER(LEFT(aOptions[nIterator],1))
    else
      cFirst += chr(32)
    endif
  NEXT

  oTb:= tBrowseNew(nTop,nLeft,nBottom,nRight)
  oTb:addcolumn(tbcolumnNew(nil,{||aOptions[nElement]}))
  oTb:getcolumn(1):width := min(findbigest(aOptions),sbcols(nLeft,nRight,.f.) )
  oTb:Skipblock     := {|n|aaskip(n,@nElement,len(aOptions))}
  oTb:goTopBlock    := {||nElement := 1}
  oTb:goBottomBlock := {||nElement := len(aOptions)}

  if nStart#nil .and. nStart <= len(aOptions)
    if nRow#nil
      oTb:RowPos := nRow
      nElement   := nStart
      oTb:configure()
    else
      bgoto(nStart,nElement,oTb)
    endif
  endif
  while .t.
    dispbegin()
    while !oTb:stabilize()
    end
    dispend()
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
      oTb:PAGEDOWN()
    CASE nLastKey = K_END         && END
      oTb:GOBOTTOM()
    CASE nLastKey = K_ENTER       && ENTER
      exit
    CASE nLastKey = K_ESC
      nElement := 0
      EXIT
    case (cLastKey:=upper(chr(nLastkey)))$cFirst .and. cLastkey#chr(32)
      nFound := at(cLastKey,subst(cFirst,nElement+1))
      nFound := iif(nFound> 0,nFound+nElement,nFound)
      if nFound==0 .and. nElement > 1
        nFound := at(cLastKey,cFirst)
      endif
      if nFound > 0
        if nFound<>nElement
          bgoto(nFound,nElement,oTb)
        endif
      endif
    case SETKEY(nLastkey)#nil
      eval( SETKEY(nLastkey),procname(1),procline(1),readvar() )
    case bKeyBlock#nil
      eval(bKeyBlock,nElement,nLastkey,oTb)
    endcase
  end
ENDIF
nrow := oTb:rowpos
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


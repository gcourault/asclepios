static nElement

#include "inkey.ch"
function browse2d(nTop,nLeft,nBottom,nRight,aArr,aHead,cColor,cTitle,bExcept)
local nColumn,nLastKey
local cBox,oTb,lHeaders
local nReturn

dispbegin()
cColor  := iif(cColor#nil,cColor,sls_popcol())
cTitle  := iif(ctitle#nil,cTitle,"")
cBox    := makebox(nTop,nLeft,nBottom,nRight,cColor)
lHeaders:= aHead#nil
aHead   := iif(aHead#nil,aHead,array(len(aArr[1])) )
oTb     := tbrowsenew(nTop+1,nLeft+1,nBottom-1,nRight-1)
if lHeaders
  oTb:headsep := "Ä"
endif
oTb:colsep := "³"

nElement    := 1
@nTop,nLeft+1 say cTitle

for nColumn = 1 to len(aArr[1])
  oTb:addColumn(TBColumnNew(aHead[nColumn],makeblock(aArr,nColumn)))
  oTb:getcolumn(nColumn):width := findbigest(aArr,nColumn,aHead)
next
oTb:skipblock       := {|n|aaskip(n,@nElement,len(aArr))}
oTb:gobottomblock   := {||nElement := len(aArr)}
oTb:gotopblock      := {||nElement := 1}

dispend()
while .t.
  while !oTb:stabilize()
  end
  nLastkey := inkey(0)
  do case
  case nLastkey == K_UP
    oTb:up()
  case nLastkey == K_DOWN
    oTb:down()
  case nLastkey == K_PGUP
    oTb:pageup()
  case nLastkey == K_PGDN
    oTb:pagedown()
  case nLastkey == K_LEFT
    oTb:left()
  case nLastkey == K_RIGHT
    oTb:right()
  case nLastkey == K_HOME
    oTb:gotop()
  case nLastkey == K_END
    oTb:gobottom()
  case nLastkey == K_ENTER
    exit
  case nLastkey == K_ESC
    nElement := 0
    exit
  case bExcept#nil
    eval(bExcept,nLastKey,oTb,nElement)
  endcase
end
unbox(cBox)
nReturn  := nElement
nElement := nil
return nReturn


static function makeblock(a,i)
return {||a[nElement,i]}


//--------------------------------------------------------------
static func findbigest(aItems,nElement,aHead)
local aBiggest := 0
local i
for i = 1 to len(aItems)
  aBiggest := max(aBiggest,len(trans(aItems[i,nElement],"")))
next
if aHead[nElement]#nil
  aBiggest := max(aBiggest,len(trans(aHead[nElement],"")))
endif
return aBiggest




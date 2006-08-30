#include "inkey.ch"
//--------------------------------------------------------------
function aMsg(aMsgs,cTitle,cFooter,lCenter,cColor,nTop,nLeft,nBottom,nRight)
local cBox,oTb
local nMessage := 1
local nLongest
local nLastKey

if aMsgs#nil .and. valtype(aMsgs)=="A"
  cColor := iif(cColor#nil,cColor,sls_popcol())
  cTitle := iif(cTitle#nil,cTitle,"")
  cFooter := iif(cFooter#nil,cFooter,"Pulse una tecla ...")
  lCenter := iif(lCenter#nil,lCenter,.f.)
  nLongest := dodim(@nTop,@nLeft,@nBottom,@nRight,aMsgs,cFooter)
  nLongest := MAX(nLongest,sbcols(nLeft,nRight,.f.))
  nLongest := MAX(nLongest,19)
  cBox := makebox(nTop,nLeft,nBottom,nRight,cColor)
  @nTop,nLeft+1 say ctitle
  @nBottom,nLeft+1 say cFooter
  oTb  := tbrowsenew(nTop+1,nLeft+1,nBottom-1,nRight-1)
  if lCenter
    oTb:addcolumn(tbcolumnNew(nil,{||ampadc(aMsgs[nMessage],nLongest)}))
  else
    oTb:addcolumn(tbcolumNnew(nil,{||ampadr(aMsgs[nMessage],nLongest)}))
  endif
  oTb:skipblock := {|n|aaskip(n,@nMessage,len(aMsgs))}
  while .t.
     while !oTb:stabilize()
     end
     nLastKey := inkey(0)
     do case
     case nLastkey == K_UP
       oTb:up()
     case nLastkey == K_DOWN
       oTb:down()
     otherwise
       exit
     endcase
  end
  unbox(cBox)
endif
return nil

//--------------------------------------------------------------
static function dodim(nTop,nLeft,nBottom,nRight,aMsgs,cFooter)
local aLongest := findbigest(aMsgs)
if nTop==nil.or.nLeft==Nil.or.nBottom==nil.or.nRight==nil
   nTop     := 0
   nLeft    := 0
   nBottom  := min(len(aMsgs)+2,maxrow())
   nRight   := min(aLongest+2,maxcol())
   nright   := max(nRight,len(cFooter)+2)
   sbcenter(@nTop,@nLeft,@nBottom,@nRight)
endif
return aLongest

//--------------------------------------------------------------
static func findbigest(aMsgs)
local aBiggest := 0
local i
local cValtype
for i = 1 to len(aMsgs)
  cValtype := valtype(aMsgs[i])
  aBiggest := max(aBiggest,len(trans(aMsgs[i],"")))
next
return aBiggest

//--------------------------------------------------------------
static func ampadc(expVar,nWidth)
if valtype(expVar)=="L"
  return PADC(IIF(expVar,"Si","No"),nWidth)
endif
return PADC(expVar,nWidth)

//--------------------------------------------------------------
static func ampadr(expVar,nWidth)
if valtype(expVar)=="L"
  return PADR(IIF(expVar,"Si","No"),nWidth)
endif
return PADR(expVar,nWidth)


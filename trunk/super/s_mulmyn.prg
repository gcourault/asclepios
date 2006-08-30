#include "inkey.ch"
FUNCTION MULTIMSGYN(aMsgs,cYes,cNo,cColor,cTitle,lCenter,nTop,nLeft)
local cBox,oTb
local nMessage := 1
local nLongest
local nLastKey
local aPrompts
local cHi,cLo
local nYesNo := 1
local nOldYN := 2
local nBottom,nRight

if aMsgs#nil .and. valtype(aMsgs)=="A"
  cColor := iif(cColor#nil,cColor,sls_popcol())
  cLo    := takeout(cColor,",",1)
  cHi    := takeout(cColor,",",2)
  cTitle := iif(cTitle#nil,cTitle,"")
  lCenter := iif(lCenter#nil,lCenter,.f.)
  cYes    := iif(cYes#nil,cYes,"Si")
  cNo     := iif(cNo #nil,cNo ,"No ")

  nLongest := dodim(@nTop,@nLeft,@nBottom,@nRight,aMsgs,cYes,cNo)

  nLongest := MAX(nLongest,sbcols(nLeft,nRight,.f.))

  aPrompts := getprompts(cYes,cNo,nLeft,nRight)

  cBox := makebox(nTop,nLeft,nBottom,nRight,cColor)

  @nTop,nLeft+1 say ctitle

  oTb  := tbrowsenew(nTop+1,nLeft+1,nBottom-2,nRight-1)
  if lCenter
    oTb:addcolumn(tbcolumnNew(nil,{||ampadc(aMsgs[nMessage],nLongest)}))
  else
    oTb:addcolumn(tbcolumNnew(nil,{||ampadr(aMsgs[nMessage],nLongest)}))
  endif
  oTb:skipblock := {|n|aaskip(n,@nMessage,len(aMsgs))}
  oTb:colorspec := cLo+","+cLo

  while .t.
     dispbegin()
     @nBottom-1,aPrompts[nOldYN,1] say aPrompts[nOldYN,2] color cLo
     nOldYn := nYesNo
     while !oTb:stabilize()
     end
     @nBottom-1,aPrompts[nYesNo,1] say aPrompts[nYesNo,2] color cHi
     dispend()
     nLastKey := inkey(0)
     do case
     case nLastkey == K_UP
       oTb:up()
     case nLastkey == K_DOWN
       oTb:down()
     case nLastkey == K_LEFT .or. nLastKey == K_RIGHT
       nYesNo := iif(nYesNo == 1,2,1)
     case nLastKey == K_ENTER
       exit
     case nLastKey == K_ESC
       nYesNo := 0
       exit
     otherwise
       exit
     endcase
  end
  unbox(cBox)
endif
return (nYesNo == 1)

//--------------------------------------------------------------
static function dodim(nTop,nLeft,nBottom,nRight,aMsgs,cYes,cNo)
local nLongest := findbigest(aMsgs)
nLongest := max(nLongest,len(cYes+cNo)+1)
if nTop==nil.or.nLeft==Nil
  nTop     := 0
  nLeft    := 0
  nBottom  := min(len(aMsgs)+3,maxrow())
  nRight   := min(nLongest+2,maxcol())
  sbcenter(@nTop,@nLeft,@nBottom,@nRight)
else
  nBottom  := nTop+min(len(aMsgs)+3,maxrow())
  nRight   := nLeft+min(nLongest+2,maxcol())
endif
return nLongest

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
else
  return PADC(expVar,nWidth)
endif
return nil

//--------------------------------------------------------------
static func ampadr(expVar,nWidth)
if valtype(expVar)=="L"
  return PADR(IIF(expVar,"Si","No"),nWidth)
else
  return PADR(expVar,nWidth)
endif
return nil

//--------------------------------------------------------------
static function getprompts(cYes,cNo,nLeft,nRight)
local nCols    := nRight-nLeft-1
local nPadding := INT((nCols-len(cYes+cNo))/3)
return {{nLeft+nPadding+1,cYes},{nLeft+nPadding+1+len(cYes)+nPadding+1,cNo}}


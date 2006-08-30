#include "inkey.ch"
FUNCTION vertview(aFields,aFDescr,cColor,cTitle,cFooter)
local cBox,oTb
local nField := 1
local nValuesLen,nDescLen
local aValues,i
local nTop,nLeft,nBottom,nRight
local cMemobox,nLastKey
cColor := iif(cColor#nil,cColor,sls_popcol())
cTitle := iif(cTitle#nil,cTitle,"")
cFooter:= iif(cFooter#nil,cFooter,"ESCAPE to quit")
if aFields==nil.or.aFDescr==nil
  aFields := afieldsx()
  aFdescr := afieldsx()
endif
aValues := array(len(aFields))
nDescLen   := bigelem(aFDescr)+1
for i = 1 to  len(aValues)
  aValues[i] := padr(aFdescr[i],nDescLen)+ aMacro(aFields[i])
next

nValuesLen := bigelem(aValues)

nTop    := 0
nLeft   := 0
nBottom := min(len(aFields)+1,maxrow()-1)
nRight  := min(maxcol()-1,nValuesLen+1)
sbcenter(@nTop,@nLeft,@nBottom,@nRight)
nValuesLen := sbcols(nLeft,nRight,.f.)

cBox := makebox(ntop,nLeft,nBottom,nRight,cColor)
@nTop,nLeft+1 say cTitle
@nBottom,nLeft+1 say cFooter
oTb  := tbrowsenew(nTop+1,nLeft+1,nBottom-1,nRight-1)
oTb:addcolumn(tbcolumNnew(nil,{||padr(aValues[nField],nValuesLen) }   ))
oTb:skipblock := {|n|aaskip(n,@nField,len(aValues))}
while .t.
   while !oTb:stabilize()
   end
   nLastKey := inkey(0)
   do case
   case nLastkey == K_UP
     oTb:up()
   case nLastkey == K_DOWN
     oTb:down()
   case nLastkey == K_PGUP
     oTb:pageup()
   case nLastkey == K_PGDN
     oTb:pagedown()
   case nLastkey == K_ENTER .and. "(memo - Enter"$aValues[nField]
       cMemoBox := makebox(ntop,nLeft,nBottom,nRight,cColor)
       @ntop,nLeft+1 SAY '[VIENDO CAMPO MEMO : '+aFDescr[nField]+"]"
       @nbottom,nLeft+1 say ' Pulse ESCAPE para salir]'
       Memoedit(HARDCR(&(aFields[nField])),nTop+1,nLeft+1,nbottom-1,nright-1,.F.,'',200)
       unbox(cMemoBox)
   case nLastkey == K_ESC
     exit
   endcase
end
unbox(cBox)
return nil

//--------------------------------------------------------------
static function aMacro(expThis)
local expValue := &(expThis)
if valtype(expValue)=="C" .and. (chr(13)$expValue .or. chr(141)$expValue)
  return "(memo - Enter to View)"
else
  return trans(&(expThis),"")
endif
return nil


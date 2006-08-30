#include "inkey.ch"
// browsesdf("test.sdf",{"First","Last","Date","Buyer"},{"C","C","D","L"},{15,20,8,3})

function browseSDF(cFile,aDesc,aTypes,aLens)
local cThisLine,nLastKey
local i,oTb,cInScreen
local nHandle := fopen(cFile,64)
local nTop    := 3
local nLeft   := 5
local nBottom := 22
local nRight  := 75
IF Ferror() <> 0
  msg("Error abriendo archivo : "+cFile)
  RETURN ''
ENDIF
cInscreen := makebox(nTop,nLeft,nBottom,nRight,sls_normcol())
@nTop,nLeft+1 say "[Mostrar archivo SDF]"
@nBottom-2,nLeft+1 to nBottom-2,nRight-1
@nBottom-1,nLeft+1 say padc("Usar "+chr(24)+chr(25)+chr(26)+chr(27)+",  ESCAPE o ENTER para salir",nRight-nLeft-1)

oTb := tbrowsenew(nTop+1,nLeft+1,nBottom-3,nRight-1)
for i = 1 to len(aTypes)
  oTb:addcolumn(tbcolumnnew(aDesc[i],;
                makedblock(i,aTypes,aLens,nHandle) ))
next

oTb:skipblock     := {|n|tskip(n,nHandle)}
oTb:gotopblock    := {||ftop(nHandle)}
oTb:gobottomblock := {||fbot(nHandle)}
oTb:headsep := "Ä"
oTb:colsep := "³"

while .T.
  DISPBEGIN()
  while !oTb:stabilize()
  end
  DISPEND()
  nLastKey := inkey(0)
  do case
  case nLastKey == K_UP
    oTb:UP()
  case nLastKey == K_DOWN
    oTb:down()
  case nLastKey == K_PGUP
    oTb:PAGEUP()
  case nLastKey == K_PGDN
    oTb:PAGEdown()
  case nLastKey == K_HOME
    oTb:gotop()
  case nLastKey == K_END
    oTb:gobottom()
  case nLastKey == K_LEFT
    oTb:left()
  case nLastKey == K_RIGHT
    oTb:right()
  case nLastKey == K_ENTER .or. nLastKey == K_ESC
    exit
  endcase
end
fclose(nHandle)
unbox(cInscreen)
return nil

//--------------------------------------------------------------------------
static FUNCTION fbot(nHandle)
FSEEK(nHandle,0,2)
RETURN ''

//--------------------------------------------------------------------------
static FUNCTION ftop(nHandle)
FSEEK(nHandle,0)
RETURN ''

//--------------------------------------------------------------
static function tskip(n,nHandle)
local nMoved   := 0
if n > 0
  while nMoved < n
    if fmove2next(nHandle)
      nMoved++
    else
      exit
    endif
  end
elseif n < 0
  while nMoved > n
    if fmove2prev(nHandle)
      nMoved--
    else
      exit
    endif
  end
endif
return nMoved

//--------------------------------------------------------------------------
static function makedblock(i,aTypes,aLens,nHandle)
local bBlock
local nStart := 0
local nLen
for nLen = 1 to i-1
  nStart += aLens[nLen]
next
nStart += 1
do case
case aTypes[i]=="C"
  bBlock := {||padr(subst(sfreadline(nHandle),nStart,aLens[i]),aLens[i])  }
case aTypes[i]=="N"
  bBlock := {||padl(subst(sfreadline(nHandle),nStart,aLens[i]),aLens[i]) }
case aTypes[i]=="D"
  bBlock := {||stod(subst(sfreadline(nHandle),nStart,8)) }
case aTypes[i]=="L"
  bBlock := {||iif(subst(sfreadline(nHandle),nStart,1)=="T",.t.,.f.) }
endcase
return bBlock


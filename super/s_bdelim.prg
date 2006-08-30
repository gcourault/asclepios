#include "inkey.ch"
// browsedelim("test.asc",{"First","Last","Buyer?","Date"},{"C","C","L","D"},{15,25,3,8})

function browsedelim(cFile,aDesc,aTypes,aLens,cFieldDel,cCharDel)
local cThisLine,nLastKey
local i,oTb,cInScreen
local nHandle := fopen(cFile,64)
local nTop    := 3
local nLeft   := 5
local nBottom := 22
local nRight  := 75
IF Ferror() <> 0
  msg("Error opening file : "+cFile)
  RETURN ''
ENDIF
cFieldDel := iif(cFieldDel#nil,cfieldDel,",")
cCharDel := iif(cCharDel#nil,cCharDel,["])
cInscreen := makebox(nTop,nLeft,nBottom,nRight,sls_normcol())
@nTop,nLeft+1 say "[Delimited file Browse]"
@nBottom-2,nLeft+1 to nBottom-2,nRight-1
@nBottom-1,nLeft+1 say padc("Use "+chr(24)+chr(25)+chr(26)+chr(27)+",  ESCAPE or ENTER when done",nRight-nLeft-1)

oTb := tbrowsenew(nTop+1,nLeft+1,nBottom-3,nRight-1)
for i = 1 to len(aTypes)
  oTb:addcolumn(tbcolumnnew(aDesc[i],;
                makedblock(i,aTypes,aLens,cFieldDel,cCharDel,nHandle) ))
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
static function isfeof(nHandle)
local nOldPos := FSEEK(nHandle,0,1)
local lEof := (fseek(nHandle,0,2)==nOldPos)
fseek(nHandle,nOldPos)
return lEof

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
static function makedblock(i,aTypes,aLens,cFieldDel,cCharDel,nHandle)
local bBlock
do case
case aTypes[i]=="C"
  bBlock := {||cRemove(padr(takeout(sfreadline(nHandle),cFieldDel,i),aLens[i]),cCharDel)  }
case aTypes[i]=="N"
  bBlock := {||padl(takeout(sfreadline(nHandle),cFieldDel,i),aLens[i]) }
case aTypes[i]=="D"
  bBlock := {||stod(takeout(sfreadline(nHandle),cFieldDel,i)) }
case aTypes[i]=="L"
  bBlock := {||iif(takeout(sfreadline(nHandle),cFieldDel,i)=="T",.t.,.f.) }
endcase
return bBlock

//--------------------------------------------------------------------------
static function cremove(cStr,cKill)
return strtran(cStr,cKill,'')


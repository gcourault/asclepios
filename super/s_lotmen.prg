#include "inkey.ch"
static aCurrent
static nElement := 1
static aStack   := {}


FUNCTION SLOTUSMENU(nTop,nLeft,nbottom,nRight,aOptions,lBox,lSaveRest,lReset)
LOCAL oTb,cBox,nColumn
LOCAL nTbTop,nTbLeft,nTbBottom,nTbRight,nWidth
LOCAL expReturn := 0
LOCAL nLastkey,cLastkey,nFirstLetter


lBox      := iif(lBox#nil,lBox,.f.)
lSaveRest := iif(lSaveRest#nil,lSaveRest,.f.)
lReset    := iif(lReset#nil,lReset,.f.)
if lBox
  nBottom  := nTop+3
  nTbTop   := nTop+1
  nTbLeft  := nLeft+1
  nTbRight := nRight-1
else
  nBottom  := nTop+1
  nTbTop   := nTop
  nTbLeft  := nLeft
  nTbRight := nRight
endif
if lSaveRest
  if lBox
    cBox := Makebox(nTop,nLeft,nBottom,nRight)
  else
    cBox := Savescreen(nTop,nLeft,nBottom,nRight)
  endif
ELSEIF lBox
    Makebox(nTop,nLeft,nBottom,nRight)
endif
nWidth    := nTbRight-nTbLeft+1
if len(aStack)=0
  aCurrent  := aOptions
endif
oTb := BuildTb(nTbTop,nTbLeft,nTbTop,nTbRight,nWidth)
oTb:colpos := nElement

while .t.
  dispbegin()
  while !oTb:stabilize()
  end
  if aCurrent[oTb:colpos,2]#nil
    @nTbTop+1,nTbLeft say padr(aCurrent[oTb:colpos,2],nWidth)
  else
    scroll(nTbTop+1,nTbLeft,ntbTop+1,nTbRight,0)
  endif
  dispend()
  nLastKey := INKEY(0)
  do case
  case nLastKey == K_ENTER      //
    if valtype(aCurrent[oTb:colpos,3])=="A"
      aadd(aStack,{aCurrent,oTb:colpos})
      aCurrent := aCurrent[oTb:colpos,3]
      oTb := BuildTb(nTbTop,nTbLeft,nTbTop,nTbRight,nWidth)
      oTb:colpos := 1
    elseif valtype(aCurrent[oTb:colpos,3])=="B"
      eval(aCurrent[oTb:colpos,3])
    else
      expReturn := aCurrent[oTb:colpos,3]
      exit
    endif
  case nLastKey == K_ESC      // abort
    if len(aStack)>0
      aCurrent := atail(aStack)[1]
      oTb := BuildTb(nTbTop,nTbLeft,nTbTop,nTbRight,nWidth)
      oTb:colpos :=  atail(aStack)[2]
      aSize(aStack,len(aStack)-1)
    else
      exit
    endif
  case nLastKey == K_LEFT     // allow movement (left)
     IF oTb:colpos > 1
       oTb:left()
     ELSE
       oTb:colpos  := len(aCurrent)
       oTb:refreshall()
     ENDIF
  case nLastKey == K_RIGHT    // allow movement (right)
     IF oTb:colpos < len(aCurrent)
       oTb:right()
     ELSE
       oTb:colpos  := 1
       oTb:refreshall()
     ENDIF
  CASE (cLastkey := upper(chr(nLastkey)))$"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
     if cLastkey == upper(left(aCurrent[oTb:colpos,1],1))
       keyboard chr(13)
     elseif (nFirstLetter := ascan(aCurrent,{|e|e[1]#nil.and.upper(left(e[1],1))==cLastKey },oTb:colpos+1)) > 0 ;
        .or. (nFirstLetter := ascan(aCurrent,{|e|e[1]#nil.and.upper(left(e[1],1))==cLastKey },1,oTb:colpos)) > 0
       oTb:colpos  := nFirstLetter
       oTb:refreshall()
     endif

  endcase
end
nElement := oTb:colpos
if lSaveRest
  if lBox
    unbox(cBox)
  else
    restscreen(nTop,nLeft,nBottom,nRight,cBox)
  endif
endif
if lReset
  SLOTUSCLEAR()
endif
return expReturn

//----------------------------------------------------------------------
FUNCTION SLOTUSCLEAR
aStack := {}
nElement := 1
return nil

//-----------------------------------------------------------------
static function BuildTb(ntop,nLeft,nbottom,nRight,nWidth)
local oTb,nColumn
local ntotWidth := ttlwidth()
scroll(nTop,nLeft,nBottom,nRight,0)
if ntotWidth >= nWidth
  oTb := tbrowsenew(nTop,nLeft,nbottom,nRight)
else
  oTb := tbrowsenew(nTop,nLeft,nbottom,nLeft+nTotWidth-1)
endif
for nColumn = 1 to len(aCurrent)
  oTb:addcolumn(tbColumnNew(nil,makeblock(nColumn)))
next
otb:skipblock := {|n|0}
return oTb

//-----------------------------------------------------------------
static function makeblock(i)
return {||aCurrent[i,1]}


//-----------------------------------------------------------------
static function ttlwidth
local nWidth := 0
aeval(aCurrent,{|e|nWidth+=len(e[1])+1})
return nWidth



#include "inkey.ch"
FUNCTION RAT_MENU2(aOptions,nStart,lImmediate)
local cNormcolor   := takeout(Setcolor(),",",1)
local cEnhcolor    := takeout(Setcolor(),",",2)
local i,aThisOp
local aDims        := array(len(aOptions))
local nElement     := min(iif(nStart#nil,nStart,1),len(aOptions))
local nOldSel      := nElement
local nLastKey, nFound, nMrow,nMcol, nMouseFound
local cFirstLet    := ""
local cLastKey
lImmediate := iif(lImmediate#nil,lImmediate,.t.)
for i = 1 to len(aOptions)
   aThisOp := aOptions[i]
   @aThisOp[1], aThisOp[2] say aThisOp[3] color cNormColor
   aDims[i] := {aThisOp[1],aThisOp[2],aThisOp[1],aThisOp[2]+len(aThisOp[3])-1}
   cFirstLet += upper(left(aThisOp[3],1 ))
next

while .t.
   @aOptions[nOldSel,1],aOptions[nOldSel,2] say aOptions[nOldSel,3] color cNormColor
   nOldSel      := nElement
   @aOptions[nElement,1],aOptions[nElement,2] say aOptions[nElement,3] color cEnhColor
   nLastKey := rat_event(0)
   cLastKey := upper(chr(nLastKey))
   do case
   case nLastKey == 400  // left mouse
      nMrow := rat_eqmrow()
      nMcol := rat_eqmcol()
      if (nMouseFound := ascan(aDims,{|d|d[1]==nMrow .and.;
           (d[2] <=nMcol .and. d[4] >=nMcol ) })) > 0
           nElement := nMouseFound
           if lImmediate .or. nElement==nOldSel
             keyboard chr(13)
           endif
      endif
   case nLastKey = K_LEFT .or. nLastkey==K_UP
      nElement := IIF(nElement=1,len(aOptions),nElement-1)
   case nLastKey = K_RIGHT .or. nLastKey == K_DOWN
      nElement := IIF(nElement=len(aOptions),1,nElement+1)
   case cLastKey$cFirstLet
      if (nFound := AT(cLastKey,subst(cFirstLet,nElement)) ) > 0
        nElement := nFound+nElement-1
      else
        nElement := at(cLastKey,cFirstLet)
      endif
      if lImmediate .or. nElement==nOldSel
        keyboard chr(13)
      endif
   case nLastKey = K_ENTER
      exit
   case nLastKey = K_ESC
      nElement := 0
      exit
   endcase
end
return nElement


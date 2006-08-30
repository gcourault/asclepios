#include "inkey.ch"
function spoporder()
local nKey  := 0
local expRead
local nOldOrder := indexord()
local nRecord   := recno()
local lFound    := .f.
local aKeys := fillkeys()
nKey := mchoice(aKeys,5,15,5+len(aKeys)+2,65,"Seleccione Indice")
if nKey > 0
  set order to (nKey-1)
endif
return indexord()


static function fillkeys
local aKeys := {"<Orden Natural (registros)>" }
local i := 1
while !empty(indexkey(i))
  aadd(aKeys,indexkey(i))
  i++
end
return aKeys


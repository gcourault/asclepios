#include "inkey.ch"
function spopseek(aKeys)
local nKey  := 0
local expRead
local nOldOrder := indexord()
local nRecord   := recno()
local lFound    := .f.
aKeys := iif(aKeys#nil,aKeys,fillkeys())
if len(aKeys) > 1
   nKey := mchoice(aKeys,5,15,5+len(aKeys)+2,65,"Seleccione un Indice")
elseif len(aKeys)==1
   nKey := 1
else
   msg("No hay Indices abiertos")
endif
if nKey > 0
  expRead := eval( &("{||"+aKeys[nKey]+"}") )
  popread(.t.,"Seek value:",@expRead,"@K")
  if lastkey()<>K_ESC .and. !empty(expRead)
     IF VALTYPE(expRead)=="C"
       expRead := trim(expRead)
     endif
     set order to (nKey)
     seek expRead
     lFound := found()
     if !found()
       msg("No se encontr¢")
       go nRecord
     endif
  endif
endif
set order to (nOldOrder)
return lFound


static function fillkeys
local aKeys := {}
local i := 1
while !empty(indexkey(i))
  aadd(aKeys,indexkey(i))
  i++
end
return aKeys


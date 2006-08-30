*- first param MUST be an array now
FUNCTION bldarr(aArray,nArrayLength,cInString)
local cNextElement,nIterator
asize(aArray,nArrayLength)
FOR nIterator = 1 TO nArrayLength
  cNextElement      := takeout(cInString,":",nIterator)
  aArray[nIterator] := cNextElement
NEXT
return nil


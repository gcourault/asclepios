FUNCTION akount(aArray,expValue)
local nIterator
local nMatchKount  := 0
local cTypeNeeded  := VALTYPE(expValue)
local narrayLength := aleng(aArray)
for nIterator = 1 TO narrayLength
  IF VALTYPE(aArray[nIterator])==cTypeNeeded
    IF aArray[nIterator] == expValue
      nMatchKount++
    ENDIF
  ENDIF
NEXT
RETURN nMatchKount


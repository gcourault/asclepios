FUNCTION trueval(cInString)
local nIter,cThisLetter
local nLenString := LEN(cInString)
local cOutValue := ''
for nIter = 1 TO nLenString
  cThisLetter := SUBST(cInString,nIter,1)
  IF cThisLetter$"0123456789."
    cOutValue += cThisLetter
  ENDIF
NEXT
RETURN VAL(cOutValue)
*: EOF: S_TRUEVA.PRG


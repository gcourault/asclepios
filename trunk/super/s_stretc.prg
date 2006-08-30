FUNCTION stretch(cInString,cImbedChar,nFrequency)
local nIter,nLenString,cOutString
cOutString := ''
nLenString := LEN(cInString)
for nIter = 1 TO nLenString-nFrequency STEP nFrequency
  cOutString += ( SUBST(cInString,nIter,nFrequency)+cImbedChar )
NEXT
cOutString += ( SUBST(cInString,nIter) )
RETURN cOutString


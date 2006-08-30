FUNCTION PROPER(cInString)
local nIter,cOutString,cThisChar,lCapNext

lCapNext   := .T.
cOutString := ''

*- loop for length of string
FOR nIter = 1 TO LEN(cInString)
  cThisChar  := SUBST(cInString,nIter,1)
  *- if its not alpha,cap the next alpha character
  IF !UPPER(cThisChar) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ'"
    lCapNext := .T.
  ELSE
    *- capitalise it or lower() it accordingly
    IF lCapNext
      cThisChar := UPPER(cThisChar)
      lCapNext  := .F.
    ELSE
      cThisChar := LOWER(cThisChar)
    ENDIF
  ENDIF
  *- add it to the cOutString
  cOutString += cThisChar
NEXT
RETURN cOutString

*: EOF: S_PROPER.PRG


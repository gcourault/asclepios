FUNCTION strpull(cInString,cDelim1,cDelim2)
local cOutString,nAt1,nAt2
IF EMPTY(cDelim1) .AND. !(" "==cDelim1)
  cInString := "±"+cInString
  cDelim1   := "±"
ENDIF
IF EMPTY(cDelim2) .AND. !(" "==cDelim2)
  cInString := cInString+"²"
  cDelim2   := "²"
ENDIF
nAt1  := AT(cDelim1,cInString)
cOutString := ''
IF nAt1 > 0
  nAt1 := nAt1+len(cDelim1)
  nAt2 :=AT(cDelim2,SUBST(cInString,nAt1))
  IF nAt2 > 0
    nAt2 := nAt2+nAt1-1
    IF (nAt2-nAt1) > 0
      cOutString := SUBST(cInString,nAt1,(nAt2-nAt1))
    ENDIF
  ENDIF
ENDIF
RETURN cOutString
*: EOF: S_STRPUL.PRG


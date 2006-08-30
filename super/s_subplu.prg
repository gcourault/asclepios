FUNCTION subplus(cInstring,nStart1,nChars1,nStart2,nChars2,;
                 nStart3,nChars3,nStart4,nChars4)
local nIter
local cOutString := ''
IF nStart1#nil .and. nChars1#nil
  cOutString += ( SUBST(cInstring,nStart1,nChars1))
ENDIF
IF nStart2#nil .and. nChars2#nil
  cOutString += ( SUBST(cInstring,nStart2,nChars2))
ENDIF
IF nStart3#nil .and. nChars3#nil
  cOutString += (SUBST(cInstring,nStart3,nChars3))
ENDIF
IF nStart4#nil .and. nChars4#nil
  cOutString += ( SUBST(cInstring,nStart4,nChars4))
ENDIF
RETURN cOutString
*: EOF: S_SUBPLU.PRG


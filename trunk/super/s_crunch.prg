FUNCTION crunch(cInstring,nAllorSingle)
local nIterator
local nStringLen := LEN(cInstring)
cInstring        := Alltrim(cInstring)
IF nAllorSingle = 0 // crunch out all spaces
  cInstring := STRTRAN(cInstring," ","")
ELSE  // crunch out all but single spaces
  DO WHILE SPACE(2)$cInstring
    cInstring := STRTRAN(cInstring,SPACE(2),SPACE(1))
  ENDDO
ENDIF
RETURN padr(cInstring,nStringLen)


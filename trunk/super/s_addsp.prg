FUNCTION addspace(cString,nDesiredLength)
nDesiredLength := iif(nDesiredLength#nil,nDesiredLength,len(cString) )
RETURN SUBST(cString+REPL(' ',nDesiredLength-LEN(cString)),1,nDesiredLength)


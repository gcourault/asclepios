FUNCTION arrange(cInstring,nStart,nHowmany,nNewPosition)
LOCAL nStringLength := LEN(cInstring)
LOCAL cExtraction   := SUBST(cInstring,nStart,nHowmany)
cInstring     := STUFF(cInstring,nStart,nHowmany,"")
cInstring     := STUFF(cInstring,nNewPosition,0,cExtraction)
RETURN cInstring


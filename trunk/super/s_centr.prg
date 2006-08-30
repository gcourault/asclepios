FUNCTION centr(cInstring,nPadWidth)
nPadwidth := iif(nPadWidth#nil,nPadWidth,len(cInString))
return PADC(alltrim(cInstring),nPadWidth)


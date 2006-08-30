function att(nTop,nLeft,nBottom,nRight,nAttribute)
local nLength := (nRight-nLeft+1)*(nBottom-nTop+1)
local cSaved  := SaveScreen(nTop,nLeft,nBottom,nRight)
* restscreen(nTop,nLeft,nBottom,nRight,;
*          trans(cSaved,REPL("X"+chr(nAttribute),nLength)))
restscreen(nTop,nLeft,nBottom,nRight,;
          cSaved)
return cSaved


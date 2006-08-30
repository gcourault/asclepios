function viewmemos(nTop,nLeft,nBottom,nRight,cColor)
local aMemos := aFieldsType("M")
local nChoice,cMemoBox
if len(aMemos) > 0
     nChoice = 1
     IF len(aMemos) > 1
       nChoice := mchoice(aMemos,2,15,3+len(aMemos),26,"¨Cu l memo?:")
     ENDIF
     if nChoice > 0
       if !(nTop#nil .and. nLeft#nil .and. nBottom#nil .and. nRight#nil)
         nTop    := 2
         nLeft   := 15
         nBottom := 22
         nRight  := 65
       endif
       cColor := iif(cColor#nil,cColor,sls_popcol())
       cMemoBox := makebox(ntop,nLeft,nBottom,nRight,cColor)
       @ntop,nLeft+1 SAY '[VIENDO CAMPOS MEMO: '+aMemos[nChoice]+"]"
       @nbottom,nLeft+1 say ' Pulse ESCAPE para salir]'
       Memoedit(HARDCR(fieldget(fieldpos(aMemos[nChoice]))),nTop+1,nLeft+1,nbottom-1,nright-1,.F.,'',200)
       unbox(cMemoBox)
     endif
ELSE
  msg("No se detectarn Campos Memo","")
endif
return nil


FUNCTION Sadd_rec(nTries, lAskMore, cAskMessage)
local nOrigTries, lReturn
nTries      := iif(nTries#nil,nTries,5)
lAskMore    := iif(lAskMore#nil,lAskMore,.f. )
cAskMessage := iif(cAskMessage#nil,cAskMessage,"No se puede agregar registro. ¨Reintenta?" )
nOrigTries  := nTries
lReturn     := .f.
WHILE nTries > 0
      APPEND BLANK
      if !NETERR()
         lReturn := .t.
         exit
      endif
      nTries--
      if nTries = 0 .and. lAskMore
        if messyn(cAskMessage)
          nTries := nOrigTries
        endif
      else
        inkey(.5)
      endif
ENDDO
RETURN lReturn



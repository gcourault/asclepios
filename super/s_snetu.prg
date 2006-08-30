
FUNCTION SNET_USE(cDbfName, cAlias, lUseExclusive, nTries, lAsk, cMessage)
local nTriesOrig, lReturn
nTriesOrig := nTries
lReturn    := .f.
do while nTries > 0
        DBUSEAREA(nil,nil,cDbfName,cAlias,!lUseExclusive)
        if .not. NETERR()
           lReturn := .t.
           exit
        endif
        inkey(.5)
        nTries--
        if nTries = 0 .and. lAsk
          if messyn(cMessage)
            nTries := nTriesOrig
          endif
        endif
enddo
return lReturn


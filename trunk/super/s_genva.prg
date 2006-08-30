FUNCTION genval(_beetljoos_,expWhatSay)
local  lReturnval := .t.
*- test the condition. If its false, set returnval to .f., display the message

if valtype(_beetljoos_)=="C"
  IF .NOT. (&_beetljoos_)
    lReturnval :=.F.
    if valtype(expWhatSay)=="C"
      msg(expWhatSay)
    elseif valtype(expWhatSay)=="A"
      amsg(expWhatsay)
    endif
  ENDIF
elseif valtype(_beetljoos_)=="B"
  IF .NOT. eval(_beetljoos_)
    lReturnval :=.F.
    if valtype(expWhatSay)=="C"
      msg(expWhatSay)
    elseif valtype(expWhatSay)=="A"
      amsg(expWhatsay)
    endif
  ENDIF
endif

RETURN(lReturnval)
* EOF: S_GENVA.PRG


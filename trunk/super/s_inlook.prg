//-------------------------------------------------------------------------
FUNCTION ISINLOOK(expCurrent,nArea,bCompare,lBlankOk,cMsg)
local nThisArea := select()
local lFound := .f.
local expIndexKey
select (nArea)
expIndexKey := indexkey(0)
lBlankOk := iif(lBlankOk#nil,lBlankOk,.f.)
if empty(expCurrent) .and. !lBlankOk
  lFound := .f.
elseif bCompare#nil
  locate for expCurrent==eval(bCompare)
  lFound := found()
elseif INDEXORD() > 0
  if type(expIndexKey)==valtype(expCurrent)
    seek expCurrent
    lFound := found()
  endif
endif
select (nThisArea)
if !lFound .and. cMsg#nil
  msg(cMsg)
endif
return lFound


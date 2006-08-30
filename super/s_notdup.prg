//-------------------------------------------------------------------------
FUNCTION ISNOTDUP(expCurrent,nOrder,bCompare,lBlankOk,nExceptRec,cMsg)
local nThisrecord := recno()
local lFound := .t.
local nOldOrder := INDEXORD(0)
local cOldFilter := DBFILTER()
local expIndexKey := indexkey(0)
if valtype(nExceptRec)=="N"
  SET FILTER TO RECNO()#nExceptRec
endif
if valtype(nOrder)=="N"
  set order to (nOrder)
endif
lBlankOk := iif(lBlankOk#nil,lBlankOk,.f.)
if empty(expCurrent) .and. !lBlankOk
  lFound := .f.
elseif bCompare#nil  // must be a locate
  set order to 0
  go top
  locate for expCurrent==eval(bCompare)
  lFound := found()
elseif INDEXORD() > 0
  if type(expIndexKey)==valtype(expCurrent)
    seek expCurrent
    lFound := found()
  endif
endif
if lFound .and. cMsg#nil
  msg(cMsg)
endif
SET ORDER TO (nOldOrder)
go (nThisRecord)
if !empty(cOldFilter)
  set filter to &cOldFilter
else
  set filter to
endif
return !(lFound)


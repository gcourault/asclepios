//---------------------------------------------------------------------
function blankfield(cField)
local cType := fieldtypex(cField)
local cLen := fieldlenx(cField)
do case
case cType = "C"
  return space(cLen)
case cType = "M"
  return ""
case cType = "N"
  return 0
case ctype = "L"
  return .f.
case cType = "D"
  return CTOD("  /  /  ")
endcase
return nil

//---------------------------------------------------------------------
function blankrec(nTries,lInteract,cMessage)
local i
local lSuccess := .f.
nTries      := iif(nTries#nil,nTries,5)
lInteract   := iif(lInteract#nil,lInteract,.f.)
cMessage    := iif(cMessage#nil,cMessage,"Unable to lock record. Keep trying?")
if SREC_LOCK(nTries,lInteract,cMessage)
  for i = 1 to fcount()
   fieldput(i,blankfield(field(i)))
  next
  lSuccess := .t.
  unlock
endif
return lSuccess

//---------------------------------------------------------------------
function isblankrec
local i
local lIsblank := .t.
for i = 1 to fcount()
  if !empty(fieldget(i))
    lIsblank := .f.
    exit
  endif
next
return lIsBlank



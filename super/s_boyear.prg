FUNCTION BOYEAR(dInDate)
local dReturn
local nSaveDate := SET_DATE(1)
dInDate := iif(valtype(dInDate)<>"D",date(),dInDate)
dReturn := CTOD("01/01/"+ right(TRANS(YEAR(dInDate),"9999"),2)  )
SET_DATE(nSaveDate)
return dReturn


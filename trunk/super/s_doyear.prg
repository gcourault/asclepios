FUNCTION doyear(dInDate)
local nOldDate, nReturn
nOldDate := SET_DATE(1)
nReturn  :=  dInDate- CTOD("01/01/"+RIGHT(DTOC(dInDate),2)) +1
SET_DATE(nOldDate)
RETURN nReturn


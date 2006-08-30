FUNCTION bom(dInDate)
local nPrevDateFormat  := SET_DATE(1)
local dReturn          := CTOD(TRANSFORM(MONTH(dInDate),'99')+"/01/"+;
                          TRANSFORM(YEAR(dInDate),'9999'))
SET_DATE(nPrevDateFormat)
return dReturn


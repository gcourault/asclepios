FUNCTION SETCENT(lCentury)
local lOld
lOld = (LEN(DTOC(DATE()))==10)
if lCentury#nil
 SET CENTURY (lCentury)
endif
return lOld


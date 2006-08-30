FUNCTION woyear(dDate)
local nDayOfYear := DOYEAR(dDate)
RETURN INT(nDayOfYear/7)+IIF(nDayOfYear%7>0,1,0)


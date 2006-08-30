FUNCTION womonth(dDate)
local nDayOfMonth := DAY(dDate)
RETURN INT(nDayOfMonth/7)+IIF(nDayOfMonth%7>0,1,0)


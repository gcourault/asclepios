FUNCTION Stod(cStringDate)
local nSaveDaveFormat := SET_DATE(1)
local dReturnDate     := CTOD(SUBSTR(cStringDate,5,2)+'/';
                       +SUBSTR(cStringDate,7,2)+'/';
                       +SUBSTR(cStringDate,1,4))
SET_DATE(nSaveDaveFormat)
RETURN dReturnDate


FUNCTION daysin(dInDate)
local nReturn
local nMonth  := month(dInDate)
local nYear   := year(dInDate)
if nMonth=2  // february, check for leap year
  if (nYear%4=0 .and. nYear%100#0).or. (nYear%400=0)  && leap year
    nReturn := 29
  else
    nReturn := 28
  endif
else
  nReturn   :=  {31,28,31,30,31,30,31,31,30,31,30,31}[nMonth]
endif
return nReturn


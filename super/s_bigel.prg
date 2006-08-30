Function BIGELEM(aArray)
local nLongest := 0
local nIterator
for nIterator = 1 to len(aArray)
   if valtype(aArray[nIterator])=="C"
     nLongest := max(nLongest,len(aArray[nIterator]))
   endif
next
return nLongest



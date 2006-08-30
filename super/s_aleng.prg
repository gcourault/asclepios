Function Aleng(aArray)
local i,nActualLength := 0
for i = 1 to len(aArray)
   if aArray[i]#nil
     nActualLength++
   else
     exit
   endif
next
return nActualLength



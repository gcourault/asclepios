function aextract(aArray,bCondition,nElement)
local aReturn := {}
local i
for i = 1 to len(aArray)
  if eval(bCondition,aArray[i],i)
    if nElement#nil
      aadd(aReturn,aArray[i,nElement])
    else
      aadd(aReturn,aArray[i])
    endif
  endif
next
return aReturn


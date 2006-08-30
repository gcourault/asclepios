//------------------------------------------------------
FUNCTION aVariance(aArray,bCondition)
local nAverage,i
local nVariance := 0
local nCount := 0
nAverage := aAverage(aArray,bCondition)
if bCondition#nil
   FOR i = 1 to len(aArray)
     if eval(bCondition,aArray[i])
      nVariance += (nAverage-aArray[i] )^2
      nCount++
     endif
   ENDFOR
else
   FOR i = 1 to len(aArray)
      nVariance += (nAverage-aArray[i] )^2
      nCount++
   ENDFOR
endif
return ( nVariance/nCount )

//------------------------------------------------------
FUNCTION aStdDev(aArray,bCondition)
return sqrt(aVariance(aArray,bCondition))

//------------------------------------------------------
FUNCTION aAverage(a,bCondition)
return (aSum(a,bCondition)/aMatches(a,bCondition) )

//------------------------------------------------------
FUNCTION aSum(a,bCondition)
local nRet := 0
local i
if bCondition#nil
 for i = 1 to len(a)
   if eval(bCondition,a[i])
     nRet+= a[i]
   endif
 next
else
  for i = 1 to len(a)
    nRet+= a[i]
  next
endif
return (nRet)

//------------------------------------------------------
FUNCTION aMatches(a,bCondition)
local i,nMatches := 0
if bCondition#nil
  for i =1 to len(a)
   if eval(bCondition,a[i])
     nMatches++
   endif
  next
else
  nMatches := len(a)
endif
return nMatches



//------------------------------------------------------
FUNCTION amVariance(aArray,nElem,bCondition)
  local nAverage, i
  local nVariance := 0
  local nCount    := 0
  local nReturn   := 0
  if (valtype(nElem) == 'N')
    nAverage    := amAverage(aArray,nElem,bCondition)
    bCondition  := iif(valtype(bCondition) == 'B',bCondition,{||.t.})
    for i := 1 to len(aArray)
      if (eval(bCondition,aArray[i]))
        nVariance += ((nAverage-aArray[i][nElem] )^2)
        nCount++
      endif
    next
    nReturn := (nVariance/nCount)
  endif
return (nReturn)

//------------------------------------------------------
FUNCTION amStdDev(aArray,nElem,bCondition)
return(sqrt(amVariance(aArray,nElem,bCondition)))


//------------------------------------------------------
FUNCTION amAverage(a,nElem,bCondition)
  local nRet := 0
  if (valtype(nElem) == 'N')
    nRet := amSum(a,nElem,bCondition)
    nRet := (nRet/aMatches(a,bCondition) )
  endif
return (nRet)

//------------------------------------------------------
FUNCTION amSum(a,nElem,bCondition)
  local nRet := 0
  local i
  if (valtype(nElem) == 'N')
    bCondition := iif(valtype(bCondition) == 'B',bCondition,{||.t.})
    for i := 1 to len(a)
      if (eval(bCondition,a[i]))
        nRet+= a[i][nElem]
      endif
    next
  endif
return (nRet)



function ss_hblinds(nTop,nLeft,nBottom,nRight,cInScreen,nDelay)
local nRows := nBottom-nTop+1
local nRowCounter
local nCounter
local x
nDelay := iif(nDelay#nil,nDelay,100)
for nRowCounter = 1 to nRows step 2
  restscreen(nTop+nRowCounter-1,nLeft,ntop+nRowCounter-1,nright,;
      getscrow(cInScreen,nTop,nLeft,nBottom,nRight,nRowCounter))
  for nCounter =1 to nDelay
    x=1
  next
next
for nRowCounter = 2 to nRows step 2
  restscreen(nTop+nRowCounter-1,nLeft,ntop+nRowCounter-1,nright,;
      getscrow(cInScreen,nTop,nLeft,nBottom,nRight,nRowCounter))
  for nCounter =1 to nDelay
    x=1
  next
next
return nil

//--------------------------------------------------------
function ss_vblinds(nTop,nLeft,nBottom,nRight,cInScreen,nDelay)
local nCols := nright-nleft+1
local nColCounter
local nCounter
local x
nDelay := iif(nDelay#nil,nDelay,50)
for nColCounter = 1 to nCols step 2
  restscreen(nTop,nLeft+nColCounter-1,nBottom,nleft+nColCounter-1,;
         getsccol(cInScreen,nTop,nLeft,nBottom,nRight,nColCounter))
  for nCounter =1 to nDelay
    x=1
  next
next
for nColCounter = 2 to nCols step 2
  restscreen(nTop,nLeft+nColCounter-1,nBottom,nleft+nColCounter-1,;
         getsccol(cInScreen,nTop,nLeft,nBottom,nRight,nColCounter))
  for nCounter =1 to nDelay
    x=1
  next
next
return nil

//---------------------------------------------------------------
function ss_slice(nTop,nLeft,nBottom,nRight,cInScreen,nSteps)
local nRows := nBottom-nTop+1
local nCols := nRight-nLeft+1
local nRowCounter
local aRows := array(nRows)
local cNowScreen := savescreen(nTop,nLeft,nBottom,nRight)
local nIter,nIter2

nSteps := iif(nSteps#nil,nSteps,8)
for nRowCounter = 1 to nRows
  arows[nRowCounter] := getscrow(cNowScreen,nTop,nLeft,nBottom,nRight,nRowCounter)
next

for nIter = 0 to nCols-1 step nSteps
  dispbegin()
  restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
  for nIter2 = 1 to nRows step 2
    restscreen(nTop+nIter2-1,nLeft,ntop+nIter2-1,nright-nIter,aRows[nIter2])
    aRows[nIter2] := savescreen(nTop+nIter2-1,nLeft,nTop+nIter2-1,nRight-nIter-nSteps)
  next

  for nIter2 = 2 to nRows step 2
    restscreen(nTop+nIter2-1,nLeft+nIter,ntop+nIter2-1,nright,aRows[nIter2])
    aRows[nIter2] := savescreen(nTop+nIter2-1,nLeft+nIter+nSteps,nTop+nIter2-1,nRight)
  next
  dispend()
next
restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
return nil

//---------------------------------------------------------------
function ss_split(nTop,nLeft,nBottom,nRight,cInScreen,nSteps)
local nRows := nBottom-nTop+1
local nCols := nRight-nLeft+1
local nRowCounter
local nCounter,nIter2
local aRows := array(nRows)
local nEachSide := int(nCols/2)
local cNowScreen := savescreen(nTop,nLeft,nBottom,nRight)

nSteps := iif(nSteps#nil,nSteps,5)
for nRowCounter = 1 to nRows
  arows[nRowCounter] := getscrow(cNowScreen,nTop,nLeft,nBottom,nRight,nRowCounter)
next

While nEachSide > 0
  dispbegin()
  restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
  for nIter2 = 1 to nRows
     restscreen(nTop+nIter2-1,nLeft,ntop+nIter2-1,nLeft+nEachSide-1,left(aRows[nIter2],nEachSide*2))
     restscreen(nTop+nIter2-1,nRight-nEachSide+1,ntop+nIter2-1,nRight,Right(aRows[nIter2],nEachSide*2))
  next
  dispend()
  nEachSide-=nSteps
end
restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
return nil
//---------------------------------------------------------------
function ss_fold(nTop,nLeft,nBottom,nRight,cInScreen,nSteps)
local nRows := nBottom-nTop+1
local nCols := nRight-nLeft+1
local nRowCounter
local nCounter,nIter2
local aRows := array(nRows)
local nWidth  := nCols-2
local nOffset := 1
local cNowScreen := savescreen(nTop,nLeft,nBottom,nRight)

nSteps := iif(nSteps#nil,nSteps,3)
for nRowCounter = 1 to nRows
  arows[nRowCounter] := getscrow(cNowScreen,nTop,nLeft,nBottom,nRight,nRowCounter)
next

While nWidth > 2
  dispbegin()
  restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
  for nIter2 = 1 to nRows
     restscreen(nTop+nIter2-1,nLeft+nOffset,ntop+nIter2-1,nRight-nOffset,Subst(aRows[nIter2],(nOffset*2)+1,nWidth*2))
  next
  dispend()
  nOffset+=nSteps
  nWidth := nCols-(nOffset*2)
end
restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
return nil
//---------------------------------------------------------------
function ss_rise(nTop,nLeft,nBottom,nRight,cInScreen,nDelay)
local nRows    := nBottom-nTop+1
local nCols    := nRight-nLeft+1
local aRows    := array(nRows)
local nRowCounter,nIter,nIter2,nCounter
nDelay := iif(nDelay#nil,nDelay,100)
for nRowCounter = 1 to nRows
  arows[nRowCounter] := getscrow(cInScreen,nTop,nLeft,nBottom,nRight,nRowCounter)
next
for nIter = 1 to nRows
   for nIter2 = 1 to nIter
     restscreen(nBottom-nIter+nIter2,nLeft,nBottom-nIter+nIter2,nRight,aRows[nIter2])
   next
   for nCounter =1 to nDelay
     nIter2=1
   next
next
restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
return nil
//---------------------------------------------------------------
function ss_fall(nTop,nLeft,nBottom,nRight,cInScreen,nDelay)
local nRows    := nBottom-nTop+1
local nCols    := nRight-nLeft+1
local aRows    := array(nRows)
local nRowCounter,nIter,nCounter,nIter2

nDelay := iif(nDelay#nil,nDelay,100)
for nRowCounter = 1 to nRows
  arows[nRowCounter] := getscrow(cInScreen,nTop,nLeft,nBottom,nRight,nRowCounter)
next
for nIter = nrows to 1 step -1
   dispbegin()
   scroll(nTop,nLeft,nBottom,nright,-1)
   restscreen(nTop,nLeft,nTop,nRight,aRows[nIter])
   dispend()
   for nCounter =1 to nDelay
     nIter2=1
   next
next
restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
return nil

//------------------------------------------------------------------
//--this is provided for compatibility
function fadeaway(cInScreen,nTop,nLeft,nBottom,nRight)
ss_fade(nTop,nLeft,nBottom,nRight,cInScreen)
return nil
//------------------------------------------------------------------

function ss_fade(nTop,nLeft,nBottom,nRight,cInScreen)
local cCurrent := savescreen(nTop,nLeft,nBottom,nRight)
local nIter
for nIter = 10 to 1 step -1
  restscreen(nTop,nLeft,nBottom,nRight,ssprinkle(cInScreen,savescreen(nTop,nLeft,nBottom,nRight),nIter))
next
return nil


//---------------------------------------------------------------
function ss_slideright(nTop,nLeft,nBottom,nRight,cInScreen)
local nRows := nBottom-nTop+1
local nCols := nRight-nLeft+1
local nRowCounter
local nCounter,nIter2,nIter
local aRows := array(nRows)
local cNowScreen := savescreen(nTop,nLeft,nBottom,nRight)

for nRowCounter = 1 to nRows
  arows[nRowCounter] := getscrow(cInScreen,nTop,nLeft,nbottom,nright,nRowCounter)
  arows[nRowCounter] += getscrow(cNowScreen,nTop,nLeft,nBottom,nRight,nRowCounter)
next

for nIter = nCols to 1 step -8
  dispbegin()
  for nIter2 = 1 to nRows
    restscreen(nTop+nIter2-1,nLeft,ntop+nIter2-1,nright,subst(aRows[nIter2],nIter*2+1,nCols*2))
  next
  dispend()
next
restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
return nil
//---------------------------------------------------------------
function ss_slideleft(nTop,nLeft,nBottom,nRight,cInScreen)
local nRows := nBottom-nTop+1
local nCols := nRight-nLeft+1
local nRowCounter
local nCounter,nIter2,nIter
local aRows := array(nRows)
local cNowScreen := savescreen(nTop,nLeft,nBottom,nRight)

for nRowCounter = 1 to nRows
  arows[nRowCounter] := getscrow(cNowScreen,nTop,nLeft,nBottom,nRight,nRowCounter)
  arows[nRowCounter] += getscrow(cInScreen,nTop,nLeft,nbottom,nright,nRowCounter)
next

for nIter = 1 to nCols step 8
  dispbegin()
  for nIter2 = 1 to nRows
    restscreen(nTop+nIter2-1,nLeft,ntop+nIter2-1,nright,subst(aRows[nIter2],nIter*2+1,nCols*2))
  next
  dispend()
next
restscreen(ntop,nLeft,nbottom,nRight,cInScreen)
return nil

//---------------------------------------------------------------
function ss_closeh(ntop,nLeft,nBottom,nRight,cInScreen,nDelay)
local nRows := nBottom-nTop+1
local nRowTop   := nTop
local nRowBottom := nBottom
local nCounter,x
nDelay := iif(nDelay#nil,nDelay,100)

while nRowTop<nRowBottom

  restscreen(nRowTop,nLeft,nRowTop,nRight,;
      getscrow(cInScreen,nTop,nLeft,nBottom,nRight,nRowTop-nTop+1))

  restscreen(nRowBottom,nLeft,nRowBottom,nRight,;
      getscrow(cInScreen,nTop,nLeft,nBottom,nRight,nRowBottom-nTop+1))

  nRowTop++
  nrowBottom--
  for nCounter =1 to nDelay
    x=1
  next
end
restscreen(ntop,nLeft,nBottom,nRight,cInScreen)
return nil

//---------------------------------------------------------------
function ss_closev(ntop,nLeft,nBottom,nRight,cInScreen,nDelay)
local nCols := nright-nleft+1
local nColLeft  := nLeft
local nColRight := nRight
local nCounter,x
nDelay := iif(nDelay#nil,nDelay,50)

while  nColLeft < nColRight
  dispbegin()
  restscreen(nTop,nColLeft,nBottom,nColLeft,;
         getsccol(cInScreen,nTop,nLeft,nBottom,nRight,nColLeft-nLeft+1))

  restscreen(nTop,nColRight,nBottom,nColRight,;
         getsccol(cInScreen,nTop,nLeft,nBottom,nRight,nColRight-nLeft+1))

  dispend()
  nColLeft++
  ncolRight--

  for nCounter =1 to nDelay
    x=1
  next
end
restscreen(ntop,nLeft,nBottom,nRight,cInScreen)
return nil
//---------------------------------------------------------------

function ss_implode(ntop,nLeft,nBottom,nRight,cInScreen,nDelay)
local nRows := nBottom-nTop+1
local nCols := nright-nleft+1
local nColLeft  := nLeft
local nColRight := nRight
local nRowTop   := nTop
local nRowBottom := nBottom
local nCounter,x
nDelay := iif(nDelay#nil,nDelay,100)

while nRowTop<nRowBottom  .and. nColLeft < nColRight
  dispbegin()
  restscreen(nRowTop,nLeft,nRowTop,nRight,;
      getscrow(cInScreen,nTop,nLeft,nBottom,nRight,nRowTop-nTop+1))

  restscreen(nRowBottom,nLeft,nRowBottom,nRight,;
      getscrow(cInScreen,nTop,nLeft,nBottom,nRight,nRowBottom-nTop+1))

  restscreen(nTop,nColLeft,nBottom,nColLeft,;
         getsccol(cInScreen,nTop,nLeft,nBottom,nRight,nColLeft-nLeft+1))

  restscreen(nTop,nColRight,nBottom,nColRight,;
         getsccol(cInScreen,nTop,nLeft,nBottom,nRight,nColRight-nLeft+1))

  dispend()
  nRowTop++
  nRowBottom--
  nColLeft++
  ncolRight--
  for nCounter =1 to nDelay
    x=1
  next
end
restscreen(ntop,nLeft,nBottom,nRight,cInScreen)
return nil
//---------------------------------------------------------------

function ss_wipeh(ntop,nLeft,nBottom,nRight,cInScreen,nDelay)
local nRowTop   := nTop
local nCounter,x
nDelay := iif(nDelay#nil,nDelay,100)

for nRowTop = nTop to nBottom

  restscreen(nRowTop,nLeft,nRowTop,nRight,;
      getscrow(cInScreen,nTop,nLeft,nBottom,nRight,nRowTop-nTop+1))

  for nCounter =1 to nDelay
    x=1
  next
next
restscreen(ntop,nLeft,nBottom,nRight,cInScreen)
return nil

//---------------------------------------------------------------
function ss_wipev(ntop,nLeft,nBottom,nRight,cInScreen,nDelay)
local nColLeft
local nCounter,x
nDelay := iif(nDelay#nil,nDelay,50)

for nColLeft = nLeft to nRight
  dispbegin()
  restscreen(nTop,nColLeft,nBottom,nColLeft,;
         getsccol(cInScreen,nTop,nLeft,nBottom,nRight,nColLeft-nLeft+1))

  dispend()

  for nCounter =1 to nDelay
    x=1
  next
end
restscreen(ntop,nLeft,nBottom,nRight,cInScreen)
return nil

// here for compatibility, not documented
function shiftr(cInscreen,nTop,nLeft,nBottom,nright,nSpeed)
ss_slideright(nTop,nLeft,nBottom,nRight,cInscreen)
return nil


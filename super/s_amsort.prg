function aSortmult(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15)
local aAll    := {a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15}
local aSorter := array(len(a1))
local nArrays := pcount()
local i,nNext,aThis
for i = 1 to len(aSorter)
  aThis := {}
  for nNext = 1 to nArrays
    aadd(aThis,aAll[nNext,i])
  next
  aSorter[i] := aThis
next

asort(aSorter,,,{|x,y|x[1]<y[1]})

for i = 1 to len(aSorter)
  for nNext = 1 to nArrays
    aAll[nNext,i] := aSorter[i,nNext]
  next
next
return nil

function aSortmultr(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15)
local aAll    := {a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15}
local aSorter := array(len(a1))
local nArrays := pcount()
local i,nNext,aThis
for i = 1 to len(aSorter)
  aThis := {}
  for nNext = 1 to nArrays
    aadd(aThis,aAll[nNext,i])
  next
  aSorter[i] := aThis
next

asort(aSorter,,,{|x,y|x[1]>y[1]})

for i = 1 to len(aSorter)
  for nNext = 1 to nArrays
    aAll[nNext,i] := aSorter[i,nNext]
  next
next
return nil


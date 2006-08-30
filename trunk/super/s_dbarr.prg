/* example
  use customer
  a := dbf2array()
  for i = 1 to len(a)
    @0+i,0 get a[i]
  next
  read
  if aupdated(a)
    array2dbf(a)
  endif
*/


FUNCTION DBF2ARRAY()
local aArray := array(fcount())
local i
for i = 1 to fcount()
   aArray[i] := FIELDGET(i)
next
return aArray

//-----------------------------------------------------------------
FUNCTION ARRAY2DBF(aArray)
local i
for i = 1 to fcount()
  FIELDPUT(i,aArray[i])
next
return nil

//-----------------------------------------------------------------
FUNCTION AUPDATED(aArray)
local i
local lUpdated := .f.
for i = 1 to fcount()
  if aArray[i]#FIELDGET(i)
    lUpdated := .t.
    exit
  endif
next
return lUpdated

//-----------------------------------------------------------------


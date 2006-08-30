
Function uniqfname(cExtension,cPath,cPrefix)
local nCounter,cUniqName

if valtype(cPrefix)<>"C"
  cPrefix := "U"
endif
if valtype(cPath)<>"C"
  cPath  := getdfp()
endif
nCounter = 900000
if !empty(cExtension)
  cExtension = "."+cExtension
endif
cUniqName  := cPrefix+"_"+trans(nCounter,"999999")+cExtension
do while file(cPath+cUniqName)
  nCounter++
  cUniqName := cPrefix+"_"+trans(nCounter,"999999")+cExtension
enddo

return cUniqName



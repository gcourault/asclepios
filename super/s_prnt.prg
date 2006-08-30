function prnt(nRow,nColumn,cString,nAttribute)
local  cColor
if valtype(nAttribute)=="C"
   cColor := nAttribute
elseif valtype(nAttribute)=="N"
   cColor := at2char(nAttribute)
else
   cColor := setcolor()
endif
@nRow,nColumn say cString color cColor
return nil


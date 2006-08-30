function afieldstype(cType)
local aStruct := dbstruct()
local aReturn := {}
if valtype(cType)=="C"
   cType := upper(cType)
   AEVAL(aStruct,{|e|iif(e[2]$cType,aadd(aReturn,e[1]),nil)} )
endif
return aReturn

//----------------------------------------------------------------------
function qfldstype(cType)
local aStruct := dbstruct()
local nReturn := 0
if valtype(cType)=="C"
   cType := upper(cType)
   AEVAL(aStruct,{|e|iif(e[2]$cType,nReturn++,nil)} )
endif
return nReturn

//----------------------------------------------------------------------
function afieldsx
local aStruct := dbstruct()
local aReturn := {}
AEVAL(aStruct,{|e|aadd(aReturn,e[1])} )
return aReturn

//----------------------------------------------------------------------
function aftypesx
local aStruct := dbstruct()
local aReturn := {}
AEVAL(aStruct,{|e|aadd(aReturn,e[2])} )
return aReturn

//----------------------------------------------------------------------
function aflensx
local aStruct := dbstruct()
local aReturn := {}
AEVAL(aStruct,{|e|aadd(aReturn,e[3])} )
return aReturn

//----------------------------------------------------------------------
function afdecix
local aStruct := dbstruct()
local aReturn := {}
AEVAL(aStruct,{|e|aadd(aReturn,e[4])} )
return aReturn

//----------------------------------------------------------------------
function a2tosing(aMult,nElement)
local aSing := {}
nElement := iif(nElement==nil,1,nElement)
AEVAL(aMult,{|e|iif(valtype(e[nElement])#nil,aadd(aSing,e[nElement]),nil)})
return aSing


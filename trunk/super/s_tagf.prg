function stagfields(aFieldNames,cTitle,cMark)
local aReturn
local aStruc,i
if aFieldNames==nil
  aFieldNames := array(fcount())
  aStruc      := dbstruct()
  for i = 1 to len(aStruc)
    aFieldNames[i] := aStruc[i,1]
  next
endif
aReturn := TAGARRAY(aFieldNames,cTitle,cMark)
return aReturn


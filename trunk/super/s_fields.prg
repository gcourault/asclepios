
function isfield(f)
local lAliased := "->"$f
local cFieldName,cAliasNAme
local lIsField
if lAliased
  cFieldName    := parsfield(f)
  cAliasNAme    := parsalias(f)
else
  cFieldName     := f
  cAliasNAme := alias()
endif
if select(cAliasName)==0
  lIsField := .f.
else
  lIsField := ( (cAliasNAme)->(fieldpos(cFieldName)) ) > 0
endif
return lIsField

//------------------------------------------------------------
function isthisarea(f)
local lAliased := "->"$f
local cFieldName,cAliasNAme
local lIsThisArea := .f.
if isfield(f)
  lIsThisArea := .t.
  if lAliased
    cAliasNAme    := parsalias(f)
    lIsThisArea   := ALLTRIM(UPPER(cAliasName))==ALLTRIM(UPPER(alias()))
  endif
endif
return lIsThisArea

//------------------------------------------------------------
function expblock(cExpress)
local bBlock
bBlock := &("{||"+cExpress+"}")
return bBlock

//------------------------------------------------------------
function workblock(cExpress)
local workarea
if isfield(cExpress)
  if "->"$cExpress
    workarea := select( parsalias(cExpress) )
  else
    workarea := select()
  endif
  return fieldwblock(parsfield(cExpress),workarea)
endif
return nil

//------------------------------------------------------------
function parsalias(cExpress)
if "->"$cExpress
  return left(cExpress,at("-",cExpress)-1)
else
  return alias()
endif
return ""

//------------------------------------------------------------
function parsfield(cExpress)
if "->"$cExpress
  return subst(cExpress,at(">",cExpress)+1)
else
  return cExpress
endif
return ''


//--------------------------------------------------------------
function fieldtypex(expField)
local aStruc    := dbstruct()
local nFieldPos := iif(valtype(expField)=="N",expField,fieldposx(expField))
local cType     := "U"
if nFieldPos > 0
   cType := aStruc[nFieldPos,2]
endif
return cType

//--------------------------------------------------------------
function fieldlenx(expField)
local aStruc    := dbstruct()
local nFieldPos := iif(valtype(expField)=="N",expField,fieldposx(expField))
local cLen      := 0
if nFieldPos > 0
   cLen  := aStruc[nFieldPos,3]
endif
return cLen

//--------------------------------------------------------------
function fielddecx(expField)
local aStruc    := dbstruct()
local nFieldPos := iif(valtype(expField)=="N",expField,fieldposx(expField))
local cDec      := 0
if nFieldPos > 0
   cDec  := aStruc[nFieldPos,4]
endif
return cDec

//--------------------------------------------------------------
function fieldposx(cField)
local nPosit := 0
if isfield(cField)
  nPosit := (parsalias(cField))->(fieldpos(parsfield(cField) ))
endif
return nPosit


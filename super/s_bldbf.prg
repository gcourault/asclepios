//± CHANGED TO USE DBCREATE()
//± DOOMED IN NEXT VERSION

FUNCTION blddbf(cDbfName,aDefinition)

local cFieldDescription,cFieldName,cFieldType,nFieldLen,nFieldDec
local nIterator,cDefinitionType,nLenDefinition
local aWorkNames := {}
local aWorkTypes := {}
local aWorkLens  := {}
local aWorkDecs  := {}

IF USED()
  msg("BLDDBF()- Datafile in use - cannot create")
  RETURN .F.
ENDIF

if !(".DBF"$UPPER(cDbfName) )
  cDbfName = cDbfName+".dbf"
endif

if !("\"$cDbfName .or. ":"$cDbfName)
   cDbfName = getdfp()+cDbfName
endif

IF FILE(cDbfName)
  *- don't want to overwrite an existing dbf
  msg("BLDDBF()- Datafile "+cDbfName+" exists - cannot overwrite")
  RETURN .F.
ENDIF

cDefinitionType := VALTYPE(aDefinition)
nLenDefinition  := LEN(aDefinition)

nIterator = 0
DO WHILE .T.
  cFieldDescription  := ""
  nIterator++
  *- take out the next section between the ":"
  *- or if param 2 is an array, the next element
  IF cDefinitionType == "C"
    cFieldDescription = takeout(aDefinition,":",nIterator)
  ELSEIF nIterator <= nLenDefinition
    cFieldDescription = aDefinition[nIterator]
  ENDIF
  *- from that section, take out the sections between the ","
  *- as field name, field type, length and description
  IF !EMPTY(cFieldDescription)
    cFieldName := ''
    cFieldType := ''
    nFieldLen  := 0
    nFieldDec  := 0
    cFieldName := UPPER(takeout(cFieldDescription,",",1))
    cFieldType := UPPER(takeout(cFieldDescription,",",2))
    nFieldLen  := VAL(takeout(cFieldDescription,",",3))
    nFieldDec  := VAL(takeout(cFieldDescription,",",4))
    
    *- fill in length/decimals on LDM and C types
    DO CASE
    CASE cFieldType == "L"
      nFieldLen := 1
      nFieldDec := 0
    CASE cFieldType == "D"
      nFieldLen := 8
      nFieldDec := 0
    CASE cFieldType == "M"
      nFieldLen := 10
      nFieldDec := 0
    CASE cFieldType == "C"
      nFieldDec := 0
    ENDCASE
    
    *- if it looks like a valid field description, plug it in
    IF !EMPTY(cFieldName) .AND. (cFieldType $ "CNDLM")
      AADD(aWorkNames,cFieldName)
      AADD(aWorkTypes,cFieldType)
      AADD(aWorkLens,nFieldLen)
      AADD(aWorkDecs,nFieldDec)
    endif
  ELSE
    *- if no more fields
    nIterator := nIterator-1
    EXIT
  ENDIF
ENDDO

if nIterator > 0
 makemydbf(cDbfName,aWorkNames,aWorkTypes,aWorkLens,aWorkDecs)
 IF SNET_USE(cDbfName,"",.F.,5)
     RETURN .T.
 ELSE
     RETURN .F.
 ENDIF
else
 RETURN .F.
endif
return .f.

static function makemydbf(cDbfName,aFieldNames,aFieldTypes,;
                          aFieldLens,aFieldDec)
local nIter
local aStruc := {}
for nIter := 1 to len(aFieldNames)
  aadd(aStruc,{aFieldnames[nIter],aFieldTypes[nIter],;
               aFieldLens[nIter],aFieldDec[nIter] } )
next
DBCREATE(cDbfName, aStruc)
RETURN NIL


static aFieldNames,aStructure
static aFreqFields,aSumFields
static cFreqString,cNumbString
static cFreqdbf
static nOldArea,cOldAlias
static cIndExp


FUNCTION freqanal

local cInscreen
local lOldExact,cOldColor,nOldOrder,nOldCursor,bOldF10
local nMainChoice
local nbrflds


nbrflds         := fcount()
aFieldNames         := array(nbrflds)
aStructure          := dbstruct()
Afields(aFieldNames)

aFreqFields       := {}
aSumFields       := {}


lOldExact       := SETEXACT(.T.)
cInscreen       := savescreen(0,0,24,79)
cOldColor       := setcolor(sls_normcol())
nOldCursor       := setcursor(0)
bOldF10           := SETKEY(-9)
nOldArea         := select()
cOldAlias        := alias()
nOldOrder        := indexord()
set order to 0

cFreqDbf        := ''
cIndExp         := ''
cFreqString     := ""
cNumbString      := ""

*-- draw screen
@0,0,24,79 BOX sls_frame()
Setcolor(sls_popcol())
@1,1,09,50 BOX sls_frame()
@1,5 SAY '[An lisis de Frecuencia]'
@20,1,23,78 BOX sls_frame()
@21,2 say "Campos Frecuencia     :"
@22,2 say "Otros campos a sumar  :"

*-- Main Loop
do while .t.
  @21,27 say cFreqString
  @22,27 say cNumbString
  *- indicate if query is active
  @2,60 SAY IIF(EMPTY(sls_query()),"[Sin Consulta]","[Con Consulta]")
  
  *- do a menu
  Setcolor(sls_popmenu())
  @02,3 PROMPT "Selecci¢n Campos Frecuencia"
  @03,3 PROMPT "Selecci¢n de otros campos a SUMAR"
  @04,3 PROMPT "Generar Consulta"
  @05,3 PROMPT "Hacer An lisis de Frecuencia"
  @06,3 PROMPT "Salir"
  menu to nMainChoice
  do case
  case nMainChoice = 1  && field selection
        aFreqFields := fa_fselect()
        scroll(21,2,22,77,0)
		  @21,2 say "Campos Frecuencia     :"
        @22,2 say "Otros campos a sumar  :"
  case nMainChoice = 2  && additional numeric field selection
        aSumFields := fa_aselect()
        scroll(21,2,22,77,0)
        @21,2 say "Campos Frecuencia     :"
        @22,2 say "Otros campos a sumar  :"
  case nMainChoice = 3  && build query
        query()
  case nMainChoice = 4  && do analysis
       if empty(cIndExp)
        msg("Primero seleccione los campos frecuencia")
       else
        fa_perform()
       endif
  case nMainChoice = 5 .or. nMainChoice = 0
     setcolor(cOldColor)
     restscreen(0,0,24,79,cInscreen)
     SETEXACT(lOldExact)
     setcursor(nOldCursor)
     SETKEY(-9,bOldF10)
     set order to (nOldOrder)
     return ''
  endcase
enddo
aFieldNames :=nil; aStructure := nil
aFreqFields := nil; aSumFields := nil
cFreqString := nil ;cNumbString := nil
cFreqdbf := nil   ; nOldArea := nil
cOldAlias := nil  ; cIndExp   := nil

return ''

//-----------------
static function fa_fselect
local i
local aPicked
local aChrAll    := {}
local aChrFields := {}
local aRetFields := {}
cFreqString      := ""
cIndExp          := ""
for i = 1 TO len(aStructure)
    IF aStructure[i,2]=="C"
      aadd(aChrFields,aStructure[i,1])
      aadd(aChrAll,aStructure[i])
    ENDIF
NEXT
aPicked    := tagarray(aChrFields,"Seleccione Campos Frecuencia")
for i = 1 to len(aPicked)
     aadd(aRetFields,aChrAll[aPicked[i]])
     cFreqString = cFreqString+aChrAll[aPicked[i],1]+' '
     cIndExp = cIndExp+aChrAll[aPicked[i],1]+'+" "+'
next
cIndExp = LEFT(cIndExp,LEN(cIndExp)-1)
return aRetFields

//-----------------------------------------------------------
static function fa_aselect
local aPicked
local aNumAll    := {}
local aNumFields := {}
local aRetFields := {}
local i
cNumbString       := ""
* fill numeric array with numeric fields
for i = 1 TO len(aStructure)
    IF aStructure[i,2]=="N"
      aadd(aNumFields,aStructure[i,1])
      aadd(aNumAll,aStructure[i])
    ENDIF
NEXT
if len(aNumFields)>0
  aPicked    := tagarray(aNumFields,"Seleccione Campos Num‚ricos")
  for i = 1 to len(aPicked)
       aadd(aRetFields,aNumAll[aPicked[i]])
       cNumbString := cNumbString+aNumAll[aPicked[i],1]+' '
  next
else
  msg("No hay campos num‚ricos")
endif
return aRetFields

//-----------------------------------------------------------

static function fa_perform
local bQuery,_ninja,cPermDbf,lUseQuery,lAbandoned,cFreqNtx,cFOrder
local cPopBox
local bExpress := &("{||"+cIndExp+"}")
local cLocator
local expFieldVal
local nIter,nFieldPos

cFOrder    := ""
bQuery     := {||.t.}
lUseQuery  := .f.
lAbandoned := .f.
if !empty(sls_query())
  if !messyn("¨Limita la lista de frecuencia a la Consulta?","No","Si")
      bQuery      := sls_bquery()
      lUseQuery   := .t.
  endif
endif

cPopBox   := makebox(7,28,14,53)
@7,29 SAY '[Procesando...]'
@10,30 SAY "Generando DBF"
*- prepare temp dbf for use, building if needed
IF !fa_makedb(cFreqDbf)
  msg("Error construyendo la DBF de salida.")
  RETURN ''
ENDIF

select 0
if !SNET_USE(cFreqDbf,"HOUNDOG",.T.,5,.F.,'')
  SELECT (nOldArea)
  msg("error abriendo la DBF de frecuencias.")
  return ''
endif

cFreqNtx := UNIQFNAME(RIGHT(INDEXEXT(),3),getdfp())

@ 9,30 SAY "Indexando..."
DBCREATEINDEX(cFreqNtx,cIndExp,bExpress)
*INDEX ON &cIndExp TO (cFreqNtx)

@11,30 SAY "Registro activo..."
SELECT (nOldArea)

*- fill temp dbf with occurance count
go top
if lUseQuery
  locate for eval(bQuery)
endif

do while !eof()

  @12,29 SAY TRANS(recno(),"999999")
  ??' de '
  ??RECCOUNT()
  cLocator     := eval(bExpress)
  SELECT houndog
  SEEK cLocator
  IF FOUND()
    SET ORDER TO 0
    REPLACE frequency_ WITH houndog->frequency_+1
  ELSE
    SET ORDER TO 0
    APPEND BLANK
    FOR nIter= 1 TO len(aFreqFields)
      expFieldVal := (cOldAlias)->(fieldget(fieldpos(aFreqFields[nIter,1])))
      fieldput(nIter,expFieldVal)
    NEXT
    REPLACE frequency_ WITH 1
  ENDIF
  FOR nIter = 1 TO len(aSumFields)
    expFieldVal := (cOldAlias)->(fieldget(fieldpos(aSumFields[nIter,1])))
    nFieldPos := fieldpos(aSumFields[nIter,1])
    fieldput(nFieldPos,expFieldVal+fieldget(nFieldPos) )
  NEXT
  SET ORDER TO 1
  SELECT (nOldArea)
  if lUseQuery
    CONTINUE
  else
    skip
  endif
  IF INKEY() = 27
        IF MESSYN("¨Abandona el an lisis?")
          lAbandoned = .t.
          exit
        ENDIF
  ENDIF
enddo

SELECT houndog
SET INDEX TO
erase (getdfp()+cFreqNtx)
unbox(cPopBox)

if !lAbandoned
   *- create a descending index
    cFOrder = UNIQFNAME(RIGHT(INDEXEXT(),3),getdfp())
    INDEX ON 100-houndog->frequency_ TO (cFOrder)

   *- show the results
   cPopBox = makebox(1,1,23,79)
   @1,2 SAY '[Resultado del An lisis ]'
   @23,2 SAY '[Pulse ESCAPE para finalizar]'
   fa_browse()
   unbox(cPopBox)
   DO WHILE .T.
     IF messyn("¨Env¡a los resultados a una DBF permanente?")
       cPermDbf = SPACE(8)
       popread(.F.,"Nombre de la DBF a enviarla:",@cPermDbf,"@N")
       cPermDbf = Alltrim(cPermDbf)
       IF !(LASTKEY() = 27 .OR. EMPTY(cPermDbf))
         cPermDbf = Alltrim(cPermDbf)
         cPermDbf =UPPER(cPermDbf)+".DBF"
         IF FILE(cPermDbf)
           msg("La base de datos "+cPermDbf+" ya existe - ","Use otro nombre")
             cPermDbf = ''
             LOOP
         ENDIF
         COPY TO (cPermDbf)
         EXIT
       ENDIF
     ELSE
       EXIT
     ENDIF
   ENDDO
endif
USE
erase (getdfp()+cFreqDbf)
IF !EMPTY(cFOrder)
  erase (getdfp()+cFOrder)
endif
SELECT (nOldArea)
RETURN ''


//-----------------------------------------------------------


static function fa_makedb()
local aDbfStruc := aclone(aFreqFields)
local nIter
for nIter := 1 to len(aSumFields)
  aadd(aDBFStruc,aSumfields[nIter])
next
aadd(aDbfStruc,{"FREQUENCY_","N",5,0})
cFreqDbf   := uniqfname("DBF",getdfp())
sele 0
DBCREATE(cFreqDbf,aDbfStruc)
USE
select (nOldArea)
return file(cFreqDbf)


//------------------------------------------------------------
#include "inkey.ch"
static function fa_browse()
*   DBEDIT(2,2,22,78)
local oBrowse
local nIter
local nLastkey

oBrowse := TBROWSEDB(2,2,22,78)
for nIter := 1 to fcount()
   oBrowse:addColumn(TBColumnNew( field(nIter),fieldblock(field(nIter))  )  )
next



oBrowse:COLSEP := "³"
DO WHILE .T.
   WHILE !oBrowse:STABILIZE()
   END
   nLastKey := INKEY(0)
   do case
   CASE nLastKey = K_LEFT
     oBrowse:left()
   CASE nLastKey = K_RIGHT
     oBrowse:right()
   CASE nLastKey = K_UP
     oBrowse:UP()
   CASE nLastKey = K_PGUP
     oBrowse:PAGEUP()
   CASE nLastKey = K_HOME
     oBrowse:GOTOP()
   CASE nLastKey = K_DOWN
     oBrowse:DOWN()
   CASE nLastKey = K_PGDN
     oBrowse:PAGEdOWN()
   CASE nLastKey = K_END
     oBrowse:GOBOTTOM()
   case nLastKey = K_F10  .OR. nLastKey == K_ESC
     EXIT
   endcase
ENDDO
return nil








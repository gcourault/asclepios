function copyfields(aInFieldNames,aInFieldDesc)

local nOldCursor     := setcursor(0)
local cInScreen      := Savescreen(0,0,24,79)
local cOldColor      := Setcolor()
local nMenuChoice
local cTarget        := ""
local bCondition     := {||.t.}
local aFields        := {}
local aSelected,aTagged
local aFieldNames    := array(fcount())
local aFieldDesc     := array(fcount())
local i
local cWhich         := "TODOS LOS REGISTROS"
local nOrder         := indexord()
local cProgress,nCopied
if aInFieldNames#nil
  aFieldNames := aInFieldNames
  if aInFieldDesc#nil
    aFieldDesc := aInFieldDesc
  else
    afields(aFieldDesc)
  endif
else
  afields(aFieldNames)
  afields(aFieldDesc)
endif
aTagged := {}
*- draw boxes
@0,0,24,79 BOX sls_frame()
Setcolor(sls_popcol())
@1,1,8,40 BOX sls_frame()
@1,5 SAY '[Copiar Campos Seleccionados]'

*- main loop
DO WHILE .T.
  
  *- do a menu
  Setcolor(sls_popmenu())
  @02,3 PROMPT "Campos a Copiar  "
  ??IIF(len(aFields)>0,"û"," ")
  @03,3 PROMPT "Criterio "
  ??cWhich
  @04,3 PROMPT "Archivo Destino "
  ??padr(cTarget,12)
  @05,3 PROMPT "Hacer la Copia  "
  @06,3 PROMPT "Salir           "

  MENU TO nMenuChoice

  Setcolor(sls_popcol())
  DO CASE
  CASE nMenuChoice = 1  // fields
    aFields := {}
    aSelected := tagarray(aFieldDesc,"Seleccione Campos a Copiar")
    for i = 1 to len(aSelected)
      aadd(aFields,aFieldNames[aSelected[i]])
    next
  CASE nMenuChoice = 2  // filter
    bCondition := getfilter(bCondition,aTagged,@cWhich)
  CASE nMenuChoice = 3  // dbfname
    cTarget    := getdbfname(cTarget)
  CASE nMenuChoice = 4   // do the copy
    if !empty(cTarget)
     if len(aFields) > 0
       set order to 0
       nCopied := copyf(aFields,bCondition,cTarget)
       set order to (nOrder)
       msg("Terminado",alltrim(str(nCopied))+" registros copiados a",cTarget)
     else
       msg("Elija los campos")
     endif
    else
      msg("Se necesita un nombre para la DBF")
    endif
  CASE nMenuChoice = 5 .OR. nMenuChoice = 0
    Restscreen(0,0,24,79,cInScreen)
    Setcolor(cOldColor)
    setcursor(nOldCursor)
    exit
  ENDCASE
END
RETURN nil


static function copyf(aFields,bCondition,cTarget)
local nSource       := select()
local cSource       := alias()
local aGetblocks    := array(len(aFields))
local aNewStruc     := array(len(aFields))
local i,nTarget
local nCopied       := 0

IF !empty(cTarget)
   plswait(.T.,"Preparando la copia....")
   for i = 1 to len(aFields)
     aGetBlocks[i] := fieldwblock(aFields[i],nSource)
     aNewStruc[i]  := {aFields[i],fieldtypex(aFields[i]),fieldlenx(aFields[i]),fielddecx(aFields[i])}
   next

   dbcreate(cTarget,aNewStruc)
   plswait(.F.)
   if file(cTarget)
     USE (cTarget) NEW EXCLUSIVE alias _TARGET_
     nTarget   := select()
     select (nSource)
     go top

     PROGEVAL({||_TARGET_->(putrec(aGetBlocks)),nCopied++},bCondition,"Copiando",;
        {||alltrim(str(nCopied))+" copia de "+alltrim(str(recno()))+" registros"} )

   endif
   select _TARGET_
   nCopied := recc()
   USE
   select (nSource)
ENDIF
return nCopied

//-------------------------------------------------------------
static function putrec(aGetBlocks)
local i
APPEND BLANK
for i = 1 to fcount()
  FIELDPUT(i,eval(aGetBlocks[i]))
next
//boxupdate(recc(),nil)
return nil

//-------------------------------------------------------------
static FUNCTION getdbfname(cDbfName)

DO WHILE .T.
  cDbfName = PADR(cDbfName,35)
  popread(.F.,"Nombre de la base de datos destino : ",@cDbfName,"@!")
  IF EMPTY(cDbfName)
    EXIT
  ENDIF
  cDbfName := Alltrim(cDbfName)
  cDbfName := IIF(.NOT. ".DBF" $ cDbfName, cDbfName+".DBF",cDbfName)
  
  *- if it already exists, don't overwrite it
  *- loop around and get another filespec
  IF FILE(cDbfName)
    IF messyn("La base de datos "+cDbfName+" ya existe - ","Usar otro nombre","Overwrite")
      cDbfName := ''
      LOOP
    ENDIF
  ENDIF
  EXIT
ENDDO
return cDbfName

//------------------------------------------------------------
static function getfilter(bCondition,aTagged,cWhich)
local nChoice
local bNew := bCondition
nChoice := menu_v("Copiar Registros:","Marcar Registros a Copiar",;
                  "Copiar registros consultados",;
                  "Todos los registros")
cWhich := 'TODOS LOS REGISTROS'
DO CASE
CASE lastkey()=27
CASE nChoice = 1
  tagit(aTagged)
  IF len(aTagged) > 0
    bNew := {||ascan(aTagged,recno())>0}
    cWhich := 'REGISTROS MARCADOS'
  endif
CASE nChoice = 2
  IF EMPTY(sls_query())
    IF !messyn("No existe consulta","¨Hace una?","Olvidarlo")
      RETURN ''
    ENDIF
    QUERY()
    if !empty(sls_query())
      bNew := sls_bquery()
      cWhich := 'CONSULTA'
    endif
  ELSE
    IF messyn("¨Modifica la expresi¢n de la consulta?")
      QUERY()
    ENDIF
    if !empty(sls_query())
      bNew := sls_bquery()
      cWhich := 'CONSULTA'
    endif
  ENDIF
CASE nCHOICE = 3
  bNew := {||.t.}
  cWhich := 'TODOS LOS REGISTROS'
ENDCASE
cWhich := padr(cWhich,16)
return bNew


FUNCTION copyitout()
local aTagged := {}
local nOldCursor     := setcursor(0)
local cInScreen      := Savescreen(0,0,24,79)
local cOldColor      := Setcolor()
local nMenuChoice
local cTarget        := ""
local bCondition     := {||.t.}
local i
local cWhich         := "TODOS LOS DATOS "
local nOrder         := indexord()
local cProgress,nCopied

*- draw boxes
@0,0,24,79 BOX sls_frame()
Setcolor(sls_popcol())
@1,1,8,40 BOX sls_frame()
@1,5 SAY '[Copiar Registros Seleccionados]'

*- main loop
DO WHILE .T.
  
  *- do a menu
  Setcolor(sls_popmenu())
  @02,3 PROMPT "Criterio "
  ??cWhich
  @03,3 PROMPT "Archivo Destino "
  ??padr(cTarget,12)
  @04,3 PROMPT "Hacer la Copia  "
  @06,3 PROMPT "Salir           "

  MENU TO nMenuChoice

  Setcolor(sls_popcol())
  DO CASE
  CASE nMenuChoice = 1  // filter
    bCondition := getfilter(bCondition,aTagged,@cWhich)
  CASE nMenuChoice = 2  // dbfname
    cTarget    := getdbfname(cTarget)
  CASE nMenuChoice = 3   // do the copy
    if !empty(cTarget)
       plswait( .T. , "Copiando..." )
       set order to 0
       nCopied   := copyf(bCondition,cTarget)
       set order to (nOrder)
       plswait(.F.)
       msg("Terminado",alltrim(str(nCopied))+" registros copiados a ",cTarget)
    else
      msg("Se necesita un nombre de la DBF destino")
    endif
  CASE nMenuChoice = 4 .OR. nMenuChoice = 0
    Restscreen(0,0,24,79,cInScreen)
    Setcolor(cOldColor)
    setcursor(nOldCursor)
    exit
  ENDCASE
END
RETURN nil


static function copyf(bCondition,cTarget)
local nMatches := 0
local nCounted := 0
local bDisplay := {||alltrim(str(nMatches))+" copia de "+alltrim(str(recc()))+" with "+alltrim(str(recc()-nCounted))+" to check" }
 dbgotop()
 ProgOn("Copiando")
 copy to (cTarget) for eval(bCondition).and.(nMatches++,.t.) while (nCounted++,ProgDisp(nMatches,recc(),bDisplay ))
 ProgOff()
return nMatches

//-------------------------------------------------------------
static FUNCTION getdbfname(cDbfName)

DO WHILE .T.
  cDbfName = PADR(cDbfName,35)
  popread(.F.,"Nonbre de la base de datos destino : ",@cDbfName,"@!")
  IF EMPTY(cDbfName)
    EXIT
  ENDIF
  cDbfName := Alltrim(cDbfName)
  cDbfName := IIF(.NOT. ".DBF" $ cDbfName, cDbfName+".DBF",cDbfName)
  
  *- if it already exists, don't overwrite it
  *- loop around and get another filespec
  IF FILE(cDbfName)
    msg("La base de datos "+cDbfName+" ya existe - ","Usar otro nombre")
    cDbfName := ''
    LOOP
  ENDIF
  EXIT
ENDDO
return cDbfName

//------------------------------------------------------------
static function getfilter(bCondition,aTagged,cWhich)
local nChoice
local bNew := bCondition
nChoice := menu_v("Copiar Registros:","Marcar registros a copiar",;
                  "Copiar registros de una consulta",;
                  "Todos los Registros")
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
    IF !messyn("No hay consulta activa","¨Hace una?","Olvidarlo")
      RETURN ''
    ENDIF
    QUERY()
    if !empty(sls_query())
      bNew := sls_bquery()
      cWhich := 'CONSULTA'
    endif
  ELSE
    IF messyn("¨Modifica la consulta activa?")
      QUERY()
    ENDIF
    if !empty(sls_query())
      bNew := sls_bquery()
      cWhich := 'CONSULTA'
    endif
  ENDIF
CASE nCHOICE = 3
  bNew := {||.t.}
  cWhich := 'TODOS LOS REGISTROS  '
ENDCASE
cWhich := padr(cWhich,16)
return bNew



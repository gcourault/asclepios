#include "inkey.ch"

static aFields,aFieldDesc,aFieldTypes
static lIsBuild,cNTXname

FUNCTION bldndx( aInFields,aInFieldDesc,aOpenNTXs,lBuildex)

EXTERNAL DESCEND,nbr2str

LOCAL cIndexExpr,lDescend
LOCAL cInScreen,nCurrentRecord,cOldColor,nMenuChoice
LOCAL nOldCursor,cNewName
local aOldNtxs[10]
AFILL(aOldNtxs,"")
if VALTYPE(aOpenNTXs)=="A"
  acopy(aOpenNTXs,aOldNtxs)
endif

lIsBuild := iif(lBuildex#nil,lBuildex,.f.)

*- no dbf, no index
IF !Used()
  RETURN ''
ENDIF

nCurrentRecord := RECNO()
nOldCursor     := setcursor(0)
cInScreen      := Savescreen(0,0,24,79)
cOldColor      := Setcolor()

*- if no field array, make one
IF VALTYPE(aInFields)+VALTYPE(aInFieldDesc) <> "AA"
  aFields    := array(fcount())
  aFieldDesc := array(fcount())
  Afields(aFields)
  Afields(aFieldDesc)
else
  aFields    := array(len(aInFields) )
  aFieldDesc := array(len(aInFieldDesc) )
  acopy(aInfields,aFields)
  acopy(aInfieldDesc,aFieldDesc)
ENDIF
aFieldTypes := array(len(aFields))
fillarr(aFields,aFieldTypes)

*- draw boxes
@0,0,24,79 BOX sls_frame()
Setcolor(sls_popcol())
@1,1,8,40 BOX sls_frame()
@1,5 SAY '[Index Builder]'
@18,1,23,78 BOX sls_frame()
@18,2 SAY "Clave Activa :"

*- init vars
cIndexExpr := ''
cNTXname   := ''
lDescend   := .F.

*- main loop
DO WHILE .T.
  
  *- say expression
  @19,3 SAY addspace(SUBST(cIndexExpr,1,70),70)
  @20,3 SAY addspace(SUBST(cIndexExpr,71,70),70)
  
  *- do a menu
  Setcolor(sls_popmenu())
  @02,3 PROMPT "Definir expresi¢n para el ¡ndice"
  @03,3 PROMPT "Crear expresi¢n desde el ¡ndice"
  @04,3 PROMPT "Ver los registros con la expresi¢n"
  IF lDescend
    @05,3 PROMPT "Orden de Clasificaci¢n: DESCENDENTE/ascendente"
  ELSE
    @05,3 PROMPT "Orden de Clasificaci¢n: descendente/ASCENDENTE"
  ENDIF
  @06,3 PROMPT "Salir"

  MENU TO nMenuChoice

  Setcolor(sls_popcol())
  DO CASE
  CASE nMenuChoice = 1
    cIndexExpr := sfix_express()
  CASE nMenuChoice = 2 .AND. !EMPTY(cIndexExpr)
    sfix_create(cIndexExpr,aOldNtxs,lDescend)
  CASE nMenuChoice = 3 .AND. !EMPTY(cIndexExpr)
    smalls(cIndexExpr)
    IF !EMPTY(nCurrentRecord)
      GO nCurrentRecord
    ENDIF
  CASE nMenuChoice = 4
    lDescend := !(lDescend)
  CASE nMenuChoice = 5 .OR. nMenuChoice = 0
    Restscreen(0,0,24,79,cInScreen)
    Setcolor(cOldColor)
    setcursor(nOldCursor)
    IF !EMPTY(nCurrentRecord)
      GO nCurrentRecord
    ENDIF
    exit
  ENDCASE
END
cNewName := cNTXName
aFields:=aFieldDesc:=aFieldTypes:=lIsBuild:=cNTXname:=nil
RETURN cNewName

//==============================================================

static FUNCTION sfix_express
local   cExprBox,nElement,cNtxExpression
local   nPartsAdded,nIter,cfieldName
local   aExprParts[20]
local   oBrowse
local   nKey
local   expBuild
nElement := 1

cExprBox = makebox(2,42,17,78,sls_popcol(),0,0)
@2,43 SAY "[Generador de la Expresi¢n Indice]"

oBrowse  := tbrowseNew(3,43,13,77)
oBrowse:addcolumn(tbColumnNew("Campo",{||PADR(aFieldDesc[nElement],32)}  ))
oBrowse:skipblock     := {|n|askip(n,@nElement)}
oBrowse:gobottomblock := {||nElement := len(aFields)}
oBrowse:gotopblock    := {||nElement := 1}

@14,43 TO 14,77
@15,43 SAY "Enter para seleccionar , F10 para salir "
IF lIsBuild
  @16,43 SAY "Alt-E para generar expresi¢n compleja"
endif
nElement       := 1
nPartsAdded    := 0
cNtxExpression := ""

DO WHILE .T.
  while !oBrowse:stabilize()
  end
  @19,3 SAY addspace(SUBST(cNtxExpression,1,70),70)
  @20,3 SAY addspace(SUBST(cNtxExpression,71,70),70)


  nKey     := inkey(0)

  do case
  case nKey == K_ESC .or. nKey==K_F10
     exit
  case nKey == K_DOWN
     oBrowse:down()
  case nKey == K_UP
     oBrowse:up()
  case nKey == K_ENTER .or. nKey == K_ALT_E
     IF aFieldTypes[nElement]=="M"
       msg("No se permiten campos memo en los ¡ndices")
       LOOP
     ENDIF
     nPartsAdded++
     *- field name and type
     cfieldName := aFields[nElement]
     IF nKey==K_ALT_E .and. lIsBuild
       cFieldName := buildex("Expresi¢n Compleja del Indice",cFieldName,.F.,aFields,aFieldDesc)
     ENDIF
     *- add to string as a character expression
     DO CASE
     CASE aFieldTypes[nElement]== 'C'
       aExprParts[nPartsAdded]= cfieldName
     CASE aFieldTypes[nElement]== 'D'
       aExprParts[nPartsAdded]= 'dtos('+cfieldName+')'
     CASE aFieldTypes[nElement]== 'N'
       aExprParts[nPartsAdded]= 'nbr2str('+cfieldName+')'
     CASE aFieldTypes[nElement]== 'L'
       aExprParts[nPartsAdded]= 'iif('+cfieldName+',"T","F")'
     ENDCASE
     cNtxExpression := ""
     for nIter = 1 TO nPartsAdded-1
       cNtxExpression +=aExprParts[nIter]+'+'
     NEXT
     cNtxExpression +=aExprParts[nPartsAdded]
  endcase
ENDDO
SETKEY(K_ALT_E)
unbox(cExprBox)
RETURN cNtxExpression

//==============================================================

static FUNCTION sfix_create(cIndexExpr,aOldNtxs,lDescend)
local cExpress := iif(lDescend,'DESCEND('+cIndexExpr+')',cIndexExpr)
local bExpress := &("{||"+cExpress+"}" )
SET ORDER TO 0

IF  messyn("¨Crea el ¡ndice? ",10,27)
  cNTXname = SPACE(8)
  DO WHILE .T.
    cNTXname = PADR(cNTXName,8)
    popread(.F.,"Nombre del ¡ndice: ",@cNTXname,'@!')
    IF AT(".",cNTXname) > 0
      cNTXname := TRIM(takeout(cNTXname,'.',1))
    ENDIF
    cNTXname := TRIM(STRTRAN(cNTXname," ","")+"")
    IF FILE(cNTXname+INDEXEXT())
       msg("Este ¡ndice ya existe - no se puede sobreescribir")
       cNTXname := SPACE(8)
       loop
    ELSEIF EMPTY(cNTXname)
      IF messyn("Se ha dejado el nombre en blanco - ¨Cancela?")
        EXIT
      ENDIF
    ELSE
      EXIT
    ENDIF
  ENDDO
  IF !EMPTY(cNTXname)
    Scroll(19,2,22,77,0)
    @19,3 SAY "Creando Indice      :"+cNTXname+IIF(lDescend,"            ORDEN ASCENEDENTE","           ORDEN DESCENDIENTE")

     ProgOn("Indexando")
     dbcreateindex(cNtxName,"("+cExpress+")",{||ProgDisp( recno(),reccount() ),eval(bExpress) },.f.)
     ProgOff()

    Scroll(19,2,22,77,0)
    SET INDEX TO (cNTXname),(aOldNtxs[1]),(aOldNtxs[2]),;
                 (aOldNtxs[3]),(aOldNtxs[4]),(aOldNtxs[5]),;
                 (aOldNtxs[6]),(aOldNtxs[7]),(aOldNtxs[8]),;
                 (aOldNtxs[9]),(aOldNtxs[10])
    Scroll(19,2,22,77,0)
  ENDIF
ENDIF
return ''

//============================================================
static function askip(n,curr_row)
  local skipcount := 0
  do case
  case n > 0
    do while curr_row+skipcount < fcount()  .and. skipcount < n
      skipcount++
    enddo
  case n < 0
    do while curr_row+skipcount > 1 .and. skipcount > n
      skipcount--
    enddo
  endcase
  curr_row += skipcount
return skipcount


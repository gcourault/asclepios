
static nLeftMargin,nTopMargin,lPauseFirst,nFormWidth
static bLocater,cDestination
static nSelectedArea,cWorkForm
static aFields,aFdesc,aFtype,aUexpress,aUkeys
static aTagged,aHelp,nUserDef

#define MAXFORMSIZE 4000
#include "inkey.ch"


FUNCTION formletr(aInField,aInfdescr,aInftype,aInUexpress,aInUdescrip,aInUkeys)


LOCAL nFieldCount,cCurrFormDes,nMainSelect
LOCAL nSelection,cDescription
local lUseQuery,nCount,cImpFile,lUseTag,cMainScreen,cOldColor
local cShowFilter,nFilterType,cFormsFile
local nCursor, bOldF1,bOldF2,bOldF10
local nSinglerec := 0

nUserDef  := iif(aInUexpress#nil,min(30,len(aInUexpress)),0)
aHelp := sfll_makeh(aInUexpress,aInUdescrip,aInUkeys)

cFormsFile      := SLSF_FORM()

* assumes dbf is open
IF !USED()
  RETURN ''
  msg("No hay bases de datos abiertas")
ENDIF

nSelectedArea   := SELECT()

*- save environment
cMainScreen     := SAVESCREEN(0,0,24,79)
cOldCOlor       := Setcolor()
nCursor         := SETCURSOR(0)
bOldF1          := SETKEY(28)
bOldF2          := SETKEY(-1)
bOldF10         := SETKEY(-9)

*- select a new area for forms.dbf
SELECT 0


* create form if it doesn't exist
IF !FILE(cFormsFile+".dbf")
    blddbf(cFormsFile,"DESCRIPT,C,50:MEMO_ORIG,M")
ENDIF
*- open forms.dbf

IF !SNET_USE(cFormsFile,"__FORM",.F.,5,.F.,"No se puede abrir "+cFormsFile+". ¨Reintenta?")
   sele (nSelectedArea)
   return ''
endif

*- go back to first area
select (nSelectedArea)

SET CURSOR ON
plswait(.T.)
*- make field arrays
if valtype(aInField)+valtype(aInfdescr)+valtype(aInftype)=="AAA"
  aFields := aInField
  aFdesc  := aInFdescr
  aFtype  := aInftype
else
  aFields := array(fcount())
  aFdesc  := array(fcount())
  aFtype  := array(fcount())
  Afields(aFields,aFtype)
  Afields(aFdesc)
ENDIF
aUExpress := aInUexpress
aUKeys    := aInUkeys


*- get nFieldCount
nFieldCount = Fcount()
plswait(.F.)

*- draw the screen
Setcolor(sls_normcol())

@0,0,24,79 BOX "ÚÄ¿³ÙÄÀ³ "
Setcolor(sls_popcol())
@1,4,13,35 BOX "ÚÄ¿³ÙÄÀ³ "
@20,1,23,78 BOX "ÚÄ¿³ÙÄÀ³ "
@1,5 SAY '[Administrador de Formularios]'


*- no current form
cCurrFormDes := SPACE(50)
*- default form width
nFormWidth   := 79

*- default output
cDestination := "IMPRESORA"

*- default device (_SUPERPRN is initialized by INITSUP)
SET PRINTER TO (sls_prn())

nLeftMargin := 0
nTopMargin  := 0
cShowFilter := "TODOS LOS REGISTROS"
bLocater    := {||.t.}
lPauseFirst := .F.
*- set keys
SET KEY -1 TO
SET KEY 28 TO
DO WHILE .T.
  Setcolor(sls_popmenu())
  
  *- display  - is query active
  @1,65 SAY IIF(EMPTY(sls_query()),"[Sin Consulta]  ","[Consulta Activa]")
  *- display current form
  @21,4  SAY "FORMULARIO ACTIVO ->"+cCurrFormDes
  *- display current datafile
  @22,4  SAY "BASE DE DATOS     ->"+ALIAS()
  
  *- do the menu
  GO TOP
  @02,8 PROMPT "Seleccionar Formulario"
  @03,8 PROMPT "Crear nuevo Formulario"
  @04,8 PROMPT "Borrar Formularios"
  @05,8 PROMPT "Editar Formulario Activo"
  @06,8 PROMPT "Imprimir Formularios"
  @07,8 PROMPT "Ancho del Formulario :"+TRANS(nFormWidth,"999")
  @08,8 PROMPT "Salida a :"+cDestination
  @09,8 PROMPT "Asignar puerto de Impresora"
  @10,8 PROMPT "Filtro :"+cShowFilter
  @12,8 PROMPT "Salir"
  MENU TO nMainSelect
  Setcolor(sls_popcol())
  
  
  *- do action based on request
  DO CASE
  CASE nMainSelect = 1
    *- select a predefined formletter to work with
    SELECT __FORM
    IF RECCOUNT() > 0
      nSelection := sffl_pick()
      IF nSelection > 0
        GO nSelection
      ENDIF
      cCurrFormDes := __FORM->descript
    ELSE
      msg("No hay formularios definidos")
    ENDIF
    select (nSelectedArea)
    
  CASE nMainSelect = 2
    
    *- create a new form letter
    cDescription := SPACE(50)
    do while empty(cDescription)
      popread(.T.,"Ingrese una descripci¢n para el formulario",@cDescription,"@!")
      if empty(cDescription)
        if messyn("Ha dejado el nombre en blanco - ¨Abandona el proceso?")
            exit
        endif
      endif
    enddo
    if empty(cDescription)
      loop
    endif
    cWorkForm := ""
    IF !messyn("¨Usa otro formulario como modelo?","No","Si")
      SELECT __FORM
      IF RECCOUNT() > 0
        nSelection := sffl_pick()
        IF nSelection > 0
          GO nSelection
        ENDIF
        cWorkForm := __FORM->memo_orig
      ELSE
        msg("No hay formularios en el archivo")
      ENDIF
      select (nSelectedArea)
    ELSE
      IF !messyn("¨Importa un archivo texto como modelo?","No","Si")
        cImpFile := SPACE(12)
        popread(.T.,"Archivo a Importar (ENTER o *Asteriscos para seleccionar - ESC para salir)",@cImpFile,"")
        IF !LASTKEY() = 27
          IF EMPTY(cImpFile) .OR. AT('*',cImpFile) > 0
            IF EMPTY(cImpFile)
              cImpFile := "*.*"
            ENDIF
            cImpFile := popex(cImpFile)
          ENDIF
          IF !LASTKEY() = 27
            IF FILE(cImpFile)
              IF MEMORY(0)*1000 < FILEINFO(cImpFile,1)
                msg("El archivo es muy grande para ser importado")
              ELSE
                cWorkForm := MEMOREAD(getdfp()+cImpFile)
                *- limit the size of it to 2 pages
                cWorkForm := LEFT(cWorkForm,MAXFORMSIZE)
              ENDIF
            ENDIF
          ENDIF
        ENDIF
      ENDIF
    ENDIF
    
    *- edit the form letter
    *- SFFL_EDIT returns .t. if user wants to save
    IF sffl_edit()
      SELECT __FORM
      locate for deleted()   // re-use deleted records
      if (found() .AND. SREC_LOCK(5,.F.) ) .OR. ;
         SADD_REC(5,.T.,"No se puede bloquear el registo para grabar. ¨Reintenta?")
          REPLACE memo_orig WITH cWorkForm
          REPLACE __FORM->descript WITH cDescription
          cCurrFormDes := __FORM->descript
          DBRECALL()
          unlock
          goto recno()
      endif
    ENDIF
    select (nSelectedArea)
    
    
  CASE nMainSelect = 3
    SELECT __FORM
    purgem()
    select (nSelectedArea)
    
  CASE nMainSelect = 4 .AND. !EMPTY(cCurrFormDes)
    
    *- edit the current form
    SELECT __FORM
    cWorkForm := __FORM->memo_orig
    
    *- call SFFL_EDIT()
    *- returns .t. if user wants to save changes
    IF sffl_edit()
      if SREC_LOCK(5,.T.,"No se puede bloquear el registro para grabar. ¨Reintenta?")
        REPLACE memo_orig WITH cWorkForm
        unlock
        goto recno()
      ENDIF
    ENDIF
    select (nSelectedArea)
    
  CASE nMainSelect = 5 .AND. !EMPTY(cCurrFormDes)

    if cShowFilter == "UN SOLO REGITRO"
      sffl_print(cDestination,bLocater,.t.)
    else
      sffl_print(cDestination,bLocater,.f.)
    endif
  CASE nMainSelect = 6
    popread(.F.,"Ancho del Formulario ",@nFormWidth,"999")
    
  CASE nMainSelect = 7
    cDestination = IIF(cDestination == "IMPRESORA","ARCHIVO  ","IMPRESORA")
    
  CASE nMainSelect = 8
    sls_prn(prnport())   
    
  CASE nMainSelect = 9
    nFilterType := MAX(1,menu_v("Tipo de Filtro ",;
                                "Ninguno - Todos los Registros",;
                                "Registros que cumplen con la consulta",;
                                "Registros Marcados",;
                                "Un solo registro"))
    DO CASE
    CASE nFilterType = 1
      cShowFilter := "TODOS LOS REGISTROS "
      lUseTag     := .F.
      lUseQuery   := .F.
      bLocater    := {||.t.}
    CASE nFilterType = 2
      cShowFilter := "REGISTROS CONSULTADOS"
      IF messyn("Modify query now?")
        QUERY(aFields,aFdesc,aFtype,"To Form Letters")
      ENDIF
      lUseTag     := .F.
      lUseQuery   := .T.
      bLocater    := sls_bquery()
    CASE nFilterType = 3
      cShowFilter := "REGISTROS MARCADOS  "
      IF messyn("¨Marca los registros?")
        aTagged := {}
        tagit(aTagged,aFields,aFdesc)
      ENDIF
      lUseTag   := .T.
      lUseQuery := .F.
      bLocater  := {|| (Ascan(aTagged,RECNO())> 0)}
    CASE nFilterType = 4
      cShowFilter := "UN SOLO REGISTRO   "
      IF messyn("¨Selecciona el registro?","Verlos","Usar el activo")
        editdb(.f.,aFields,aFDesc,.t.)
      ENDIF
      nSingleRec := recno()
      bLocater  := {||recno()==nSingleRec}
    ENDCASE
  CASE nMainSelect = 10 .OR. nMainSelect = 0
    SELECT __FORM
    USE
    select (nSelectedArea)
    RESTSCREEN(0,0,24,79,cMainScreen)
    Setcolor(cOldCOlor)
    setcursor(nCursor)
    SETKEY(28,bOldF1)
    SETKEY(-1,bOldF2)
    SETKEY(-9,bOldF10)
    RETURN ''
    
  ENDCASE
ENDDO

nLeftMargin :=nTopMargin:=lPauseFirst:=nFormWidth:=nil
bLocater:=cDestination:=nil
nSelectedArea:=cWorkForm:=nil
aFields:=aFdesc:=aFtype:=aUexpress:=aUkeys:=nil
aTagged:=aHelp:=nUserDef:=nil

RETURN ''


*==================================================================

static FUNCTION sffl_edit
local cScreen

* Force initial insert mode
Readinsert(.T.)
cScreen := SAVESCREEN(0,0,24,79)
SET SCOREBOARD OFF
SET KEY -9 TO

*- draw screen
@0, 0 ,24, 79 BOX "ÚÄ¿³ÙÄÀ³ "
@0,6 say " F1:AYUDA    F2:Elegir el campo    F10:GRABAR     ESC:CANCELAR  "

*- call memoedit, get returned string into cWorkForm
SET CURSOR ON
cWorkForm := Memoedit(cWorkForm, 1, 1, 23, 78, .T., "SFFL_F_L_U",nFormWidth)
SET CURSOR OFF

RESTSCREEN(0,0,24,79,cScreen)
*- if escape was pressed, return .f. (don't save)
IF LASTKEY() = K_ESC
  RETURN .F.
ELSE
  RETURN .T.
ENDIF
return .f.


#include "memoedit.ch"
/*
    MODES
    -----------
    0            ME_IDLE              Idle, all keys processed
    1            ME_UNKEY             Unknown key, memo unaltered
    2            ME_UNKEYX            Unknown key, memo altered
    3            ME_INIT              Initialization mode

    RETURN VALUES
    -------------
    0            ME_DEFAULT           Perform default action
    1-31         ME_UNKEY             Process requested action
                                      corresponding to key value
    32           ME_IGNORE            Ignore unknown key
    33           ME_DATA              Treat unknown key as data
    34           ME_TOGGLEWRAP        Toggle word-wrap mode
    35           ME_TOGGLESCROLL      Toggle scroll mode
    100          ME_WORDRIGHT         Perform word-right operation
    101          ME_BOTTOMRIGHT       Perform bottom-right operation
*/

*============================================================
FUNCTION sffl_f_l_u(nMode, nLine, nColumn)

local nMassage
local nReturnVal, nLastkey, nFieldNumber, cYesNo, cFieldBox
local getlist := {}
local cReturn

*- show row/column
@24,6  SAY "  Line: " + TRANS(nLine, "9999")
@24,20 SAY "  Col: " + TRANS(nColumn, "9999")

nReturnVal := ME_DEFAULT
IF !(nMode= ME_INIT)
  *- store last keystroke
  nLastkey = LASTKEY()
  
  
  DO CASE

  CASE nLastkey =K_F1
    
    mchoice(aHelp,2,5,23,75,"[Help:]")

  CASE nLastkey = K_F10
    if messyn("¨Graba los cambios y sale?","Grabar y Salir","No Salir")
       keyboard chr(23)
    endif
  CASE nLastkey = K_ESC
    if !messyn("Exit without saving?")
       nReturnVal = ME_IGNORE
    endif

  CASE nLastkey = K_F3
    
    KEYBOARD CHR(174) + "DTOW(DATE())" +  CHR(175)

  CASE nLastkey = K_F4
    
    KEYBOARD CHR(174) +"CHR(12)"  +  CHR(175) + chr(13)
    
  CASE nLastkey = K_F2
    
    *- draw a box
    cFieldBox=makebox(3,45,22,75,sls_popmenu())
    @7,46 TO 7,74
    @7,45 SAY "Ã"
    @7,75 SAY "´"
    @4,46 SAY "Usar  para elegir un campo"
    @5,46 SAY "Pulse ENTER para aceptar "
    @6,46 SAY "Pulse ESCAPE para abandonar"
    
    *- achoice the fields
    nFieldNumber := SACHOICE(8,46,21,74,aFdesc)
    
    *- clear the box
    unbox(cFieldBox)
    
    *- if a nSelection was made
    IF nFieldNumber != 0
      cReturn := trim(aFields[nFieldNumber])

      IF aFtype[nFieldNumber] = "C"
       while (nMassage := ;
         menu_v("Como lo usa: "+cReturn,"Como est ","Sin Blancos","May£sculas","Min£sculas","La primera Letra con May£sculas") ) > 1
         cReturn := {"Trim(","Upper(","Lower(","Proper("}[nMassage-1]+cReturn+")"
       end
      endif

      KEYBOARD CHR(174) + cReturn + CHR(175)
      
    ENDIF
    
    nReturnVal = ME_IGNORE
    
  CASE nUserDef > 0
    if ascan(aUkeys,nLastkey) > 0
        KEYBOARD CHR(174) + TRIM(aUexpress[ascan(aUkeys,nLastkey)]) + ;
          CHR(175)
    endif
  ENDCASE
  
ENDIF
RETURN nReturnVal

*===============================================
static FUNCTION sffl_pick
LOCAL i
local  aForms := array(recc() )
*- fill aForms[] with descriptions from FORMS.DBF
FOR i = 1 TO RECCOUNT()
  GO i
  aForms[i] := __FORM->descript
NEXT
*- do an achoice and return nSelection
RETURN mchoice(aForms,6,10,16,65)

*========================================================

static FUNCTION sffl_print(cDestination,bLocater,lSingle)
local cBox1,cBox2
local nNextAction,lIsDone,nOutHandle,cLookingBox,cOutFile
local nCounter
local cUnderScreen := savescreen(0,0,24,79)
local lEditFirst,lOk2Print
local cThisForm,cReview
local cAltFile
local nIter

EXTERNAL CTRLW
setkey(-9,{||ctrlw()})

SELECT __FORM
cThisForm = __FORM->memo_orig
select (nSelectedArea)

DO WHILE .T.
  GO TOP
  *- determine output
  IF cDestination == "IMPRESORA"
    if !(sls_prn()=='COM1')
      IF !p_ready(sls_prn())
        EXIT
      ENDIF
    endif
  ELSE
    cOutFile := "FORMLETR.PRN"
    popread(.F.,"Imprimir a Archivo:",@cOutFile,"@K")
    cOutFile := Alltrim(cOutFile)
    IF EMPTY(cOutFile)
      EXIT
    ENDIF
    nOutHandle=FCREATE(getdfp()+cOutFile)
  ENDIF
  popread(.F.,"Margen Izquierdo ",@nLeftMargin,"99","Margen Superior  ",@nTopMargin,"99")
  IF LASTKEY()=27
    EXIT
  ENDIF
  lPauseFirst := messyn("¨Se detiene en cada p gina para revisar?")
  IF LASTKEY()=27
    EXIT
  ENDIF
  cLookingBox := makebox(10,30,13,50)
  @11,35 say "Buscando ..."
  LOCATE WHILE (inkey()#27) FOR EVAL(bLocater)

  nCounter      := 0
  lIsDone       := .f.
  lEditFirst    := .f.
  *- print all matching
  DO WHILE FOUND() .AND. !lIsDone
      nCounter++

      * print to temp file
      SET CONSOLE OFF
      SET PRINT OFF
      cAltFile := uniqfname("PRN")
      SET ALTERNATE TO (cAltFile)
      SET ALTERNATE ON
      for nIter = 1 TO nTopMargin
        ?
      NEXT
      prntfrml(cThisForm,nFormWidth-nLeftMargin,nLeftMargin)
      IF cDestination == "IMPRESORA"
        ?""  && EJECT
      endif
      SET CONSOLE ON
      SET ALTERNATE OFF
      CLOSE ALTERNATE
      cReview   := memoread(getdfp()+cAltFile)
      ERASE (getdfp()+cAltFile)
      lOk2Print := .t.


      IF lPauseFirst
        cBox1 :=makebox(1,1,23,79)
        do while .t.
          memoedit(cReview,2,2,22,78,.f.,.f.,nFormWidth)
          cBox2 := makebox(17,55,24,78,sls_popcol(),0)
          @18,56 prompt "Imprimir esta carta"
          @19,56 prompt "Editar esta carta"
          @20,56 prompt "Saltear esta carta"
          @21,56 prompt "No hacer m s pausas"
          @22,56 prompt "Salir de la impresi¢n  "
          menu to nNextAction
          unbox(cBox2)
          do case
            case nNextAction = 1
            case nNextAction = 2
              setkey(-9,{||ctrlw()} )
              @1,4 SAY "[ F10 graba cambios - ESC para restaurar  ]"
              SET CURSOR ON
              cReview := Memoedit(cReview,2,2,22,78,.T.,'',nFormWidth)
              SET CURSOR OFF
              cReview := STRTRAN(cReview,CHR(141))+""
              @1,4 to 1,50
              LOOP
            case nNextAction = 3
              lOk2Print := .f.
            case nNextAction = 4
              lPauseFirst := .f.
            case nNextAction = 5 .or. nNextAction = 0
              lOk2Print := .f.
              lIsDone   := .t.
          endcase
          exit
        enddo
        unbox(cBox1)
      ENDIF
      if lOk2Print
        @11,35 say "               "
        @12,35 say "Imprimiendo ..."
        SET CONSOLE OFF
        IF cDestination == "PRINTER"
          SET PRINT ON
          ?cReview
          SET PRINT OFF
          SET PRINTER TO
          SET PRINTER TO (sls_prn())
        ELSE
          FWRITE(nOutHandle,cReview+chr(13)+chr(10))
        ENDIF
        SET CONSOLE ON
        @12,35 say "             "
        @11,35 say "Buscando ... "
      ENDIF
      if inkey()= 27
         exit
      else
         clear typeahead
      endif
      skip
      if !lSingle
        LOCATE WHILE (inkey()#27) FOR EVAL(bLocater)
      else
        exit
      endif
  ENDDO
  unbox(cLookingBox)
  IF cDestination == "IMPRESORA"
    SET PRINT OFF
    SET PRINTER TO
    SET PRINTER TO (sls_prn())
  ELSE
    FCLOSE(nOutHandle)
  ENDIF
  ERASE (getdfp()+cAltFile)
  EXIT
ENDDO
setkey(-9)
CLEAR TYPEAHEAD
RESTSCREEN(0,0,24,79,cUnderScreen)
return nil

*========================================================
static function sfll_makeh(u_express,u_descrip,u_keys)
local nCount
local nUserDef  := iif(u_express#nil,min(30,len(u_express)),0)
LOCAL aHelp     := array(20+nUserDef)

aHelp[1] := "Ayuda para crear formularios"
aHelp[2] := "   "
aHelp[3] := "Escriba el texto de la carta como ud. desear¡a que aparezca."
aHelp[4] := "Pulse F2 para insetar campos de la bas de datos (p.e.,NOMBRE)"
aHelp[5] := "en el lugar que quiere que aparezcan. Cuando se impriman, los"
aHelp[6] := "campos ser n reemplazados por el contenido de la base de datos."
aHelp[7] := "(los campos insertados est n entre ® ¯ )   "
aHelp[8] := "   "
aHelp[9] := "Teclas que tienen una funci¢n en la edici¢n:"
aHelp[10] := "Ctrl-Y          Borra hasta el fin de la l¡nea"
aHelp[11] := "Ctrl-T          Borra una palabra a la derecha"
aHelp[12] := "Ctrl-B          Reformatea el p rrafo activo"
aHelp[13] := "F10             Graba y sale"
aHelp[14] := "Escape          Sale - sin grabar"
aHelp[15] := "F2              Inserta un campo de la lista"
aHelp[16] := "F3              Inserta la fecha actual"
aHelp[17] := "F4              Inserta un salto de p gina"
for nCount = 1 to nUserDef
  aHelp[17+nCount] := u_descrip[nCount]
next
aHelp[17+nUserDef+1] := "As¡ como las teclas de movimiento del cursor."
aHelp[17+nUserDef+2] := "  "
aHelp[17+nUserDef+3] := "  ........pulse una tecla"
return aHelp



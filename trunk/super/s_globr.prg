#define REP_TYPEIN      1
#define REP_UPPER       2
#define REP_LOWER       3
#define REP_PROPER      4
#define REP_CANCEL      5

FUNCTION globrep(aFieldNames,aFieldDesc)

local aFieldTypes,aFieldLens,aFieldDeci
local aTagged       := {}
local nOldCursor    := SETCURSOR(0)
LOCAL cOldcolor     := SETCOLOR()
local nIndexOrder   := INDEXORD()
local cInScreen     := savescreen(0,0,24,79)
local cTargetField  := ""
local NTargetField  := 0
local cOtherField   := ""
local bReplBlock
local nMainMenu,nOtherField
LOCAL nReplaceType,cInfoBox
LOCAL expRepl,cPicture,nQueryType,bQuery
local nReplaced

IF !used()
  msg("No hay bases de datos en uso")
  RETURN ''
ENDIF

if aFieldNames==nil .or. aFieldDesc==nil
  aFieldNames  := getfields()
  aFieldDesc   := getfields()
endif

aFieldTypes := array(len(aFieldNames))
aFieldLens  := array(len(aFieldNames))
aFieldDeci  := array(len(aFieldNames))
Fillarr(aFieldNames,aFieldTypes,aFieldLens,aFieldDeci)

Setcolor(sls_normcol())

@0,0,24,79 BOX sls_frame()
Setcolor(sls_popmenu())
@1,1,6,35 BOX sls_frame()
@18,1,23,78 BOX sls_frame()
@1,5 SAY '[Reemplazo/Modificaci¢n]'

*- do the main loop
DO WHILE .T.
  *- the menu
  Setcolor(sls_popmenu())
  @2,3 PROMPT "Seleccione el campos a Modificar"
  @3,3 PROMPT "Opciones de Reemplazo"
  @4,3 PROMPT "Ejecutar el Reemplazo"
  @5,3 PROMPT "Salir"
  MENU TO nMainMenu
  
  DO CASE
  CASE nMainMenu = 1
    Scroll(19,2,22,77,0)
    nTargetField := mchoice(aFieldDesc,05,29,16,53,"[Campos a Reemplazar]")
    IF nTargetField > 0
      nReplacetype = 0
      IF aFieldTypes[nTargetField] == "M"
        msg("No se pueden hacer reemplazos en campos MEMO")
        nTargetField := 0
      ELSE
        @20,3 SAY "Reemplazo/modificaci¢n de Campo : "+aFieldNames[nTargetField]
        cTargetField := aFieldNames[nTargetField]
        bReplBlock := nil
      ENDIF
    ENDIF
  CASE nMainMenu = 2 .AND. nTargetField > 0
      nReplacetype := menu_v("Reemplazar campo <"+cTargetField+'> con:',;
                      "Valor a escribir            ",;
                      "May£scula",;
                      "Min£scula",;
                      "Primera letra may£scula     ",;
                      "Cancelar")
      DO CASE
      CASE nReplacetype = REP_TYPEIN
        cPicture := ""
        DO CASE
        CASE aFieldTypes[nTargetField]== "C"
          expRepl  := space(aFieldLens[nTargetField])
          cPicture := "@S20"
        CASE aFieldTypes[nTargetField] == "N"
          expRepl  := 0
          cPicture := repl("9",aFieldLens[nTargetField])
          if aFieldDeci[nTargetField] > 0
            cPicture := stuff(cPicture,;
                        aFieldLens[nTargetField]-aFieldDeci[ntargetField],1,".")
          endif
        CASE aFieldTypes[nTargetField] == "D"
          expRepl  := CTOD('  /  /  ')
        CASE aFieldTypes[nTargetField] == "L"
          expRepl  := .F.
        ENDCASE
        popread(.t.,"Reemplazar con:",@expRepl,cPicture)
        @21,3 SAY "Reemplazando con            : [VALOR INGRESADO POR EL USUARIO]"
        bReplBlock := {||expRepl}
      CASE nReplacetype < REP_CANCEL .AND. (aFieldTypes[nTargetField] # "C")
        msg("Must be type character to convert to Uppercase, Lowercase or Proper")
      CASE nReplacetype = REP_UPPER
        @21,3 SAY "Convirtiendo a            : May£sculas"
        bReplBlock := {||upper(fieldget(nTargetField))}
      CASE nReplacetype = REP_LOWER
        @21,3 SAY "Convirtiendo a            : Min£sculas"
        bReplBlock := {||lower(fieldget(nTargetField))}
      CASE nReplacetype = REP_PROPER
        @21,3 SAY "Convirtiendo a            : Primer letra May"
        bReplBlock := {||proper(fieldget(nTargetField))}
      ENDCASE
  CASE nMainMenu = 2 .AND. nTargetField = 0
      msg("Select target field")
  CASE nMainMenu = 3 .AND. nTargetField > 0 .and. bReplBlock#nil
      nQueryType := menu_v("[Selecci¢n de Registros]",;
                           "Todos los registros     ",;
                           "Registros con consulta  ",;
                           "Registros marcados      ",;
                           "Cancelar")
      DO CASE
      CASE nQueryType = 2
        IF !EMPTY(sls_query()) .AND. messyn("¨Modifica la Consulta activa?")
          QUERY(aFieldNames,aFieldNames,aFieldTypes)
        ELSE
          QUERY(aFieldNames,aFieldNames,aFieldTypes)
        ENDIF
        if !empty(sls_query())
          bQuery := sls_bquery()
        endif
        @22,3 SAY "Registros reemplazados    : REGISTROS CONSULTADOS"
      CASE nQueryType = 3
        tagit(aTagged)
        if len(aTagged) > 0
          bQuery := {||ascan(recno(),aTagged)>0}
        endif
        @22,3 SAY "Registros reemplazados    : RECORDS MARCADOS "
      CASE nQueryType = 0 .OR. nQueryType =4
        bQuery := nil
      OTHERWISE
        bQuery := {||.t.}
        @22,3 SAY "Registros reemplazados    : TODOS LOS REGISTROS "
      ENDCASE
      IF bQuery#nil .and. messyn("¨Ejecuta el reemplazo? (Los cambios ser n permamentes)")
        IF SFIL_LOCK(5,.T.,"No se puede bloquear el archivo. ¨Reintenta?")
           *- save index order and set order to 0 for a faster replace
           SET ORDER TO 0
           cInfoBox := makebox(5,19,13,55)
           @ 5,21 SAY "[Reemplazo]"
           @ 7,21 SAY "Registros Totales"
           @ 9,21 SAY "N§ Comprobados"
           @ 11,21 SAY "N§ de Reemplazos"
           @7,41 say trans(recc(),'9999999999')
           GO TOP
           locate for eval(bQuery)
           nReplaced := 0
           while found()
             nReplaced++
             @9,41  say trans(recno(), '9999999999')
             @11,41 say trans(nReplaced, '9999999999')
             fieldput(nTargetField,eval(bReplBlock))
             continue
           end
           *- put the index order back , and annouce completion
           SET ORDER TO nIndexOrder
           unlock
           unbox(cInfoBox)
           msg("Replacement Done!")
           nReplacetype   := 0
           nTargetField   := 0
        endif
      ENDIF
      Scroll(19,2,22,77,0)
  CASE nMainMenu = 3 .AND. (nTargetField = 0 .or. bReplBlock==nil)
      msg("Select target field and define replacement options")
  CASE nMainMenu = 4 .OR. nMainMenu = 0
    restscreen(0,0,24,79,cInscreen)
    setcolor(cOldColor)
    SETCURSOR(nOldCursor)
    exit
  ENDCASE
ENDDO
RETURN ''
//--------------------------------------------------------
static function getfields
local aFieldarr := array(fcount())
aFields(aFieldarr)
return aFieldArr



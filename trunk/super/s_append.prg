
#include "inkey.ch"

static nFromArea
static nIntoArea
static cIntoAlias,cFromAlias
static bFromQuery
static aTagged
static nFilterType
static aIntoFields,aIntoTypes,aIntoLens,aIntoDecs
static aFromFields,aFromTypes,aFromLens,aFromDecs,aFromDesc
static nFromFields,nIntoFields
static aConversions
static oBrowse


FUNCTION appendit

local cOldQuery   := sls_query()
local cOldColor   := setcolor(sls_normcol())
local cOldScreen  := savescreen(0,0,24,79)
local nMainSelection := 0
local nIter
local lOpenAlready := .f.

nFromArea   := 0
nIntoArea   := 0
aTagged     := {}

nFilterType := 3
nIntoArea   := SELECT()
cIntoAlias  := ALIAS()
cFromAlias  := ""
aConversions:= {}


IF !USED()
  msg("Se necesita DBF abierta")

else
  nIntoFields := fcount()
  aIntoFields := array(fcount())
  aIntoTypes  := array(fcount())
  aIntoLens   := array(fcount())
  aIntoDecs   := array(fcount())
  Afields(aIntoFields,aIntoTypes,aIntoLens,aIntoDecs)

  drawmain()
  do while .t.
     Setcolor(sls_popmenu())
     @19,2 SAY "[Importar en:]  "+PADR(cIntoAlias,40)
     @20,2 SAY "[Importar desde:]  "+PADR(cFromAlias,40)
     @21,2 SAY "[Tipo de Filtro:]  "+{"Consulta        ",;
                                      "Reg. Marcados   ",;
                                      "Ninguno         "}[nFilterType]

     *- do the menu
     @02,3 PROMPT "Seleccionar Archivo a importar"
     @03,3 PROMPT "Campos Coincidentes"
     @04,3 PROMPT "Importar"
     @05,3 PROMPT "Fin"
     @07,3 PROMPT "Marcar registros a agregar"
     @08,3 PROMPT "Construir o modificar Consulta"
     MENU TO nMainSelection
     Setcolor(sls_normcol())
     do case
     case nMainSelection==1

       aTagged  := {}
       if nFromarea > 0 .and. !lOpenAlready
          SELECT (nFromArea)
          USE
       endif
       SELECT (nIntoArea)
       nFromArea := 0

       lOpenAlready := .f.
       if messyn("Selecci¢n del Archivo a Importar","Del directorio actual","Escribir el path y nombre del archivo")
          cFromAlias   := popex('*.dbf','[Agregar Desde:]')
       elseif lastkey()#27
          cFromAlias   := space(30)
          popread(.t.,"Escriba el nombre del archivo",@cFromAlias,"@K")
          cFromAlias := UPPER(alltrim(cFromAlias))
          cFromAlias += iif(!".DBF"$cFromAlias,".DBF","")
          if !file(cFromAlias)
            msg(cFromAlias,"no existe")
            cFromAlias := ""
          endif
       endif
       cFromAlias   := LEFT(cFromAlias,AT('.',cFromAlias)-1)

       IF !EMPTY(cFromAlias) .AND. ;
            !(strip_path(cFromAlias,.t.)==cIntoAlias) .and. ;
            (select(upper(strip_path(cFromAlias,.t.)))=0 )
         SELECT 0
         IF SNET_USE(cFromAlias,strip_path(cFromAlias,.t.),.f.,5,.t.,"No se puede abrir "+cFromAlias+". ¨Reintenta?")
           nFromArea = SELECT()
           nFromFields = Fcount()
           aFromFields := array(nFromFields)
           aFromTypes  := array(nFromFields)
           aFromLens   := array(nFromFields)
           aFromDecs   := array(nFromFields)
           aFromDesc   := array(nFromFields)
           Afields(aFromFields,aFromTypes,aFromLens,aFromDecs)

           FOR nIter = 1 TO nFromFields
             aFromDesc[nIter] = padr(aFromFields[nIter],10)+'   '+;
                                aFromTypes[nIter]+'   '+;
                                TRANS(aFromLens[nIter],"999")+'   '+;
                                TRANS(aFromDecs[nIter],"999")
           NEXT
         ELSE
           msg("Falla al abrir "+cFromAlias,"saliendo del procedimiento APPEND.")
           SELECT (nIntoArea)
           cFromAlias := ""
           nFromArea  := 0
         endif
       ELSEIF ( strip_path(cFromAlias,.t.)==cIntoAlias)
         MSG("No se puede importar una base de datos desde s¡ misma...")
         cFromAlias := ""
         nFromArea  := 0
       ELSEIF (select(upper(strip_path(cFromAlias,.t.)))#0 )
         nFromArea  := select(upper(strip_path(cFromAlias,.t.)))
         select (nFromArea)
         nFromFields = Fcount()
         aFromFields := array(nFromFields)
         aFromTypes  := array(nFromFields)
         aFromLens   := array(nFromFields)
         aFromDecs   := array(nFromFields)
         aFromDesc   := array(nFromFields)
         Afields(aFromFields,aFromTypes,aFromLens,aFromDecs)

         FOR nIter = 1 TO nFromFields
           aFromDesc[nIter] = padr(aFromFields[nIter],10)+'   '+;
                              aFromTypes[nIter]+'   '+;
                              TRANS(aFromLens[nIter],"999")+'   '+;
                              TRANS(aFromDecs[nIter],"999")
         NEXT
         lOpenAlready := .t.
       ENDIF
       bFromQuery  := {||.t.}
       SELECT (nIntoArea)
       nFilterType := 3
       aConversions:= {}

     case nMainSelection==2  .and. nFromArea > 0  // match fields
         sfim_import()
     case nMainSelection==2
         msg("Seleccione Archivo a Importar")
     case nMainSelection==3 // do import
        IF nFromArea > 0 .and. len(aConversions) > 0
         IF messyn("¨Comienza con la importaci¢n?")
           sfim_doit()
           SELECT (nFromArea)
           USE
           bFromQuery  := {||.t.}
           nFilterType := 3
           SELECT (nIntoArea)
           nFromArea   := 0
           cFromAlias  := ""
           aConversions:= {}
         else
           msg("Seleccione Archivo a Importar","y campos coincidentes")
         ENDIF
        endif
     case nMainSelection==4 // quit
         exit
     case nMainSelection==5 .and. nFromArea > 0 // tag
           SELECT (nFromArea)
           tagit(aTagged)
           if len(aTagged) > 0
             nFilterType := 2
             bFromQuery = {||(ascan(aTagged,recno())> 0)}
           else
             nFilterType := 3
             bFromQuery  := {||.t.}
           endif
           SELECT (nIntoArea)

     case nMainSelection==6 .and. nFromArea > 0 // query
           SELECT (nFromArea)
           *- build query for other area
           sls_query("")
           QUERY()
           if !empty(sls_query() )
             nFilterType := 1
             bFromQuery := &("{||"+sls_query()+"}" )
           else
              nFilterType := 3
              bFromQuery  := {||.t.}
           endif
           sls_query( cOldQuery)
           SELECT (nIntoArea)
     case ISPART(nMainSelection,5,6)
         msg("Seleccione Archivo a Importar")
     endcase

  enddo

endif
if nFromarea > 0 .and. !lOpenAlready
   SELECT (nFromArea)
   USE
endif
SELECT (nIntoArea)
sls_query(cOldQuery)
setcolor(cOldColor)
RESTSCREEN(0,0,24,79,cOldScreen)

nFromArea  := nil ;nIntoArea  := nil;cIntoAlias := nil;cFromAlias := nil
bFromQuery := nil ;aTagged    := nil;nFilterType:= nil;aIntoFields:= nil
aIntoTypes := nil ;aIntoLens  := nil;aIntoDecs := nil ;aFromFields:= nil
aFromTypes := nil ;aFromLens := nil ;aFromDecs := nil ;aFromDesc := nil
nFromFields := nil ;nIntoFields := nil ; aConversions := nil ; oBrowse := nil

RETURN ''

//==================================================================

static FUNCTION sfim_import
local lOldExact
local nIter
local nExistMatch
local nElement := 1
local cUnder := savescreen(1,1,23,78)
local cEmpty := repl(chr(177),50)
local expGet,cGetPic
local cWorkType
local nWorklen
local expTemp
local nLkey

SELECT (nIntoArea)
if empty(aConversions)
  aConversions := array( (cIntoAlias)->(fcount())     )
  afill(aConversions,"")
endif

lOldExact = SET(_SET_EXACT,.t.)


FOR nIter = 1 TO nFromFields
  //nExistMatch = Ascan(aFromFields,aIntoFields[nIter])
  nExistMatch = Ascan(aIntoFields,aFromFields[nIter])
  IF nExistMatch > 0
    IF aFromTypes[nIter]==aIntoTypes[nExistMatch] .and.;
       aFromLens[nIter]==aIntoLens[nExistMatch] .and.;
       aFromDecs[nIter]==aIntoDecs[nExistMatch]
          aConversions[nExistMatch] := aFromFields[nIter]
    ENDIF
  ENDIF
NEXT

oBrowse := tbrowseNew(2,2,19,77)
oBrowse:headsep := "Ä"
oBrowse:colsep := "³"
oBrowse:addcolumn(tbcolumnNew("Campos del Archivo destino",;
        {||padr(aIntofields[nElement],15)+iif(empty(aConversions[nElement]),"    "," =>  " )} ))
oBrowse:getcolumn(1):width := 20
oBrowse:addcolumn(tbcolumnNew("Agregar desde los campos",{||padr(aConversions[nElement],50,chr(177))} ))
oBrowse:getcolumn(2):width := 50
oBrowse:skipblock := {|n|askip(n,@nElement)}
oBrowse:gobottomblock := {||nElement := nIntoFields}
oBrowse:gotopblock := {||nElement := 1}

drawbrz()

DO WHILE .T.
  while !oBrowse:stabilize()
  end

  nLkey := INKEY(0)

  DO CASE
  CASE nLkey = K_DOWN
    oBrowse:down()
  CASE nLkey = K_PGDN
    oBrowse:pagedown()
  CASE nLkey = K_END
    oBrowse:gobottom()
  CASE nLkey = K_UP
    oBrowse:up()
  CASE nLkey = K_PGUP
    oBrowse:pageup()
  CASE nLkey = K_HOME
    oBrowse:gotop()
  CASE (nLkey > 48 .AND. nLkey < 58) .OR. ;
      (nLkey > 64 .AND. nLkey < 91) .OR. ;
      (nLkey > 96 .AND. nLkey < 127)
    sfim_alpha(nLkey,@nElement)
    oBrowse:refreshall()
  CASE nLkey = K_ENTER
    sfim_match(aFromDesc,nElement)
    oBrowse:refreshall()
  CASE nLkey = K_ESC
    EXIT
  CASE nLkey = K_F10
    EXIT
  CASE nLkey = K_F3  .and. !empty(aConversions[nElement] )    // extended expression
    IF MESSYN("¨Extiende "+aConversions[nElement]+" como una expresi¢n compleja?")
        select (nFromArea)
        aConversions[nElement] := BUILDEX("Importar Valor",aConversions[nElement],.t.)
        expTemp     := &( aConversions[nElement] )
        nWorkLen  := varlen(expTemp)
        cWorktype := valtype(expTemp)
        CHECKVAL(nElement,cWorktype,nworkLen)
        select (nIntoArea)
    ENDIF
    oBrowse:refreshall()
  CASE nLkey = K_F2      // type it in
    do case
    case aIntoTypes[nElement] =="C"
      expGet   := space(aIntoLens[nelement])
      cGetPic  := "@S25"
    case aIntoTypes[nElement] =="D"
      expGet   := date()
      cGetPic  := ""
    case aIntoTypes[nElement] =="L"
      expGet   := .f.
      cGetPic  := "Y"
    case aIntoTypes[nElement] =="N"
      expGet   := 0
      cGetPic  := repl("9",aIntoLens[nElement])
      if aIntoDecs[nElement] > 0
        cGetPic  := stuff(cGetPic,aIntoLens[nElement]-aIntoDecs[nElement],1,".")
      endif
    case aIntoTypes[nElement] =="M"
      expGet   := space(100)
      cGetPic  := "@S25"
    endcase
    IF MESSYN("¨Escribe un "+aIntoFields[nElement]+" valor a importar?")
      popread(.t.,"Ingrese :",@expGet,cGetPic)
      //aConversions[nElement] := "["+trans(expGet,"")+"]"
      IF lastkey()#27
        do case
        case aIntoTypes[nElement] =="C"
          aConversions[nElement] := "["+expGet+"]"
        case aIntoTypes[nElement] =="D"
          aConversions[nElement] := "CTOD("+DTOC(expGet)+")"
        case aIntoTypes[nElement] =="L"
          aConversions[nElement] := IIF(expGet,".t.",".f.")
        case aIntoTypes[nElement] =="N"
          aConversions[nElement] := trans(expGet,cGetPic)
        case aIntoTypes[nElement] =="M"
          aConversions[nElement] := "["+expGet+"]"
        endcase
      endif
    ENDIF
    oBrowse:refreshall()
  ENDCASE
ENDDO
SET(_SET_EXACT,lOldExact)
restscreen(1,1,23,78,cUnder)
return nil

//==================================================================


static FUNCTION sfim_match(aFromDesc,nElement)
local cUnder := makebox(0,40,24,78,Setcolor(),0)
local nChoice := 0
local cWorkType
local nWorklen
local expGet1,expGet2

select (nFromArea)

@ 3,41 TO 3,77
@ 3,40 SAY 'Ã'
@ 3,78 SAY '´'

@ 20,41 TO 20,77
@ 20,40 SAY 'Ã'
@ 20,78 SAY '´'
@ 2, 43 SAY "Campo       Tipo   Long   Dec"
@ 1,42 SAY cFromAlias+" Lista de Campos"
@ 21,42 SAY "Seleccionar campos a importar "
@ 22,43 SAY padr(aIntoFields[nElement],10)+'   '+;
                 aIntoTypes[nElement]+'   '+;
                 TRANS(aIntoLens[nElement],"999")+'   '+;
                 TRANS(aIntoDecs[nElement],"999")
att(22,43,22,73,14)
@ 23,42 SAY "O pulse ESCAPE para no seleccionar"
nChoice := SACHOICE(4,43,19,77,aFromDesc)
IF nChoice > 0
  aConversions[nElement] := aFromFields[nChoice]
  cWorktype := aFromTypes[nChoice]
  nWorkLen  := aFromLens[nChoice]
  checkval(nElement,cWorktype,nWorkLen)
  *- comment this out if you don't want to call BUILDEX
ELSE
  aConversions[nElement] = ""
ENDIF
select (nIntoArea)
unbox(cUnder)
RETURN nil

//==================================================================

STATIC FUNCTION CHECKVAL(nelement,cWorktype,nworkLen)
local expGet1,expGet2
do case
case aIntoTypes[nElement]=="C"
  do case
  case cWorktype$"CM"
     IF nWorkLen > aIntoLens[nElement]
       if MESSYN("La longitus de los campos fuentes exceden a los campos destino",;
                 "Truncar a la Derecha","Truncar a la Izquierda")
          aConversions[nElement]:="LEFT("+aConversions[nElement]+","+;
                 alltrim(str(aIntoLens[nElement]))+")"
       else
          aConversions[nElement]="SUBST("+aConversions[nElement]+",-"+;
                  alltrim(str(aIntoLens[nElement]))+")"
       endif
     ENDIF

  case cWorktype=="D"
     IF aIntoLens[nElement] < 8
       msg(aIntoFields[nElement]+" es menor que 8 caracteres.",;
            "se requieres 8 o m s caracteres")
       aConversions[nElement]=""
     else
       if messyn("Convertir un campo FECHA a CARACTER Usar:",;
                 "MM/DD/AA","AAAAMMDD")
         aConversions[nElement]="DTOC("+aConversions[nElement]+")"
       ELSE
         aConversions[nElement]="DTOS("+aConversions[nElement]+")"
       ENDIF
     endif
  case cWorktype=="L"
      expGet1 := space(aIntoLens[nElement])
      expGet2 := expGet1
      popread(.t.,"Convertir un valor l¢gico TRUE al caracter :",@expGet1,"",;
                  "Convertir un valor l¢gico FALSE al caracter :",@expGet2,"")
      aConversions[nElement]="IIF("+aConversions[nElement]+;
                  ",["+expGet1+"],["+expGet2+"])"
  case cWorktype=="N"
      if aIntoLens[nElement] < nWorkLen
          IF MESSYN("La longitud del campo Fuente excede al campo Destino",;
                    "Truncar el resultado","Abandonar")
             aConversions[nElement]="SUBST(STR("+aConversions[nElement]+"),-"+;
                      alltrim(str(aIntoLens[nElement]))+")"
          else
             aConversions[nElement]=""
          endif
      else
        aConversions[nElement]="STR("+aConversions[nElement]+")"
      endif
  endcase
case aIntoTypes[nElement]=="M"
  do case
  case cWorktype=="D"
      if messyn("Convirtiendo un campo FECHA a campo CARACTER. Usar:",;
                "MM/DD/AA","AAAAMMDD")
        aConversions[nElement]="DTOC("+aConversions[nElement]+")"
      ELSE
        aConversions[nElement]="DTOS("+aConversions[nElement]+")"
      ENDIF
  case cWorktype=="L"
      expGet1 = space(50)
      expGet2 = expGet1
      popread(.t.,"Convertir TRUE l¢gico a Caracter  :",@expGet1,;
                  "Convertir FALSE l¢gico a Caracter :",@expGet2)
      aConversions[nElement]="IIF("+aConversions[nElement]+;
                  ",["+expGet1+"],["+expGet2+")"
  case cWorktype=="N"
       aConversions[nElement]="STR("+aConversions[nElement]+")"
  endcase
case aIntoTypes[nElement]=="D" .and. (!cWorktype=="D")
  MSG("Ha intentado mover un campo fecha en uno no fecha",;
      "Seleccione 'Extender una expresi¢n compleja' y convertir",;
      "a fecha primero")
   aConversions[nElement]=""
case aIntoTypes[nElement]=="L" .and. (!cWorktype=="L")
  msg("Ha intentado mover un campo l¢gico en",;
      "un campo no l¢gico. No se puede hacer!")
   aConversions[nElement]=""
case aIntoTypes[nElement]=="N"
  do case
  case !cWorktype=="N"
    MSG("Ha intentado mover un valor no Num‚rico en un campo Num‚rico",;
        "Seleccione 'Extender una expresi¢n compleja' y convertir",;
        "a Num‚rico primero")
     aConversions[nElement]=""
  case cWorktype=="N"
    aConversions[nElement]="VAL(STR("+aConversions[nElement]+","+;
                         alltrim(str(aIntoLens[nElement]))+","+;
                         alltrim(str(aIntoDecs[nElement]))+"))"
    MSG("Nota: Si el tama¤o del campo destino es menor que el ",;
        "tama¤o del valor a reemplazar, resultar  un valor CERO.")
  endcase
endcase
return nil


//==================================================================

static FUNCTION sfim_alpha(nKey,nElement)
local cKey        := upper(chr(nKey))
local nTmpElement := IIF(nElement=nIntoFields,1,nElement+1)

DO WHILE !(nTmpElement=nElement)
  IF LEFT(aIntoFields[nTmpElement],1) == cKey
    nElement := nTmpelement
    EXIT
  ENDIF
  nTmpElement = IIF(nTmpElement=nIntoFields,1,nTmpElement+1)
ENDDO
RETURN ''

//==================================================================
static FUNCTION sfim_doit

LOCAL nAppCount
LOCAL cUnder
LOCAL nNtxOrder,nIter

local aReplacewith := {}
local aReplace  := {}
local cStripAlias := strip_path(cFromAlias,.t.)

for nIter = 1 TO nIntoFields
  IF !EMPTY(aConversions[nIter])
    aadd(aReplacewith, &("{||"+aConversions[nIter]+"}" ) )
    aadd(aReplace, FieldWblock(aIntoFields[nIter],nIntoArea) )
  ENDIF
NEXT

nNtxOrder := INDEXORD()
SET ORDER TO 0
nAppCount := 0
cUnder    := makebox(6,20,14,61)

@ 9,20 SAY 'Ã'
@ 9,62 SAY '´'
@ 7,23 SAY "Agregando registros"
@ 8,23 SAY "desde "+cStripAlias+" en "+cIntoAlias
@ 9,21 SAY "ÄÄÄÄ[ESC detiene el proceso ]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 11,23 SAY "0 registros agregados"
CLEAR TYPEAHEAD
SELECT (nFromArea)
LOCATE FOR eval(bFromQuery)
DO WHILE FOUND()
  IF inkey() = 27
    IF messyn("¨Detiene el proceso?")
      EXIT
    ENDIF
    CLEAR TYPEAHEAD
  ENDIF
  nAppCount++
  @ 11,23 SAY nAppCount
  ??" Registros Agregados"


  SELECT (nIntoArea)
  if SADD_REC(5,.t.,"Network error - No se pueden agregar registros. ¨Reintenta?")
     FOR nIter = 1 to len(aReplace)
       eval(aReplace[nIter],(cStripAlias)->(eval(aReplacewith[nIter]))  )
     NEXT
     unlock
  else
     msg("No se pueden agregar registros - Regreso al Men£")
     SELECT (nFromArea)
     exit
  endif
  SELECT (nFromArea)
  CONTINUE
ENDDO

unbox(cUnder)
SET ORDER TO nNtxOrder
return nil

//==================================================================

static proc drawbrz
@ 1,1,23,78 BOX "ÚÄ¿³ÙÄÀ³ "
@ 1,3 SAY "[Campos coincidentes]"
@ 20,1 SAY 'Ã'
@ 20,78 SAY '´'
@ 2,3 SAY "Campos Archivo Destino     Agregar desde el Archivo los campos:"
@ 20,2 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 21,3 SAY "< CR>  Selecciona Campos Destino"
@ 22,3 SAY "<F2> Tipear Valor a Importar  <F3> Valor a Importar Complejo <F10> Menu    "
return

//==================================================================
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

//==================================================================

STATIC PROC DRAWMAIN
Setcolor(sls_normcol())
@ 0,0,24,79 BOX sls_frame()
Setcolor(sls_popmenu())
@1,1,9,25 BOX sls_frame()
@18,1,23,78 BOX sls_frame()
@1,5 SAY '[Agregar]'
@19,2 SAY "[Importar en:]"
@20,2 SAY "[Importar desde:]"
@21,2 SAY "[Tipo de Filtro:]"
RETURN


//---------------------------------------------------------------------
#include "inkey.ch"
#include "dbstruct.ch"

#define BY_WEEK    1
#define BY_WEEKTD  2
#define BY_MONTH   3
#define BY_MONTHTD 4
#define BY_YEAR    5
#define BY_YEARTD  6
#define BY_USERDEF 7

#define ASTRUC_START 1
#define ASTRUC_END   2
#define ASTRUC_COUNT 3
#define ASTRUC_SUM   4
#define ASTRUC_AVG   5



//---------------------------------------------------------------------
FUNCTION timeper( aFieldNames,aFieldDesc)

local aRanges
local nRangeType := 0
local nWeekStart
local expAsOf
local dStartingDate
local dEndingDate
local cRangeTxt  := "SIN SELECCION"

local cNumbFieldName := ""
local cDateFieldName := ""
local nNumfLen,nNumfDec

local nOldCursor
local lOldExact
local aFieldTypes,aFieldLens, aFieldDeci
local aDateFields := {}
local aNumbFields := {}
local nFields,nDateFields
local cInScreen,cOldColor
local nIndexOrd := indexord()
local nOldArea  := select()
local nMenuChoice
local nSelection
local i

nNumfLen      := 0
nNumfDec      := 0
cNumbFieldName := ""

IF VALTYPE(aFieldNames)+VALTYPE(aFieldDesc)<>"AA"
   nFields     := Fcount()
   aFieldNames := array(nFields)
   aFieldTypes := array(nFields)
   aFieldLens  := array(nFields)
   aFieldDeci  := array(nFields)
   aFieldDesc  := array(nFields)

   Afields(aFieldNames,aFieldTypes,aFieldLens,aFieldDeci)
   Afields(aFieldDesc)
else
   nFields     := len(aFieldNames)
   aFieldTypes := array(nFields)
   aFieldLens  := array(nFields)
   aFieldDeci  := array(nFields)
   FILLARR(aFieldNames,aFieldTypes,aFieldLens,aFieldDeci)
endif

for i = 1 to nFields
  if aFieldTypes[i]=="D"
    aadd(aDateFields,aFieldNames[i])
  elseif aFieldTypes[i]=="N"
    aadd(aNumbFields,aFieldNames[i])
  endif
next
if len(aDateFields) = 0
  msg("No hay campos fecha en esta base de datos")
  RETURN ''
endif

* save screen,color
cOldColor  := setcolor(sls_normcol())
cInScreen  := savescreen(0,0,24,79)
lOldExact  := setexact(.t.)

*-- draw screen
@0,0,24,79 BOX sls_frame()
Setcolor(sls_popcol())
@1,1,09,50 BOX sls_frame()
@1,5 SAY '[Análisis Periódico]'
@20,1,23,78 BOX sls_frame()
@21,2 say "Análisis en fechas contenidas en campo:"
@22,2 say "Suma/media en valores de campos       :"

SET INDEX TO
nOldCursor := iif(set(16)=0,.f.,.t.)
lOldExact  := setexact()

*-- Main Loop
DO WHILE .T.
  @21,43 say cDateFieldName
  @22,43 say cNumbFieldName
  *- indicate if query is active
  @2,60 SAY IIF(EMPTY(sls_query()),"[Sin Consulta]","[Con Consulta]")
  
  *- do a menu
  Setcolor(sls_popmenu())
  @02,3 PROMPT "Tipo de Rango =>"
  ??"    "+padr(cRangeTxt,20)
  @03,3 PROMPT "Elección campo FECHA"
  @04,3 PROMPT "Elección campo NUMERICO"
  @05,3 PROMPT "Hacer Consulta"
  @06,3 PROMPT "Ejecutar el Análisis"
  @07,3 PROMPT "Salir"

  menu to nMenuChoice
  do case
  case nMenuChoice = 1  // range type
       aRanges := getrange(@nRangeType,@nWeekStart,@expAsof,;
                         @dStartingDate,@dEndingDate,@cRangeTxt)

       if aRanges==nil
         nRangetype := 0
         cRangeTxt := 'SIN SELECCION'
       endif
       cRangeTxt := padr(cRangetxt,13)
  case nMenuChoice = 2      // select date field
      nSelection := mchoice(aDateFields,06,23,16,59,;
                    "[Elija el campo FECHA para agrupar]")
      IF nSelection > 0
        cDateFieldName = aDateFields[nSelection]
        scroll(21,2,22,77,0)
        @21,2 say "Análisis en fechas contenidas en campo:"
        @22,2 say "Suma/media de valores en campos       :"
      endif
  case nMenuChoice = 3
     nNumfLen      := 0
     nNumfDec      := 0
     cNumbFieldName := ""
     if len(aNumbfields) > 0
          *- get numeric field for summing and averaging within periods
          *- ask for the numeric field to sum/average
          nSelection := mchoice(aNumbFields,06,14,16,65,;
                      "Seleccione el campo numérico para el Análisis Periódico")
          IF nSelection > 0
            cNumbFieldName := aNumbFields[nSelection]
            scroll(21,2,22,77,0)
				@21,2 say "Análisis en fechas contenidas en campo:"
            @22,2 say "Suma/media de valores en campos       :"
               nSelection := ascan(aFieldNames,cNumbFieldName)
            nNumfLen   := aFieldLens[nSelection]
            nNumfDec   := aFieldDeci[nSelection]
          ENDIF
     else
         msg("No hay campos numéricos es esta base de datos")
     endif
  case nMenuChoice = 4     // build query
        QUERY()
  case nMenuChoice = 5   .and. empty(cDateFieldName)
        msg("Seleccione un campo FECHA para el análisis")
  case nMenuChoice = 5  .and.  nRangetype = 0
        msg("Seleccione un tipo de rango para el análisis")
  case nMenuChoice = 5     // do the analysis
       doanalysis(aRanges,cDateFieldName,dStartingDate,dEndingDate,cNumbFieldName,nNumFDec,nWeekStart,nNumFLen)
       SET INDEX TO
       for i = 1 to len(aRanges)
         aRanges[i,ASTRUC_COUNT] := 0
         aRanges[i,ASTRUC_SUM  ] := 0
         aRanges[i,ASTRUC_AVG  ] := 0
       next
  case nMenuChoice = 6 .or. nMenuChoice = 0
       setcolor(cOldColor)
       setcursor(nOldCursor)
       setexact(lOldExact)
       restscreen(0,0,24,79,cInScreen)
       exit
  endcase
enddo
return nil


//---------------------------------------------------------------------
static function doanalysis(aRanges,cDateFieldName,dStartingDate,dEndingDate,;
                           cNumbFieldName,nNumfDec,nWeekStart,nNumFLen)
local bRangeQuery
local bQuery, bDateValue, bNumbValue
local cBox
local nCount  := 0
local i
local nElement

* Use Query ?
if !empty(sls_query())
  IF !messyn("¿Usa la consulta para seleccionar los registros?","No","Si")
    bQuery := sls_bquery()
  ENDIF
endif

bDateValue    := fieldblock(cDateFieldName)
if bQuery#nil
  bRangeQuery := {||eval(bDateValue)>=dStartingDate.AND.eval(bDateValue)<=dEndingDate.and. eval(bQuery) }
else
  bRangeQuery := {||eval(bDateValue)>=dStartingDate.AND.eval(bDateValue)<=dEndingDate}
endif
if !empty(cNumbfieldName)
  bNumbValue  := fieldblock(cNumbFieldName)
else
  bNumbValue  := {||0}
endif

GO TOP
cBox   := makebox(7,28,14,53)
@7,29 SAY '[Trabajando...]'

@9,30 SAY  "Llenando rangos destino"
@10,30 SAY  "Trabajando en reg:"
@12,32 say ""
for i = 1 to reccount()
  go i
  @12,30 SAY RECNO()
  ??' of '
  ??RECCOUNT()
  if eval(bRangeQuery)
    if (nElement := inrange( eval(bDateValue), aRanges )) > 0
      aRanges[nElement,ASTRUC_COUNT]++
      aRanges[nElement,ASTRUC_SUM]+=eval(bNumbValue)
    endif
  endif
  if inkey()=K_ESC
   EXIT
  endif
next
unbox(cBox)
IF !LASTKEY()=K_ESC
   IF !empty(cNumbfieldName)
     for i = 1 to len(aRanges)
       aRanges[i,5] := iif(aRanges[i,4]==0,0,;
                ROUND(aRanges[i,4]/aRanges[i,3],nNumfDec ) )
       //AEVAL(aRanges,{|e|e[5]:=iif(e[4]==0,0,ROUND(e[4]/e[3],nNumfDec ))} )
     next
   ENDIF

   showit(aRanges,nNumfDec,nNumFLen)
   IF !messyn("¿Envía los resultados a una DBF permanente?","No","Si")
       sendtodbf(aRanges,cNumbFieldName,nNumfDec)
   endif
ELSE
   msg("Proceso cancelado por el usuario...")
   UNBOX(cBox)
endif
return nil


//-------------------------------------------------------
static function inrange(dValue,aRanges)
return ascan(aRanges,{|e|dValue>=e[1].and.dValue<=e[2]})


//---------------------------------------------------------------------
static function viewprog(nRecc, nRecno)
IF !EOF()
  @10,30 SAY INT(100*(nRecno/nRecc))
  ??"% ejecutado"
ENDIF
RETURN ''

//---------------------------------------------------------------------
static function getrange(nRangeType,nWeekStart,expAsof,;
                         dStartingDate,dEndingDate,cRangeTxt)
LOCAL lAborted   := .f.
LOCAL aRanges

LOCAL aDays := { "Domingo",;
                 "Lunes",;
                 "Martes",;
                 "Miércoles",;
                 "Jueves",;
                 "Viernes",;
                 "Sábado"}

* get type of range to work with
nRangeType  := menu_v("[Tipo de Rango:]",;
                "A Por Semana","B Semana a una fecha","C Por Mes","D Mes a una fecha",;
                "E Por Año","F Año a una Fecha","G definida por el usuario","Q Fin                     ")
if nRangeType > 0 .and. nRangeType#8
   cRangeTxt := {"POR SEMANA","SEMANA A UNA FECHA","POR MES","MES A UNA FECHA",;
                "POR AÑO","AÑO A UNA FECHA","DEFINIDA POR EL USUARIO"}[nRangeType]

   IF nRangeType = BY_WEEK
       nWeekStart = mchoice(aDays,5,31,15,50,"[La semana comienza en :]")
       IF nWeekStart = 0
         lAborted = .t.
       ENDIF
   ELSEIF nRangeType = BY_WEEKTD
     WHILE !lAborted
       nWeekStart := mchoice(aDays,5,31,15,50,"[La semana comienza en :]")
       expAsOf    := DOW(DATE())
       expAsOf    := mchoice(aDays,5,31,15,55,"[Semana como en fecha :]")
       IF expAsOf = 0
         lAborted = .t.
       ELSEIF expAsOf < nWeekStart
         msg("El día elegido es menor que el de comienzo")
         LOOP
       ELSE
         EXIT
       ENDIF
     END
   ELSEIF nRangeType = BY_MONTH
   ELSEIF nRangeType = BY_MONTHTD
       expAsOf := DAY(DATE())
       IF !asof("Mes a la fecha de: ( 1-31 )","d¡a no válido",;
                @expAsOf,"",;
                {|d|!(d< 0 .OR. d> 31) } )
          lAborted := .t.
       ENDIF
   ELSEIF nRangeType = BY_YEAR
   ELSEIF nRangeType = BY_YEARTD
       expAsOf := DATE()
       IF !asof("Año a la fecha de:","El año está fuera del rango del sistema",;
                @expAsOf,"",;
                {|d|!(YEAR(d)<1900 .OR. YEAR(d)>1999) } )
          lAborted := .t.
       ENDIF
   ELSEIF nRangeType = BY_USERDEF
     aRanges := userdates()
     if aRanges #nil
      // sort date range array by starting date element
      aRanges := asort(aRanges,,,{|x,y|x[1] < y[1]})
      dStartingDate := aRanges[1,1]
      dEndingDate   := atail(aRanges)[2]
     endif
   ENDIF
else
   lAborted := .t.
endif

* determine starting and ending range
WHILE !lAborted .and. nRangeType#BY_USERDEF .and. nRangeType#8
  dStartingDate := BOYEAR(DATE())
  dEndingDate   := DATE()
  popread(.F.,"Comienza el análisis en fecha:",@dStartingDate,"",;
              "Termina el análisis en fecha: ",@dEndingDate,"")
  IF LASTKEY() = K_ESC
    lAborted = .t.
    exit
  ELSEIF EMPTY(dStartingDate) .OR. EMPTY(dEndingDate)
    msg("Es necesario ingresar datos en estos campos")
  ELSEIF dStartingDate >= dEndingDate
    msg("La fecha de finalización es menor o igual que la de comienzo")
  ELSE
    aRanges := fillranges(nRangeType,@dStartingdDate,dEndingDate,nWeekStart,expAsOf)
    EXIT
  ENDIF
END
return aRanges

//-------------------------------------------------------
static function asof(cMsg,cErrMsg,expAsOf,cPict,bValid)
local lValid := .f.
WHILE .T.
  popread(.F.,cMsg,@expAsOf,cPict)
  IF LASTKEY() = K_ESC
    EXIT
  ELSEIF !EVAL(bValid,expAsof)
    msg(cErrMsg)
  ELSE
    lValid := .t.
    EXIT
  ENDIF
END
return lValid

//-------------------------------------------------------
static function fillranges(nRangeType,dStartingdDate,dEndingDate,nWeekStart,expAsof)
local aRanges := {}
LOCAL dThisStart,dThisEnd,dNextStart
local cBox := makebox(9,20,14,60)

* adjust beginning date to earlier first date in period in which it falls
DO CASE
CASE nRangetype = BY_WEEK .or. nRangetype = BY_WEEKTD
  IF DOW(dStartingDate) <> nWeekStart
    dStartingDate := dStartingDate-(DOW(dStartingDate)-nWeekStart)
  ENDIF
CASE nRangetype = BY_MONTH .or. nRangetype = BY_MONTHTD
  IF DAY(dStartingDate) <> 1
    dStartingDate := dStartingDate - (dStartingDate-1)
  ENDIF
CASE nRangetype = BY_YEAR .or. nRangetype = BY_YEARTD
  dStartingDate := BOYEAR(dStartingDate)
ENDCASE

* loop by periods, add elements till >= date()
dThisStart := dStartingDate
@10,30 say "Para fechas desde "+dtoc(dStartingDate)
@11,30 say "            hasta "+dtoc(dEndingDate)
WHILE !(dThisStart > dEndingDate)
  DO CASE
  CASE nRangetype = BY_WEEK
    dThisEnd   := dThisStart+6
    dNextStart := dThisStart+7
  CASE nRangetype = BY_WEEKTD
    dThisEnd   := dThisStart+(expAsOf-DOW(dThisStart))
    dNextStart := dThisStart+7
  CASE nRangetype = BY_MONTH
    dThisEnd   := dThisStart+daysin(dThisStart)-1
    dNextStart := dThisEnd+1
  CASE nRangetype = BY_MONTHTD
    dThisEnd   := dThisStart+expAsOf-1
    dNextStart := dThisStart+daysin(dThisStart)
  CASE nRangetype = BY_YEAR
    dThisEnd   := DATECALC(dThisStart,1,4)-1
    dNextStart := dThisEnd+1
  CASE nRangetype = BY_YEARTD
    dThisEnd   := LEFT(DTOC(dThisStart),6)+;
                  RIGHT(TRANS(YEAR(dThisStart)+1,"9999"),2)
    dThisEnd   := CTOD(dThisEnd)-1
    dNextStart := DATECALC(BOYEAR(dThisStart),1,4)   // GET BEGINNING OF NEXT YEAR
    dNextStart := DATECALC(dNextStart,1,4)
  ENDCASE

  @12,30 say "Rango creado   "+dtoc(dThisStart)
  @13,30 say "       hasta   "+dtoc(dThisEnd)

  aadd(aRanges,{dThisStart,dThisEnd,0,0,0} )
  dThisStart = dNextStart
END
unbox(cBox)
RETURN aRanges


//----------------------------------------------------------
static FUNCTION userdates
local cPopBox := makebox(2,9,23,57)
local nChoice,dThisStart,dThisEnd
local aRanges  := {}
local nElement := 1
local nLastKey
local oTb      := tbrowsenew(5,28,18,54)
oTb:addcolumn(tbcolumnnew("Fecha Inicio",{||iif(len(aRanges)>0,aRanges[nElement,1],"(  none  )")}  ))
oTb:addcolumn(tbcolumnnew("Fecha Final ",{||iif(len(aRanges)>0,aRanges[nElement,2],"(  none  )")}  ))
oTb:skipblock := {|n|aaskip(n,@nElement,len(aRanges))}

@ 3,28 SAY "RANGO DEFINIDO POR EL USUARIO"
@ 6,11 SAY  "<INS>   Agrega"
@ 8,11 SAY  "<DEL>   Borra"
@ 10,11 SAY "<ENTER> Edita"
@ 12,11 SAY "<F10>   Termina"
@ 14,11 SAY "<"+chr(25)+chr(24)+chr(26)+chr(27)+">  Mover"
@ 16,11 SAY "<ESC>   Cancelar"
@ 20,15 SAY "Agregue tantos Rangos Definidos por"
@ 21,21 SAY "el usuario como quiera."
@ 22,15 SAY "Se clasificarán por fecha"

while .t.
  oTb:refreshall()
  while !oTb:stabilize()
  end
  nLastKey := inkey(0)
  do case
  case nLastKey = K_F10
     exit
  case nLastKey = K_ENTER .and. len(aRanges) > 0
    popread(.t.,"Fecha Inicio",@dThisStart,"","Fecha Final ",@dThisEnd,"")
    IF EMPTY(dThisStart).OR.EMPTY(dThisEnd)
      msg("Se necesitan ambas fechas")
    ELSEIF (dThisStart) > (dThisEnd)
      msg("la fecha de finalización es anterior a la de comienzo")
    ELSE
      aRanges[nElement] := {dThisStart,dThisEnd,0,0,0}
    ENDIF
  case nLastKey = K_INS
    dThisStart = CTOD('  /  /  ')
    dThisEnd = CTOD('  /  /  ')
    popread(.t.,"Fecha Inicio",@dThisStart,"","Fecha Final  ",@dThisEnd,"")
    IF EMPTY(dThisStart).OR.EMPTY(dThisEnd)
      msg("Se necesitan ambas fechas")
    ELSEIF (dThisStart) > (dThisEnd)
      msg("la fecha de finalización es anterior a la de comienzo")
    ELSE
      nElement := max(nElement,1)
      aadd(aRanges,"")
      ains(aRanges,nElement)
      aRanges[nElement] := {dThisStart,dThisEnd,0,0,0}
    ENDIF
  case nLastKey = K_DEL .and. len(aRanges) > 0
     adel(aRanges,nElement)
     nElement--
     oTb:rowpos := max(1,oTb:rowpos-1)
     asize(aRanges,len(aRanges)-1)
  case nLastKey = K_ESC
    aRanges := {}
    exit
  case nLastKey = K_UP
    oTb:up()
  case nLastKey = K_DOWN
    oTb:down()
  case nLastKey = K_LEFT
    oTb:left()
  case nLastKey = K_RIGHT
    oTb:right()
  endcase
end
if empty(aRanges)
 aRanges := nil
endif
unbox(cPopBox)
return aRanges

//-----------------------------------------------
static function showit(aRanges,nNumfDec,nNumFLen)
local cBox := makebox(0,0,24,79,setcolor(),0,0)
local oTb      := tbrowsenew(1,1,23,78)
local nElement := 1
local nLastKey
local cNumPict := iif(nNumFDec==0,repl("9",nNumFLen),;
                      stuff( repl("9",nNumFLen),nNumFlen-nNumFdec,1,"." ) )
if len(aRanges)> 0
    oTb:addcolumn(tbcolumnnew("Fecha Inicio  ",{||aRanges[nElement,1]}  ))
    oTb:addcolumn(tbcolumnnew("Fecha Final    ",{||aRanges[nElement,2]}  ))
    oTb:addcolumn(tbcolumnnew(padl("Cuenta",10),{||aRanges[nElement,3]}  ))
    oTb:addcolumn(tbcolumnnew(padl("Suma",nNumFlen),{||trans(aRanges[nElement,4],cNumPict)}  ))
    oTb:addcolumn(tbcolumnnew(padl("Media",nNumFlen),{||trans(aRanges[nElement,5],cNumPict)}  ))
    oTb:skipblock := {|n|aaskip(n,@nElement,len(aRanges))}
    oTb:headsep := "Ä"

    @0,2 SAY '[Resultado del Análisis de Tiempos]'
    @24,2 SAY '[Pulse ESCAPE para salir]'
    while .t.
      while !oTb:stabilize()
      end
      nLastKey := inkey(0)
      do case
      case nLastKey = K_F10 .or. nLastKey = K_ESC
         exit
      case nLastKey = K_UP
        oTb:up()
      case nLastKey = K_DOWN
        oTb:down()
      case nLastKey = K_LEFT
        oTb:left()
      case nLastKey = K_RIGHT
        oTb:right()
      case nLastKey = K_PGUP
        oTb:pageup()
      case nLastKey = K_PGDN
        oTb:pagedown()
      endcase
    end
else
    msg("No hay nada que mostrar - no hay coincidencias")
endif
unbox(cBox)
return nil

static function aLenMulti(aArray,nElement)
local i
local nSum := 0
for i = 1 to len(aArray)
  nsum+=aArray[i,nElement]
next
return len(alltrim(str(nSum)))
//-----------------------------------------------
static function sendtodbf(aRanges,cNumbFieldName,nNumfDec)
local i
local cDbfName
local lDone := .f.
local aStruc := { {"STARTDATE","D",8,0},;
                  {"ENDDATE  ","D",8,0},;
                  {"COUNT","N",aLenMulti(aRanges,3),0} }
local nOldArea := select()
select 0

IF !empty(cNumbfieldName)
     aadd(aStruc,{"SUM  ","N",aLenMulti(aRanges,4),nNumfDec} )
     aadd(aStruc,{"AVERAGE","N",aLenMulti(aRanges,5),nNumfDec} )
ENDIF
WHILE !lDone .and. len(aRanges) > 0
 cDbfName := space(8)
 popread(.F.,"Nombre de la base de datos a crear:",@cDbfName,"@N")
 IF !(LASTKEY() = K_ESC .OR. EMPTY(cDbfName))
    cDbfName := Alltrim(cDbfName)
    cDbfName := UPPER(cDbfName)+".DBF"
    IF !FILE(cDbfName)
      DBCREATE(cDbfName,aStruc)
      USE (cDbfName)
      for i = 1 to len(aRanges)
         append blank
         field->startdate := aRanges[i,1]
         field->enddate   := aRanges[i,2]
         field->count     := aRanges[i,3]
         IF !empty(cNumbfieldName)
           field->sum       := aRanges[i,4]
           field->average   := aRanges[i,5]
         ENDIF
      next
      msg("Análisis Periódico copiado a: "+cDbfName)
      lDone := .t.
    ELSE
      msg("La base de datos "+cDbfName+" ya existe - ","use otro nombre")
    ENDIF
 ELSEIF empty(cDbfName) .and. messyn("El nombre fue dejado en blanco - ¨abondona el proceso?")
    lDone := .t.
 ELSEIF lastkey()=K_ESC
    lDone := .t.
 ENDIF
END
USE
select (nOldArea)
return nil





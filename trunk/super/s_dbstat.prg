//------------------------------------------------------------------------
function dbStats
local i,nLast := 0
LOCAL nOldCursor     := setcursor(0)
LOCAL cInScreen      := Savescreen(0,0,24,79)
LOCAL cOldColor      := Setcolor(sls_normcol())
local nMenuChoice
local cFieldName     := ""
local nSum,nCount,nAverage,nMin,nMax,nVariance,nStd
local nNumerics := Counttype("N")
local lGroup1 := (nNumerics > 0)
local lGroup2 := (nNumerics > 0)
local bfilter := {||.t.}
local lUseQbe := .f.
local bEvalBlock1
local cBox

*- draw boxes
@0,0,24,79 BOX sls_frame()
Setcolor(sls_popcol())
@1,1,12,40 BOX sls_frame()
@20,1,23,78 BOX sls_frame()
@1,5 SAY '[Estad¡stica de la Base de Datos]'

nSum:=nCount:=nAverage:=nMin:=nMax:=nVariance:=nStd :=0

DO WHILE .T.
  @21,5 say "Campo Num‚rico   :"+padr(iif(empty(cFieldName),"Ninguno",cFieldName),10)
  @22,5 say "Usando Filtro    :"+iif(lUseQbe,"SI","NO ")

  Setcolor(sls_popmenu())
  @03,3 PROMPT "Campo Num‚rico "
  @04,3 PROMPT "Elegir Estad   "
  @05,3 PROMPT "Filtro         "
  @06,3 PROMPT "Comenzar       "
  @07,3 PROMPT "Salir"
  MENU TO nMenuChoice
  Setcolor(sls_popcol())

  DO CASE
  CASE nMenuChoice = 0 .or. nMenuChoice = 5
    exit
  CASE nMenuChoice = 1
    nSum:=nCount:=nAverage:=nMin:=nMax:=nVariance:=nStd :=0
    if nNumerics > 0
      cFieldName := mfieldsT("N","Campo Num‚rico")
    else
      msg("No hay campos NUMERICOS en esta DBF", "CONTAR es la £nica estad¡stica disponible")
    endif
  CASE nMenuChoice = 2 // select stats
    nSum:=nCount:=nAverage:=nMin:=nMax:=nVariance:=nStd :=0
    if nNumerics > 0
      statsel(@lGroup1,@lGroup2)
    else
      msg("No hay campos NUMERICOS en esta DBF", "CONTAR es la £nica estad¡stica disponible")
    endif
  CASE nMenuChoice = 3
    if messyn("¨Hace una Consulta?")
      QUERY()
      if !empty(sls_query())
        bFilter := sls_bquery()
        lUseQbe := .t.
      else
        bFilter := {||.t.}
        lUseQbe := .f.
      endif
    else
      bfilter := {||.t.}
      lUseQbe := .f.
    endif
  CASE nMenuChoice = 4 // go
     nMin :=  1000000000
     nMax := -1000000000
     go top
     *if nNumerics > 0 .and. lGroup1
     if nNumerics > 0
       bEvalBlock1 := {||nCount++,nSum+=FIELDGET(FIELDPOS(cFieldName)),;
                       nMin:=Min(nMin,FIELDGET(FIELDPOS(cFieldName))),;
                       nMax:=Max(nMax,FIELDGET(FIELDPOS(cFieldName)))}
     else
       bEvalBlock1 := {||nCount++}
     endif
     cBox := makebox(6,21,14,50)
     @ 7,23 SAY "First Pass"
     @ 10,23 SAY "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
     @ 11,23 SAY "³ registro               ³"
     @ 12,23 SAY "³ de                     ³"
     @ 13,23 SAY "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
     @12,32 SAY TRANS(RECCOUNT(),"9999999999")
     DBEVAL(bEvalBlock,bFilter,{||showhile(11,32,"9999999999")})

     *if nNumerics > 0 .and. lGroup1
     if nNumerics > 0
        nAverage := nSum/nCount
        if lGroup2
           go top
           bEvalBlock  := {||nVariance += ;
                        ( (nAverage-FIELDGET(FIELDPOS(cFieldName)) )^2 )}
           @ 11,23 SAY "³ registro               ³"
           @ 7,23 SAY "Segunda Pasada"
           DBEVAL(bEvalBlock,bFilter,{||showhile(11,32,"9999999999")})
           nVariance := nVariance/nCount
           nStd      := sqrt(nVariance)
        endif
     endif
     unbox(cBox)
     showstats(nCount,nSum,nAverage,nMin,nMax,nVariance,nStd,lGroup1,lGroup2,(nNumerics>0))
     nSum:=nCount:=nAverage:=nMin:=nMax:=nVariance:=nStd :=0
  ENDCASE
END
Restscreen(0,0,24,79,cInScreen)
Setcolor(cOldColor)
setcursor(nOldCursor)
return nil
//----------------------------------------------------
STATIC FUNC SHOWHILE(nrow,nCol,cPict)
@nrow,nCol say trans(recno(),cPict)
return .t.

//------------------------------------------------------
static FUNCTION mfieldsT(cType,cTitle,nTop,nLeft,nBottom,nRight)
local nBoxDepth,nSelection,cFieldName,nOldCursor,i
local cUnderScreen
local aFieldList    := {}
local aAllFieldList := dbstruct()

cType := upper(cType)
IF !used() .or. !cType$"CDLNM"
  RETURN ''
ENDIF
nOldCursor = setcursor(0)

*- put them in an array
for i = 1 to len(aAllFieldList)
  if aallFieldList[i,2]==cType
    aadd(aFieldList,aAllFieldList[i,1])
  endif
next
*- if we haven't been given coordinates, figure some out
IF Pcount() < 6
  nBoxDepth := ROUND(fcount()/2,0)
  nTop      := MAX(2, 12-nBoxDepth)
  nBottom   := MIN(22,12+nBoxDepth+1)
  nLeft     := 30
  nRight    := 50
ENDIF
cUnderScreen=makebox(nTop,nLeft,nBottom,nRight,sls_popcol())
*- display the cTitle
IF Pcount() > 0
  @nTop,nLeft+1 SAY '['+cTitle+']'
ENDIF

nSelection = SACHOICE(nTop+1,nLeft+1,nBottom-1,nRight-1,aFieldList)

cFieldName  = IIF(nSelection > 0, aFieldList[nSelection],'')
unbox(cUnderScreen)
SETCURSOR(nOldCursor)
RETURN cFieldName

//------------------------------------------------------
static FUNCTION CountType(cType)
local nMatches   := 0
local aFieldList := dbstruct()
local i
cType := upper(cType)
for i = 1 to len(aFieldList)
  if aFieldList[i,2]==cType
    nMatches++
  endif
next
RETURN nMatches

//------------------------------------------------------
static function statsel(lGroup1,lGroup2)
local cBox := makebox(4,22,16,53)
local getlist := {}
@ 5,24 SAY "Elija Estad¡stica"
@ 6,47 SAY "Y/N"
@ 8,24 SAY "Suma,Media    "
@ 9,24 SAY " M¡nimo,M ximo....."

@ 12,24 SAY "Varianza,Standard"
@ 13,24 SAY " Desviaci¢n......"

@9,47   get lGroup1 pict "Y"
@13,47  get lGroup2 pict "Y"
set cursor on
read
set cursor off
unbox(cBox)
return nil

//------------------------------------------------------
static func showstats(nCount,nSum,nAverage,nMin,nMax,nVariance,nStd,lGroup1,lGroup2,lNumerics)
local cBox := makebox(4,22,18,65)
@ 5,24 SAY "Elija Estad¡stica"
@ 8,24 SAY "Contar................"
IF lNumerics .and. lGroup1
   @ 9,24 SAY "Suma................."
   @ 10,24 SAY "Media.............."
   @ 11,24 SAY "M¡nimo..............."
   @ 12,24 SAY "M ximo..............."
   @9,47  say PADL(STR(nSum),15)
   @10,47 say PADL(STR(nAverage),15)
   @11,47 say PADL(STR(nMin),15)
   @12,47 say PADL(STR(nMax),15)
endif
if lNumerics .and. lGroup2
   @ 13,24 SAY "Varianza............."
   @ 14,24 SAY "Desviaci¢n Standar...."
   @13,47 say PADL(STR(nVariance),15)
   @14,47 say PADL(STR(nStd),15)
endif
@8,47  say padl(str(nCount),15)
@17,24 SAY "(pulse una tecla)"

inkey(0)
unbox(cBox)
return nil


//------------------------------------------------------


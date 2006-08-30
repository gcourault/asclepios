
//----------------------------------------------------------------------
#DEFINE M_DBF           1
#DEFINE M_TITLE         2
#DEFINE M_NDXKEY        3
#DEFINE M_MAJKEY        4
#DEFINE M_MINKEY        5
#DEFINE M_MAJTEXT       6
#DEFINE M_MINTEXT       7
#DEFINE M_WIDTH         8
#DEFINE M_LENGTH        9
#DEFINE M_LEFTM        10
#DEFINE M_TOPM         11
#DEFINE M_SPACE        12
#DEFINE M_PAUSE        13
#DEFINE M_NPLINES      14
#DEFINE M_EJB4         15
#DEFINE M_EJAFT        16
#DEFINE M_EJMAJOR      17
#DEFINE M_EJMINOR      18
#DEFINE M_EJGRAND      19
#DEFINE M_UNTOTAL      20
#DEFINE M_MAJCHR       21
#DEFINE M_MINCHR       22
#DEFINE M_NHEAD        23
#DEFINE M_NFOOT        24
#DEFINE M_NTITL        25
#DEFINE M_TSEP         26
#DEFINE M_COLSEP       27
#DEFINE M_CSEPWID      28
#DEFINE M_LINESEP      29
#DEFINE M_NCOLS        30
#DEFINE M_FEET         31
#DEFINE M_HEADS        32
#DEFINE M_STDHEAD      33
#DEFINE M_DETAILS      34
#DEFINE M_QUERY        35
#DEFINE M_FULLSUM      36
#DEFINE M_PRNCODE      37
#DEFINE M_AFTCODE      38

#DEFINE CRLF            CHR(13)+CHR(10)
#include "inkey.ch"

//-------------------------------------------------------------------
memvar getlist

static aDbfFields,aDbfTypes,aDbfLens
static aValues
static aHeader
static aFooter
static aColumns
static aTitles
static aWidths
static aTotalYN
static aPictures
static aNdxKeys
static nElement

EXTERNAL CRUNCH


//-------------------------------------------------------------------------
FUNCTION REPORTER(aInFields,aInTypes,aInLens)
local aTagged   := {}
local lUseQuery := .f.
local lUseTag   := .f.
LOCAL nSelection,nSubChoice
LOCAL nOldArea,nReportArea
LOCAL lDone
LOCAL cInScreen,cOldColor,cBox,lReadExit,nOldOrder,lExact
LOCAL bOldF2,nOldCursor,i
LOCAL cMenuBox,cReport,cPrintBox
LOCAL nHead, nFeet

LOCAL sf_hold,sf_hold2,sf_hold3,X

IF !USED()
  msg("No hay bases de datos abiertas")
  RETURN ""
ENDIF

//aDbfFields,aDbfTypes,aDbfLens,aValues
aHeader:= {}
aFooter:= {}
aColumns:={}
aTitles:={}
aWidths:={}
aTotalYN:={}
aPictures:={}
aNdxKeys := {}
nElement := 1




GO TOP
IF !( VALTYPE(aInFields)+VALTYPE(aInTypes)+VALTYPE(aInLens))=="AAA"
  aDbfFields := array(fcount())
  aDbfTypes  := array(fcount())
  aDbfLens   := array(fcount())
  aFields(aDbfFields,aDbfTypes,aDbfLens)
ELSE
  aDbfFields := aInFields
  aDbfTypes  := aIntypes
  aDbfLens   := aInLens
ENDIF
aValues := array(38)


*- save environment
nOldArea    := SELECT()
cInScreen   := savescreen(0,0,24,79)
lReadExit   := READEXIT(.T.)
nOldOrder   := indexord()
lExact      := setexact(.t.)
nOldCursor  := setcursor(0)
cOldColor   := setcolor(sls_normcol())
bOldF2      := SETKEY(-1)
lDone       := .f.
*- load index keys
for i = 1 to 15
   if !empty(indexkey(i))
     aadd(aNdxKeys, indexkey(i) )
   endif
next

SELECT 0
IF !FILE(slsf_report()+".DBF")
     rMakeDbf()
ENDIF
if !SNET_USE(slsf_report(),"__REPORTS",.F.,5,.T.,"Error de red abriendo archivo REPORTE. ¨Reintenta?")
   SELECT (nOldArea)
   READEXIT(lReadExit)
   setexact(lExact)
   setcolor(cOldColor)
   SETKEY(-1,bOldF2)
   setcursor(nOldCursor)
   return ''
ENDIF
nReportArea := SELECT()
SELECT (nOldArea)


*- fill arrays and variables with default values
rLoadBlank()

*- draw screen
rDrawit()


*- take the plunge
DO WHILE !lDone
  DISPBEGIN()
  SELECT (nOldArea)
  SETKEY( -1 )
  Setcolor(sls_popmenu())
  scroll(22,2,22,77,0)
  SETCURSOR(0)

  @22,2 SAY "REPORTE :"+IIF(EMPTY(aValues[M_TITLE]),"Ninguno ",upper(aValues[M_TITLE]))
  @22,55 SAY "USANDO  "+ALIAS()+".DBF"

  @3,4 PROMPT  'Traer REPORTE  '
  @4,4 PROMPT  'Crear REPORTE  '
  @5,4 PROMPT  'Grabar REPORTE '
  @6,4 PROMPT  'Editar Reporte '
  @7,4 PROMPT  'Borrar Reportes'
  @08,4 PROMPT 'Headers/Footers'
  @09,4 PROMPT 'Filtrado       '
  @10,4 PROMPT 'Agrupaciones   '
  @11,4 PROMPT 'Otras Optiones '
  @13,4 PROMPT 'Imprimir Report'
  @15,4 PROMPT 'Status del Repo'
  @16,4 PROMPT 'Salir          '
  DISPEND()

  MENU TO nSelection
  SETCURSOR(1)

  DO CASE
  CASE nSelection == 1     // load report
    rLoadBlank()
    rLoadReport()
  CASE nSelection == 2     // create report
    rLoadBlank()
    cReport     := aValues[M_TITLE]
    popread(.t.,"T¡tulo del Reporte",@cReport,"@K")
    aValues[M_TITLE] := cReport
  CASE nSelection = 3  .and. (aValues[M_NCOLS]> 0)   // save report
    rSaveReport()
  CASE nSelection = 4  .AND. rLoaded()              // define columns
    rBrowseEdit()
  CASE nSelection = 5   && purge reports
    SELECT (nReportArea)
    if USED()
       PURGEM()
    endif
    SELECT (nOldArea)
  CASE nSelection = 6 .AND. rLoaded()  && headers and footers
    nHead := aValues[M_NHEAD]
    nFeet := aValues[M_NFOOT]
    popread(.t.,"N£mero de l¡neas encabezamiento    (1-9) ",@nHead,"9",;
                "N£mero de l¡neas del pie de p gina (1-9) ",@nFeet,"9")
    aValues[M_NHEAD] := nHead
    aValues[M_NFOOT] := nFeet

    while len(aHeader) < aValues[M_NHEAD]
      aadd(aHeader,"")
    end
    while len(aFooter) < aValues[M_NFOOT]
      aadd(aFooter,"")
    end
    asize(aHeader,aValues[M_NHEAD])
    asize(aFooter,aValues[M_NFOOT])
    rHeadsFeet()
  CASE nSelection = 7 .AND. rLoaded()    && record selection
    cBox   := Makebox(13,25,18,52,sls_popcol())
    @14,28 PROMPT "Sin Filtro "
    @15,28 PROMPT "Seleccionar Registros"
    @16,28 PROMPT "Construir nueva Consulta"
    IF !EMPTY(aValues[M_QUERY])
      @17,28 PROMPT "Usar la £ltima Consulta"
    ENDIF (!empty(aValues[M_QUERY]))
    MENU TO nSubChoice

    Unbox(cBox)
    lUseTag     := .F.
    lUseQuery   := .F.
    IF nSubChoice <=1
    ELSEIF nSubChoice = 2
      Tagit(aTagged)
      lUseTag := (len(aTagged) > 0)
    ELSE
      IF nSubChoice = 3
        do while .t.
          * use new Query parameters
          QUERY("","","","a Generador de Reportes")
          if len(sls_query()) > 100
             if messyn("Consulta muy larga - debe tener 100 caracteres o menos","Rehacer","Cancelar")
                loop
             else
                sls_query("")   
             endif
          endif
          exit
        enddo
        aValues[M_QUERY] := sls_query()
      ENDIF
      lUseQuery := (!EMPTY(aValues[M_QUERY]))
    ENDIF
  CASE nSelection = 8  .AND. rLoaded()   && sort order - select index for report
    rSetORder()
  CASE nSelection = 9  .AND. rLoaded()   && page layout
    rLayout()
  CASE nSelection = 10 .and. (aValues[M_NCOLS]> 0) .AND. rLoaded()
    cPrintBox := makebox(20,0,24,79,sls_normcol())
    rPrintRep({aValues,aHeader,aFooter,aColumns,aTitles,aWidths,aTotalYN,;
               aPictures},lUseQuery,lUseTag,aTagged)
    unbox(cPrintBox)

  CASE nSelection = 11 .AND. rLoaded()
    rShowLayout()
  CASE nSelection = 12  .or. lastkey()=K_ESC   // quitting time
    SETKEY(-1,bOldF2)
    if !empty(aValues[M_TITLE])
        if messyn("¨Graba el Reporte:"+trim(aValues[M_TITLE])+" antes de salir?")
          rSaveReport()
        endif
    endif
    SELECT (nReportArea)
    use
    SELECT (nOldArea)
    RESTSCREEN(0,0,24,79,cInScreen)
    READEXIT(lReadExit)
    set order to nOldOrder
    setexact(lExact)
    SETCOLOR(cOldColor)
    setcursor(nOldCursor)
    lDone := .t.
  otherwise
     Msg("No hay reportes definidos. Cargue o Cree uno")
  ENDCASE
  CLEAR TYPEAHEAD
ENDDO
aDbfFields := NIL
aDbfTypes  := NIL
aDbfLens   := NIL
aValues    := NIL
aHeader    := NIL
aFooter    := NIL
aColumns   := NIL
aTitles    := NIL
aWidths    := NIL
aTotalYN   := NIL
aPictures  := NIL
aNdxKeys   := NIL
nElement   := NIL
return ''

//-------------------------------------------------------------------------
static FUNCTION rAddColumn(nWhich)
asize(aColumns,len(aColumns)+1)
asize(aTitles,len(aTitles)+1)
asize(aWidths,len(aWidths)+1)
asize(aTotalYN,len(aTotalYN)+1)
asize(aPictures,len(aPictures)+1)
nWhich++
Ains(aColumns,nWhich)
Ains(aTitles,nWhich)
Ains(aWidths,nWhich)
Ains(aPictures,nWhich)
Ains(aTotalYN,nWhich)
aColumns[nWhich] := ""
aTitles[nWhich]  := SPACE(35)
aWidths[nWhich]  := "  "
aPictures[nWhich] := ""
aTotalYN[nWhich]  := " "
RETURN ''

//-------------------------------------------------------------------------
static FUNCTION rDelColumn(nWhich)
Adel(aColumns,nWhich)
Adel(aTitles,nWhich)
Adel(aWidths,nWhich)
Adel(aPictures,nWhich)
Adel(aTotalYN,nWhich)
asize(aColumns,len(aColumns)-1)
asize(aTitles,len(aTitles)-1)
asize(aWidths,len(aWidths)-1)
asize(aTotalYN,len(aTotalYN)-1)
asize(aPictures,len(aPictures)-1)
RETURN ''

//-------------------------------------------------------------------------
STATIC FUNCTION rGetTypeOf(cGetType)
local expValue := &(cGetType)
RETURN valtype(expValue)


//-------------------------------------------------------------------------
STATIC FUNCTION rSetORder
local nOpen,nOrder
local nSelect,cBox
local lIndex
set key 27 to

lIndex = !EMPTY(INDEXKEY(1))
cBox= Makebox(10,10,20,50,sls_popcol())
@10,12 SAY "[Seleccionar orden de procesamiento]"
@13,12 PROMPT "Seleccionar un ¡ndice abierto"
@14,12 PROMPT "Ver la selecci¢n activa"
@15,12 PROMPT "Desactivar el orden actual"
@17,12 PROMPT "Salir"
MENU TO nSelect
Unbox(cBox)

DO CASE
CASE nSelect = 1 .AND. lIndex  && select from open indexes
  STORE "" TO aValues[M_MAJKEY],aValues[M_MINKEY]
  cBox  := Makebox(10,19,17,71,sls_popcol())
  @10,21 SAY "[Seleccionar la Clave a Usar]"
  nOrder = SACHOICE(11,20,16,70,aNdxKeys)
  Unbox(cBox)
  IF nOrder > 0
    SET ORDER TO nOrder
    rParsKey(aNdxKeys[nOrder])
    aValues[M_NDXKEY] = aNdxKeys[nOrder]
  ENDIF
CASE nSelect = 2    && view selection
  Msg("El orden de la Base es  :  ",IIF(EMPTY(INDEXKEY(0)),"Ninguno",left(indexkey(0),50) ),;
    "El Grupo Principal es     :  ",IIF(EMPTY(aValues[M_MAJKEY]),"Ninguno",left(aValues[M_MAJKEY],50)),;
    "El Grupo Secundario es    :  ",IIF(EMPTY(aValues[M_MINKEY]),"Ninguno",left(aValues[M_MINKEY],50)) )

CASE nSelect = 3    && deactivate
  STORE "" TO aValues[M_MAJKEY],aValues[M_MINKEY],aValues[M_NDXKEY]
ENDCASE
Unbox(cBox)
RETURN ''




//-------------------------------------------------------------------------
STATIC FUNCTION rSaveReport
LOCAL nIter,nOverWrite,cBuffer
LOCAL nOldarea := select()
local cTitle := aValues[M_TITLE]

SELECT __REPORTS
WHILE .T.
  IF aValues[M_NCOLS] = 0
    Msg("No hay reportes definidos")
    EXIT
  ENDIF
  DO WHILE .T.
    popread(.t.,"T¡tulo del Reporte",@cTitle,"@K")
    IF LASTKEY()=27
      EXIT
    ENDIF

    LOCATE FOR TRIM(UPPER(cTitle))==TRIM(UPPER(__reports->SF_TITLE)) ;
         .AND. !DELETED()
    IF FOUND()
      if messyn("El registro ya existe:","No Sobreescribe","Sobreescribe")
        EXIT
      endif
    ELSE
      LOCATE FOR DELETED()   // if there's a deleted record, re-use it
      if found() .AND. SREC_LOCK(5,.F.)
      ELSEIF !SADD_REC(5,.T.,"Error de Red agregando registro. ¨Reintenta?")
          EXIT
      endif
    ENDIF
    aValues[M_TITLE] := cTitle

    IF SREC_LOCK(5,.T.,"Error de red grabando datos. ¨Reintenta?")
        __reports->SF_DBF := aValues[M_DBF]
        __reports->SF_TITLE := aValues[M_TITLE]
        __reports->SF_NdxKey := aValues[M_NDXKEY]
        __reports->SF_MAJKEY := aValues[M_MAJKEY]
        __reports->SF_MINKEY := aValues[M_MINKEY]
        __reports->SF_MAJTEXT := aValues[M_MAJTEXT]
        __reports->SF_MINTEXT := aValues[M_MINTEXT]
        __reports->SF_WIDTH := aValues[M_WIDTH]
        __reports->SF_LENGTH := aValues[M_LENGTH]
        __reports->SF_LEFTM := aValues[M_LEFTM]
        __reports->SF_TOPM := aValues[M_TOPM]
        __reports->SF_SPACE := aValues[M_SPACE]
        __reports->SF_PAUSE := aValues[M_PAUSE]
        __reports->SF_NPLINES := aValues[M_NPLINES]
        __reports->SF_EJB4 := aValues[M_EJB4]
        __reports->SF_EJAFT := aValues[M_EJAFT]
        __reports->SF_EJMAJOR := aValues[M_EJMAJOR]
        __reports->SF_EJMINOR := aValues[M_EJMINOR]
        __reports->SF_EJGRAND := aValues[M_EJGRAND]
        __reports->SF_UNTOTAL := aValues[M_UNTOTAL]
        __reports->SF_MAJCHR := aValues[M_MAJCHR]
        __reports->SF_MINCHR := aValues[M_MINCHR]
        __reports->SF_NHEAD := aValues[M_NHEAD]
        __reports->SF_NFOOT := aValues[M_NFOOT]
        __reports->SF_NTITL := aValues[M_NTITL]
        __reports->SF_TSEP := aValues[M_TSEP]
        __reports->SF_COLSEP := aValues[M_COLSEP]
        __reports->SF_CSEPWID := aValues[M_CSEPWID]
        __reports->SF_LINESEP := aValues[M_LINESEP]
        __reports->SF_NCOLS := aValues[M_NCOLS]
        __reports->SF_STDHEAD := aValues[M_STDHEAD]
        __reports->SF_QUERY := aValues[M_QUERY]
        __reports->SF_FULLSUM := aValues[M_FULLSUM]
        __reports->SF_PRNCODE := aValues[M_PRNCODE]
        __reports->SF_AFTCODE := aValues[M_AFTCODE]

        cBuffer := ""
        for nIter = 1 TO aValues[M_NHEAD]
          cBuffer += rSquish(aHeader[nIter])+"þ"   && report headers
        NEXT (nIter)
        __reports->sf_heads :=  cBuffer

        cBuffer := ""
        for nIter = 1 TO aValues[M_NFOOT]
          cBuffer += rSquish(aFooter[nIter])+"þ"   && report footers
        NEXT (nIter)
        __reports->sf_feet := cBuffer

        cBuffer := ""
        for nIter = 1 TO aValues[M_NCOLS]
          cBuffer += aColumns[nIter]+ "þ"    && column contents
          cBuffer += aTitles[nIter]+  "þ"       && column titles (delimited with ; for multiple)
          cBuffer += aWidths[nIter]+  "þ"   && column widths
          cBuffer += aTotalYN[nIter]+  "þ"   && column totals Y/N
          cBuffer += aPictures[nIter]+CRLF    && column pictures
        NEXT (nIter)
        __reports->sf_details := cBuffer
        DBRECALL()      // undelete it, in case it was re-used
    endif
    unlock
    goto recno()
    EXIT
  ENDDO
  EXIT
END
SELECT (nOldArea)
RETURN ''


//-------------------------------------------------------------------------
STATIC FUNCTION rSquish(cInstring)
cInString := Strtran(cInString,SPACE(80),CHR(01))
cInString := Strtran(cInString,SPACE(70),CHR(02))
cInString := Strtran(cInString,SPACE(60),CHR(03))
cInString := Strtran(cInString,SPACE(50),CHR(04))
cInString := Strtran(cInString,SPACE(40),CHR(05))
cInString := Strtran(cInString,SPACE(30),CHR(06))
cInString := Strtran(cInString,SPACE(20),CHR(07))
cInString := Strtran(cInString,SPACE(10),CHR(08))
cInString := Strtran(cInString,SPACE(05),CHR(09))
cInString := Strtran(cInString,SPACE(02),CHR(10))
RETURN cInString


//-------------------------------------------------------------------------
STATIC FUNCTION rUnSquish(cInstring)
cInstring = Strtran(cInstring,CHR(01),SPACE(80) )
cInstring = Strtran(cInstring,CHR(02),SPACE(70) )
cInstring = Strtran(cInstring,CHR(03),SPACE(60) )
cInstring = Strtran(cInstring,CHR(04),SPACE(50) )
cInstring = Strtran(cInstring,CHR(05),SPACE(40) )
cInstring = Strtran(cInstring,CHR(06),SPACE(30) )
cInstring = Strtran(cInstring,CHR(07),SPACE(20) )
cInstring = Strtran(cInstring,CHR(08),SPACE(10) )
cInstring = Strtran(cInstring,CHR(09),SPACE(05) )
cInstring = Strtran(cInstring,CHR(10),SPACE(02) )
RETURN cInstring

//-------------------------------------------------------------------------
static FUNCTION rLoadReport()

local nCountMatch,cBuffer,nMatches,nIndexOrd
local newkey,oldarea,cDbfNAme
local aMatchRec
local aRepTitles,i
local nFoundkey,cStoredKey
local cReportName

cDbfNAme    := alias()
oldarea     := select()
nIndexOrd   := indexord()
aHeader:= {}
aFooter:= {}
aColumns:={}
aTitles:={}
aWidths:={}
aTotalYN:={}
aPictures:={}

SELECT __REPORTS

LOCATE FOR __reports->sf_dbf=cDbfName .and. !deleted()
IF EOF()
  Msg("No hay reportes para la base: "+cDbfName)
ENDIF

DO WHILE !EOF()
  aValues[M_NDXKEY] = ""
  aValues[M_MAJKEY] = ""
  aValues[M_MINKEY] = ""
  IF cReportName==nil
     COUNT FOR __reports->sf_dbf=aValues[M_DBF] .and. !deleted() TO nCountMatch
     aMatchRec  := array(nCountMatch)
     aRepTitles := array(nCountMatch)
     GO TOP
     nMatches   := 0
     LOCATE FOR __reports->sf_dbf=cDbfNAme .and. !deleted()
     DO WHILE !EOF()
       nMatches++
       aMatchRec[nMatches]  := RECNO()
       aRepTitles[nMatches] := __reports->sf_title
       CONTINUE
     ENDDO

     nCountMatch := Mchoice(aRepTitles,10,20,20,70,"Reportes Grabados")
     IF nCountMatch = 0
       rLoadBlank()
       EXIT
     ENDIF
     GO (aMatchRec[nCountMatch])
  endif
  cStoredKey  := trim(__reports->sf_NdxKey)
  if !empty(cStoredKey)
    nFoundKey  := ascan(aNdxKeys,cStoredKey)
    if nFoundKey > 0
        nIndexOrd := nFoundKey
        aValues[M_NDXKEY] := cStoredKey
        aValues[M_MAJKEY] = trim(__reports->sf_majkey)
        aValues[M_MINKEY] = trim(__reports->sf_minkey)
        msg("Usando la Clave =>"+aValues[M_NDXKEY])
    else
        aValues[M_NDXKEY] := ""
        aValues[M_MAJKEY] := ""
        aValues[M_MINKEY] := ""
    endif
  endif

  aValues[M_TITLE]  := __reports->sf_title
  aValues[M_WIDTH]  := __reports->sf_width
  aValues[M_LENGTH] := __reports->sf_length
  aValues[M_LEFTM]  := __reports->sf_leftm
  aValues[M_TOPM]   := __reports->sf_topm
  aValues[M_SPACE]  := __reports->sf_space
  aValues[M_PAUSE]  := __reports->sf_pause
  aValues[M_EJB4]   := __reports->sf_ejb4
  aValues[M_EJAFT]  := __reports->sf_ejaft
  aValues[M_EJMAJOR]:= __reports->sf_ejmajor
  aValues[M_EJMINOR]:= __reports->sf_ejminor
  aValues[M_EJGRAND]:= __reports->sf_ejgrand
  aValues[M_NHEAD]  := __reports->sf_nhead
  aValues[M_NFOOT]  := __reports->sf_nfoot
  aValues[M_NTITL]  := __reports->sf_ntitl
  aValues[M_TSEP]   := __reports->sf_tsep
  aValues[M_COLSEP] := __reports->sf_colsep
  aValues[M_CSEPWID]:= __reports->sf_csepwid
  aValues[M_LINESEP] := __reports->sf_linesep
  aValues[M_NCOLS]  := __reports->sf_ncols
  aValues[M_STDHEAD] := __reports->sf_stdhead
  aValues[M_MAJTEXT] := __reports->sf_majtext
  aValues[M_MINTEXT] := __reports->sf_mintext
  aValues[M_NPLINES] := __reports->sf_nplines
  aValues[M_UNTOTAL] := __reports->sf_untotal
  aValues[M_MAJCHR] := __reports->sf_majchr
  aValues[M_MINCHR] := __reports->sf_minchr
  aValues[M_FULLSUM] := __reports->sf_fullsum
  aValues[M_PRNCODE] := __reports->sf_prncode
  aValues[M_AFTCODE] := __reports->sf_aftcode
  aValues[M_QUERY] := __reports->sf_query
  
  cBuffer := __reports->sf_heads
  for i = 1 TO aValues[M_NHEAD]
    aadd(aHeader,rUnSquish(Takeout(cBuffer,"þ",i)) )
  NEXT (I)

  cBuffer = __reports->sf_feet
  for i = 1 TO aValues[M_NFOOT]
    aadd(aFooter,rUnSquish(Takeout(cBuffer,"þ",i)) )
  NEXT (I)
  
  *- column descriptions
  for i = 1 TO aValues[M_NCOLS]
    cBuffer     := TRIM(MEMOLINE(__reports->sf_details,150,i))
    aadd(aColumns,Takeout(cBuffer,"þ",1))
    aadd(aTitles,Takeout(cBuffer,"þ",2))
    aadd(aWidths, Takeout(cBuffer,"þ",3))
    aadd(aTotalYN,Takeout(cBuffer,"þ",4))
    aadd(aPictures,Takeout(cBuffer,"þ",5))
  NEXT
  EXIT
ENDDO
SELECT (oldarea)
set order to nIndexOrd
if len(aColumns)=0
  rLoadBlank()
endif
RETURN ''


//-------------------------------------------------------------------------
static FUNCTION rParsKey(cNdxKey)
local nFiguring,nStartSeg,nKeyLength,nSegments,cThisChar
local cBox,nChoice,nAtPos,nCounter
local aMajorKeys := {}
local aMinorKeys := {}
nFiguring   := 0
nStartSeg   := 1
nKeyLength  := LEN(cNdxKey)
nSegments   := 0
cThisChar   := ""
while  left(cNdxKey,1)=="(" .and. right(cNdxKey,1)==")"
    cNdxKey := subst(cNdxKey,2,len(cNdxKey)-2)
end

for nAtPos = 1 TO nKeyLength
  cThisChar := SUBST(cNdxKey,nAtPos,1)
  IF cThisChar=="("
    nFiguring++
  ELSEIF cThisChar==")"
    nFiguring--
  ELSEIF (nFiguring=0) .AND. (cThisChar=="+")
    nSegments++
    aadd(aMinorKeys,SUBST(cNdxKey,nStartSeg,(nAtPos-nStartSeg)) )
    aadd(aMajorKeys,SUBST(cNdxKey,1,nAtPos-1) )
    nStartSeg := nAtPos+1
  ENDIF
NEXT
nSegments = nSegments+1
aadd(aMinorKeys,SUBST(cNdxKey,nStartSeg) )
aadd(aMajorKeys,cNdxKey)


cBox := Makebox(8,5,18,75,sls_popcol())
@11,8  SAY "Se pueden usar GRUPOS en el reporte."
@12,8  SAY "Un CAMBIO DE GRUPO es un punto donde cambia"
@13,8  SAY "una de las claves en una base INDEXADA. Los SUBTOTALES"
@14,8  SAY "se imprimen cuando cambia un grupo."
@15,8  SAY "Este generador de reportes tiene un grupo PRINCIPAL y uno"
@16,8  SAY "SECUNDARIO. Seleccione los GRUPOS para este reporte."
@18,8 SAY "[Pulse una tecla....]"
INKEY(0)
Unbox(cBox)

IF Messyn("¨Selecciona el grupo Principal de la clave?")
  nChoice := Mchoice(aMajorKeys,10,10,20,60,"Seleccione grupo Principal")
  IF nChoice > 0
    aValues[M_MAJKEY] := aMajorKeys[nChoice]
  ENDIF

  IF nSegments > 1 .AND. nChoice > 0 .AND. nChoice < nSegments
    IF Messyn("¨Selecciona el grupo Secundario de la Clave?")
      for nCounter = 1 TO nChoice
        Adel(aMinorKeys,1)
      NEXT
      asize(aMinorKeys,len(aMinorKeys)-nChoice)
      nChoice := Mchoice(aMinorKeys,10,10,20,60,"Seleccione el grupo Secundario")
      IF nChoice > 0
        aValues[M_MINKEY] := aMinorKeys[nChoice]
      ENDIF (nChoice > 0)
    ENDIF
  ENDIF
ENDIF
return nil


//-------------------------------------------------------------------------
static FUNCTION rDrawit
DISPBEGIN()
setcolor(sls_normcol())
@0,0,24,79 BOX "ÚÄ¿³ÙÄÀ³ "

setcolor(sls_popmenu())
@1,2,17,25 BOX "ÚÄ¿³ÙÄÀ³ "
@1,5 SAY '[Report Writer]'
@20,1,23,78 BOX "ÚÄ¿³ÙÄÀ³ "
DISPEND()
RETURN ''


//------------------------------------------------------------------
static function aaskip(n)
  local skipcount := 0
  do case
  case n > 0
    do while nElement+skipcount < len(aColumns)  .and. skipcount < n
      skipcount++
    enddo
  case n < 0
    do while nElement+skipcount > 1 .and. skipcount > n
      skipcount--
    enddo
  endcase
  nElement += skipcount
return skipcount


//-------------------------------------------------------------------------
static FUNCTION rMakeDbf
LOCAL RSTRUC[38]

RSTRUC[1]="sf_DBF,C,8"
RSTRUC[2]="sf_TITLE,C,35"
RSTRUC[3]="sf_NDXKEY,C,60"
RSTRUC[4]="sf_MAJKEY,C,60"
RSTRUC[5]="sf_MINKEY,C,60"
RSTRUC[6]="sf_MAJTEXT,C,25"
RSTRUC[7]="sf_MINTEXT,C,25"
RSTRUC[8]="sf_WIDTH,N,3,0"
RSTRUC[9]="sf_LENGTH,N,3,0"
RSTRUC[10]="sf_LEFTM,N,2,0"
RSTRUC[11]="sf_TOPM,N,2,0"
RSTRUC[12]="sf_SPACE,N,1,0"
RSTRUC[13]="sf_PAUSE,L"
RSTRUC[14]="sf_NPLINES,N,1,0"
RSTRUC[15]="sf_EJB4,L"
RSTRUC[16]="sf_EJAFT,L"
RSTRUC[17]="sf_EJMAJOR,L"
RSTRUC[18]="sf_EJMINOR,L"
RSTRUC[19]="sf_EJGRAND,L"
RSTRUC[20]="sf_UNTOTAL,L"
RSTRUC[21]="sf_MAJCHR,C,1"
RSTRUC[22]="sf_MINCHR,C,1"
RSTRUC[23]="sf_NHEAD,N,1,0"
RSTRUC[24]="sf_NFOOT,N,1,0"
RSTRUC[25]="sf_NTITL,N,1,0"
RSTRUC[26]="sf_TSEP,C,1"
RSTRUC[27]="sf_COLSEP,C,1"
RSTRUC[28]="sf_CSEPWID,N,1,0"
RSTRUC[29]="sf_LINESEP,C,1"
RSTRUC[30]="sf_NCOLS,N,2,0"
RSTRUC[31]="sf_FEET,M"
RSTRUC[32]="sf_HEADS,M"
RSTRUC[33]="sf_STDHEAD,L"
RSTRUC[34]="sf_DETAILS,M"
RSTRUC[35]="sf_QUERY,C,100"
RSTRUC[36]="sf_FULLSUM,C,1"
RSTRUC[37]="sf_PRNCODE,C,50"
RSTRUC[38]="sf_AFTCODE,C,50"
BLDDBF(slsf_report(),rstruc)
return nil

//-------------------------------------------------------------------------
static FUNCTION rLayout

local nPage,bOldf2,cBox
cBox = Makebox(1,18,24,79,sls_popcol(),0)
nPage = 1
bOldf2 = SETKEY(-1,{||rEditThis()})

DO WHILE .T.
  DO CASE
  CASE nPage = 1
    @ 1,20 SAY "[Opciones de P gina  1"
    @ 3,20 SAY "Dimensiones de la P gina"
    @ 4,20 SAY "------------------------"
    @ 5,20 SAY "Longitud de P gina..............    (lineas por p gina)"
    @ 6,20 SAY "Ancho de P gina.................(caracteres a lo ancho)"
    @ 7,20 SAY "Margen Superior................."
    @ 8,20 SAY "Margen Izquierdo................"
    @ 10,20 SAY "Encabezamiento de Grupos y Totales"
    @ 11,20 SAY "----------------------------------"
    @ 12,20 SAY "Encabezamiento Principal........"
    @ 13,20 SAY "(ingrese NONE para suprimir este encabezamiento)"

    @ 14,20 SAY "Encabezamiento secundario........"
    @ 15,20 SAY "(ingrese NONE para suprimir este encabezamiento)"
    @ 16,20 SAY "Caracter de subrayado principal.    pulse F2 para opciones"
    @ 17,20 SAY "Caracter de subrayado secundario    pulse F2 para opciones"
    @ 18,20 SAY "Subrayado de Totales............    (S/N)"
    @5,53 GET aValues[M_LENGTH]  PICT "999"
    @6,53 GET aValues[M_WIDTH]   PICT "999"
    @7,53 GET aValues[M_TOPM]    PICT "99"
    @8,53 GET aValues[M_LEFTM]   PICT "99"

    @12,53 GET aValues[M_MAJTEXT]
    @14,53 GET aValues[M_MINTEXT]
    @16,53 GET aValues[M_MAJCHR]
    @17,53 GET aValues[M_MINCHR]
	 cSubrTotal := "S"
    @18,53 GET cSubrTotal PICT "!"
    READ
	 aValues[M_UNTOTAL] := if(cSubrTotal := "S" ,.t.,.f.)
    Scroll(2,19,23,78,0)
  CASE nPage = 2
    @ 1,20 SAY  "[Opciones de P gina 2 "
    @ 3,20 SAY  "Opciones de salto de p gina"
    @ 4,20 SAY  "---------------------------"
    @ 5,20 SAY  "Saltar antes del reporte........    (S/N)"
    @ 6,20 SAY  "Saltar despu‚s del reporte......    (S/N)"
    @ 7,20 SAY  "Saltar en  cambio de Principal..    (S/N)"
    @ 8,20 SAY  "Saltar en cambio de Secundario..    (S/N)"
    @ 9,20 SAY  "Saltar antes de los totales.....    (S/N)"
    @ 10,20 SAY "Saltar si quedan # lineas.......    (despu‚s del grupo)"
    @ 11,20 SAY "Pausa entre p ginas ............    (S/N)"
    @ 13,20 SAY "Caracteres Separadores"
    @ 14,20 SAY "----------------------"
    @ 15,20 SAY "N£mero de l¡neas del t¡tulo.....    (1 or 2)"
    @ 16,20 SAY "Separador de la l¡nea de detalle    pulse F2 para opciones"
    @ 17,20 SAY "# l¡neas entre l¡neas de detalle.   (0 or 1)"
    @ 18,20 SAY "Separador de Columna............    pulse F2 para opciones"
    @ 19,20 SAY "Ancho del separador de columna.."
    @ 20,20 SAY "Separador T¡tulo/Cuerpo/Pie.....    pulse F2 para opciones"
	 mMEJB4 := "S"
	 mMEJAFT := "S"
	 mMEJMAJOR := "S"
	 mMEJMINOR := "S"
	 mMEJGRAND := "S"
	 mMPAUSE := "S"
    @5,53 GET mMEJB4   PICT "!"
    @6,53 GET mMEJAFT  PICT "!"
    @7,53 GET mMEJMAJOR PICT "!"
    @8,53 GET mMEJMINOR PICT "!"
    @9,53 GET mMEJGRAND PICT "!"
    @10,53 GET aValues[M_NPLINES] PICT "9"
    @11,53 GET mMPAUSE  PICT "!"
    @15,53 GET aValues[M_NTITL]  PICT "9" ;
       VALID iif(aValues[M_NTITL]> 0 .and. aValues[M_NTITL] < 3,.t.,(msg("Debe ser 1 o 2")=="X") )
    @16,53 GET aValues[M_LINESEP]
    @17,53 GET aValues[M_SPACE]  PICT "9" ;
       VALID iif(aValues[M_SPACE]<2,.t.,(msg("Debe ser 0 or 1")=="X") )
    @18,53 GET aValues[M_COLSEP]
    @19,53 GET aValues[M_CSEPWID] PICT "9"
    @20,53 GET aValues[M_TSEP]
    READ
    aValues[M_EJB4] := if(mMEJB4 == "S",.t.,.f.)
    aValues[M_EJAFT] := if(mMEJAFT == "S",.t.,.f.)
    aValues[M_EJMAJOR] := if(mMEJMAJOR == "S",.t.,.f.)
    aValues[M_EJMINOR] := if(mMEJMINOR == "S",.t.,.f.)
    aValues[M_EJGRAND] := if(mMEJGRAND == "S",.t.,.f.)
    aValues[M_PAUSE] := if(mMPAUSE == "S",.t.,.f.)
    Scroll(2,19,23,78,0)
  CASE nPage = 3
    @ 1,20 SAY "[Opciones de P gina  3 "
    @ 3,20 SAY "Opciones Miscel neas"
    @ 4,20 SAY "--------------------------"
    @ 6,20 SAY "¨Incluye el encabezamiento normal?"
    @ 7,20 SAY "(N§ P gina, Fecha, Hora)"
    @ 9,20 SAY "Reporte Full o Sumario..........    (F/S)"
    @ 10,20 SAY "C¢digo Impresora inicial (dec)."
    @ 11,20 SAY "C¢digo de salida ..(decimal)...    (cuando sale)"

    @ 13,20 SAY "NOTA SOBRE CODIGOS DE IMPRESORA"
    @ 14,20 SAY "Usar los c¢digos de impresora DECIMALES separados"
    @ 15,20 SAY "por comas, o tipee los caracteres que aparecen en el"
    @ 16,20 SAY "manual de la impresora, utilizando el caracter @ en"
    @ 17,20 SAY "lugar de ESCAPE. Por Ejemplo: "
    @ 18,20 SAY "(C¢digos de HP LaserJet para ponerla en ITALIC)"
    @ 19,20 SAY "   1.DECIMAL       27,40,115,49,83"
    @ 20,20 SAY "   1.CARACTERES    @(s1S"
	 mMSTDHEAD := "S"
    @6,53 GET mMSTDHEAD  PICT "!"
    @9,53 GET aValues[M_FULLSUM]  PICT "!" ;
       VALID iif(aValues[M_FULLSUM]$'SF',.t.,;
            (msg("Debe ser S)mario o F)ull")=="X") )
    @10,53 GET aValues[M_PRNCODE] PICT "@S25"
    @11,53 GET aValues[M_AFTCODE] PICT "@S25"
    READ
    aValues[M_STDHEAD] := if(mMSTDHEAD == "S",.t.,.f.) 
    Scroll(2,19,23,78,0)
  ENDCASE
  DO CASE
  CASE LASTKEY() = K_UP  .OR. LASTKEY() = K_PGUP
    nPage = MAX(1,nPage-1)
  CASE LASTKEY() = K_ESC
    EXIT
  CASE LASTKEY() = K_CTRL_END
    EXIT
  OTHERWISE
    nPage++
  ENDCASE
  IF nPage > 3
    EXIT
  ENDIF
ENDDO
bOldf2 := SETKEY(-1,bOldf2)
Unbox(cBox)
RETURN ''

//-------------------------------------------------------------------------
STATIC function rEditThis   && line draw chars
LOCAL aLineChars := {"=","Í","_","Ä","|","³","º"}
local cBox,nSelection,i,nRow,nColumn
local nSubscript

nSubscript := getactive():subscript[1]

IF (nSubscript=M_MAJCHR .OR. nSubscript=M_MINCHR .OR. nSubscript=M_LINESEP ;
      .OR. nSubscript=M_COLSEP .OR. nSubscript=M_TSEP)

     SETKEY(-1)

     nRow    := row()
     nColumn := col()
     cBox    := makebox(nRow-1,nColumn+1,nRow+1,nColumn+25)
     @nRow-1,nColumn+2 say "[Caracteres Separadores]"
     @nRow,nColumn say ""
     for i = 1 to 7
       @row(),col()+2 prompt  aLineChars[i]
     next
     menu to nSelection

     unbox(cBox)
     if nSelection > 0
        keyboard aLineChars[nSelection]
     endif
     SETKEY(-1,{||rEditThis()})
ENDIF
return ''


//-------------------------------------------------------------------------
static FUNCTION rHeadsFeet
local cBox, i:=0
local nTop,nBot,nHeadJust,nFootJust

IF aValues[M_NHEAD]+aValues[M_NFOOT] =0
  RETURN ''
ENDIF


nTop := MIN(23-(aValues[M_NHEAD]+aValues[M_NFOOT]+4),6)
nBot := nTop+(aValues[M_NHEAD]+aValues[M_NFOOT]+5)
cBox := Makebox(nTop,3,nBot,76,sls_popcol())
@nTop,4 SAY "[Encabezamientos y Pie]"

IF aValues[M_NHEAD] > 0
  @nTop+1,5 SAY "Encabezamientos:"
  for i = 1 TO aValues[M_NHEAD]
    aHeader[i] := padr(aHeader[i],(aValues[M_WIDTH]-aValues[M_LEFTM]))
    @row()+1,5 GET aHeader[i] PICT "@S70"
  NEXT
ENDIF

IF aValues[M_NFOOT] > 0
  @nTop+1+i,5 SAY "Pies de P g:"
  for i = 1 TO aValues[M_NFOOT]
    aFooter[i] := padr(aFooter[i],(aValues[M_WIDTH]-aValues[M_LEFTM]))
    @row()+1,5 GET aFooter[i] PICT "@S70"
  NEXT (I)
ENDIF
READ

@nBot-2,5 CLEAR TO nBot-1,70

i := 0
IF aValues[M_NHEAD] > 0
  @ nBot-2,5 SAY "Encabezamientos: "
  @ nBot-2,16 PROMPT      "Dejar como est "
  @ nBot-2,col()+3 PROMPT "Centrado"
  @ nBot-2,col()+3 PROMPT "Justificado a la izquierda"
  @ nBot-2,col()+3 PROMPT "Justificado a la Derecha"
  MENU TO nHeadJust
  @nTop+1,5 SAY ""
  for i = 1 TO aValues[M_NHEAD]
    DO CASE
    CASE nHeadJust = 2
      aHeader[i] :=padc(alltrim(aHeader[i]),len(aHeader[i]))
    CASE nHeadJust = 3
      aHeader[i] :=Ljust(aHeader[i])
    CASE nHeadJust = 4
      aHeader[i] :=Rjust(aHeader[i])
    ENDCASE
    @row()+1,5 get aHeader[i] pict "@S70"
  NEXT
  clear gets
ENDIF
IF aValues[M_NFOOT] > 0
  @ nBot-1,5 SAY "Pies de P g "
  @ nBot-1,16 PROMPT      "Dejar como est "
  @ nBot-1,col()+3 PROMPT "Centrado"
  @ nBot-1,col()+3 PROMPT "Justificado a la Izquierda"
  @ nBot-1,col()+3 PROMPT "Justificado a la Derecha"
  MENU TO nHeadJust
  @nTop+1+i,5 SAY ""
  for i = 1 TO aValues[M_NFOOT]
    DO CASE
    CASE nHeadJust = 2
      aFooter[i] :=padc(alltrim(aFooter[i]),len(aFooter[i]))
    CASE nHeadJust = 3
      aFooter[i] :=Ljust(aFooter[i])
    CASE nHeadJust = 4
      aFooter[i] :=Rjust(aFooter[i])
    ENDCASE
    @row()+1,5 get aFooter[i] pict "@S70"
  NEXT (I)
  clear gets
ENDIF
@nBot-2,5 CLEAR TO nBot-1,70
@ nBot-1,5 SAY "Pulse una tecla...."
inkey(0)
Unbox(cBox)
RETURN ''

//-------------------------------------------------------------------------
static FUNCTION rCurrWidth
local nWidth,i
nWidth := aValues[M_LEFTM]+((aValues[M_NCOLS]-1)*aValues[M_CSEPWID])
for i = 1 TO aValues[M_NCOLS]
  nWidth := nWidth+VAL(aWidths[i])
NEXT
RETURN nWidth

//-------------------------------------------------------------------------
static FUNCTION rShowLayout
local cBox
local getlist := {}
cBox  := makebox(0,0,24,79,setcolor(),0,0)
@ 11,0 SAY 'Ã'
@ 11,79 SAY '´'
@ 20,0 SAY 'Ã'
@ 20,79 SAY '´'
@ 1,2 SAY "T¡tulo del Reporte"
@ 2,2 SAY "Nombre de la DBF"
@ 3,2 SAY "Clave del Indice"
@ 4,2 SAY "Grupo Principal"
@ 5,2 SAY "Grupo Secundario"
@ 6,2 SAY "Texto Principal"
@ 7,2 SAY "Texto Secundario"
@ 8,2 SAY "Consulta utlizada"
@ 9,2 SAY "C¢digo de Impresora"
@ 10,2 SAY "Reseteo de Impresora"
@ 11,1 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 12,2 SAY "Ancho de P gina          Long. P gina"
@ 13,2 SAY "Margen Izquierdo         Margen Arriba                 Espaciado"
@ 14,2 SAY "N§ de L¡neas Enc.        N§ L¡neas Pie         ¨ Usa Encab. Normal ?"
@ 15,2 SAY "¨ Subraya Totales?       Subrayado Princ.            Subrayado Menor"
@ 16,2 SAY "Pausa entre P ginas"
@ 17,2 SAY "Full or Sumario         N§ de Columnas           N§ l¡neas t¡tulo"
@ 18,2 SAY "Separador T¡tulo        Separador Columna        Ancho Columna Sep"
@ 19,2 SAY "Separador L¡nea"
@ 20,1 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 21,2 SAY "Saltar:Antes                Despu‚s          Si N§ l¡nea en el grupo"
@ 22,8 SAY "Antes Princip      Cambio Principal             Cambio Secundario"
@1,22 GET aValues[M_TITLE]
@2,22 GET aValues[M_DBF]
@3,22 GET aValues[M_NDXKEY] PICT "@S50"
@4,22 GET aValues[M_MAJKEY] PICT "@S50"
@5,22 GET aValues[M_MINKEY] PICT "@S50"
@6,22 GET aValues[M_MAJTEXT]
@7,22 GET aValues[M_MINTEXT]
@8,22 GET aValues[M_QUERY] PICT "@s40"
@9,22 GET aValues[M_PRNCODE]
@10,22 GET aValues[M_AFTCODE]
@12,22 GET aValues[M_WIDTH]  pict "999"
@12,43 GET aValues[M_LENGTH] pict "999"
@13,22 GET aValues[M_LEFTM]  pict "999"
@13,43 GET aValues[M_TOPM]   pict "999"
@13,72 GET aValues[M_SPACE]  pict "999"
@14,22 GET aValues[M_NHEAD]  pict "999"
@14,43 GET aValues[M_NFOOT]  pict "999"
@14,72 GET aValues[M_STDHEAD] pict "Y"
@15,22 SAY if(aValues[M_UNTOTAL],"S","N")
@15,43 GET aValues[M_MAJCHR]
@15,72 GET aValues[M_MINCHR]
@16,22 SAY if(aValues[M_PAUSE],"S","N")
@17,22 GET aValues[M_FULLSUM]
@17,43 GET aValues[M_NCOLS]  pict "999"
@17,72 GET aValues[M_NTITL]  pict "999"
@18,22 GET aValues[M_TSEP]
@18,43 GET aValues[M_COLSEP]
@18,72 GET aValues[M_CSEPWID] pict "999"
@19,22 GET aValues[M_LINESEP]
@21,22 SAY if(aValues[M_EJB4],"S","N")
@21,43 SAY if(aValues[M_EJAFT],"S","N")
@21,72 GET aValues[M_NPLINES] pict "9"
@22,22 SAY if(aValues[M_EJGRAND],"S","N")
@22,43 SAY if(aValues[M_EJMAJOR],"S","N")
@22,72 SAY if(aValues[M_EJMINOR],"S","N")
clear gets
INKEY(0)
UNBOX(cBox)
return ''

//-------------------------------------------------------------------------
STATIC FUNCTION rLoaded
return !EMPTY(aValues[M_TITLE])

//-------------------------------------------------------------------------
STATIC FUNCTION rLoadBlank

STORE "" TO aValues[M_NDXKEY],aValues[M_MAJKEY], aValues[M_MINKEY],aValues[M_QUERY]
STORE ALIAS()   TO aValues[M_DBF]
STORE SPACE(35) TO aValues[M_TITLE]
STORE 0 TO aValues[M_TOPM],aValues[M_LEFTM]
STORE 0 TO aValues[M_NHEAD],aValues[M_NFOOT],aValues[M_NCOLS],aValues[M_SPACE]
STORE 1 TO aValues[M_NTITL],aValues[M_CSEPWID]
STORE 4 TO aValues[M_NPLINES]
STORE 80 TO aValues[M_WIDTH]
STORE 66 TO aValues[M_LENGTH]
STORE .F. TO aValues[M_PAUSE],aValues[M_EJB4]
STORE .T. TO aValues[M_EJAFT]
STORE .F. TO aValues[M_EJMAJOR],aValues[M_EJMINOR],aValues[M_EJGRAND]
STORE .F. TO aValues[M_UNTOTAL]
STORE .F. TO aValues[M_STDHEAD]

STORE "-" TO aValues[M_TSEP], aValues[M_MAJCHR]
STORE "=" TO aValues[M_MINCHR]
STORE "|" TO aValues[M_COLSEP]
STORE " " TO aValues[M_LINESEP]
STORE "F" TO aValues[M_FULLSUM]
STORE SPACE(50) TO aValues[M_PRNCODE],aValues[M_AFTCODE]
STORE padr("Grupo Principal :",25) TO aValues[M_MAJTEXT]
STORE padr("Grupo Secundario:",25) TO aValues[M_MINTEXT]

aHeader := {}
aFooter := {}
aColumns := {""}
aTitles  := {space(10)}
aWidths  := {"  "}
aTotalYN := {" "}
aPictures:= {" "}
RETURN ''


//--------------------------------------------------------------------
static function rMaketb
local rTb
nElement := 1
rTb := tbrowseNew(3,18,18,76)
rTb:addcolumn(tbcolumnnew("#",{||trans(nElement,"99")}   )  )
rTb:addcolumn(tbcolumnnew("Column Contents",{||padr(aColumns[nElement],17)}   )  )
rTb:addcolumn(tbcolumnnew("Column Title",{||padr(aTitles[nElement],19)}   )  )
rTb:addcolumn(tbcolumnnew("Width",{||padc(aWidths[nElement],5)}  ))
rTb:addcolumn(tbcolumnnew("Pict" ,{||padc(aPictures[nElement],5)}  ))
rTb:addcolumn(tbcolumnnew("Total" ,{||padc(aTotalYN[nElement],5)}  )  )
rTb:skipblock      :=  {|n|aaskip(n)}
rTb:colsep         :=  "³"
rTb:headsep        :=  "Ä"
rTb:colorspec := sls_normcol()
rTb:gotopblock      := {||nElement := 1}
rTb:gobottomblock   := {||nElement := len(aColumns)}
return rTb

//-------------------------------------------------------------------------
static FUNCTION rBrowseEdit()
local nLastkey
local cInscreen := savescreen(0,0,24,79)
LOCAL rTb       := rMaketb() // tbrowse

DISPBEGIN()
@ 0,0,24,79 BOX "±±±±±±±±±" color sls_normcol()

@ 1,1,19,78 BOX "ÚÄ¿³ÙÄÀ³ "
@ 1,2 SAY "-= Editando Reporte: "+alltrim(aValues[M_TITLE])+"=-"
@ 21,0,24,79 BOX "ÚÄ¿³ÙÄÀ³ "
//@ 3,17 to 18,17
@ 3,3 SAY "[TECLAS]"
@ 5,3 SAY "<"+CHR(24)+" "+CHR(27)+" "+CHR(25)+" "+CHR(26)+">"
@ 6,3 SAY "para moverse"
@ 7,3 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 8,3 SAY "<ENTER> para"
@ 9,3 SAY "modificar"
@ 10,3 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 11,3 SAY "<INSERT> para"
@ 12,3 SAY "agregar      "
@ 13,3 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 14,3 SAY "<DELETE> para"
@ 15,3 SAY "borrar       "
@ 16,3 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 17,3 SAY "<F10> para"
@ 18,3 SAY "terminar"

rTb:colpos := 2
rTb:refreshall()
while !rTb:stabilize()
end
DISPEND()

DO WHILE .T.
  while !rTb:stabilize()
  end
  setcolor(sls_popcol())
  SCROLL(22,1,23,78,0)
  if aValues[M_NCOLS] > 0
    DO CASE
    CASE rTb:colpos=2
      @ 23,6 SAY LEFT(aColumns[nElement],60)
    CASE rTb:colpos=3
      @ 23,6 SAY LEFT(aTitles[nElement],60)
    CASE rTb:colpos=4
      @ 23,6 SAY "Ancho de Col: "+aWidths[nElement]
    CASE rTb:colpos=5.AND. !EMPTY(aPictures[nElement])
      @ 23,6 SAY "Picture     : "+aPictures[nElement]
    CASE rTb:colpos=6 .AND. aTotalYN[nElement]=="Y"
      @ 23,6 SAY "Totaliza esta Col"
    ENDCASE
  endif

  SET CURSOR OFF
  nLastKey := INKEY(0)
  SET CURSOR ON

  DO CASE
  CASE nLastkey = K_ESC .or. nLastkey==K_F10
    EXIT
  CASE nLastkey = K_ENTER
    if aValues[M_NCOLS]=0
      rColEdit(2)
      if !empty(aColumns[1])
        aValues[M_NCOLS] = 1
      endif
    else
      rColEdit(rTb:colpos)
    endif

  CASE nLastkey = K_INS  .AND. aValues[M_NCOLS] < 34
    if aValues[M_NCOLS] > 0
      //09-23-1992 changed
      //rAddColumn(rTb:rowpos)
      rAddColumn(nElement)
    endif
    aValues[M_NCOLS] := aValues[M_NCOLS]+1
    rTb:down()
    rTb:refreshall()
    while !rTb:stabilize()
    end
    setcolor(sls_popcol())
    rColEdit(2)
    IF EMPTY(aColumns[nElement])
      //09-23-1992
      rDelColumn(nElement)
      aValues[M_NCOLS] = aValues[M_NCOLS]-1
      if aValues[M_NCOLS]==0
        rLoadBlank()
        nElement := 1
      else
        nElement--
        if rTb:rowpos<>14
          rTb:up()
        endif
      endif
      //rTb:up()
      //rDelColumn(nElement)
      //nElement--
      //aValues[M_NCOLS] = aValues[M_NCOLS]-1
    ENDIF
    rTb:refreshall()
    while !rTb:stabilize()
    end
    setcolor(sls_popcol())
    *- check width
    IF rCurrWidth() > aValues[M_WIDTH]
      Msg("­CUIDADO!",;
        " El Ancho de P gina ha sido excedido:",;
        " Ancho de P gina definido          = "+TRANS(aValues[M_WIDTH],"999"),;
        " Longitud de las columnas          = "+TRANS(rCurrWidth(),"999"))
    ENDIF

  CASE nLastkey = K_INS .AND. aValues[M_NCOLS] = 34
    Msg("El m ximo de las columnas definidas (34)")
  CASE nLastkey = K_DEL .and. aValues[M_NCOLS] > 0  && delete
    //09-23-1992 changed
    rDelColumn(nElement)
    //rDelColumn(rTb:rowpos)
    aValues[M_NCOLS] = aValues[M_NCOLS]-1
    //09-23-1992
    if aValues[M_NCOLS]==0
      rLoadBlank()
      nElement := 1
    elseif nElement > aValues[M_NCOLS]
      nElement--
    endif
    rTb:refreshall()
  CASE nLastkey = K_RIGHT
    rTb:right()
  CASE nLastkey = K_LEFT  .and. rTb:colpos > 2
    rTb:left()
  CASE nLastkey = K_UP  && up
    rTb:up()
  CASE nLastkey = K_DOWN .AND. rTb:rowpos < aValues[M_NCOLS]
    rTb:down()
  CASE nLastkey == K_PGUP
    rTb:pageup()
  CASE nLastkey == K_PGDN
    rTb:pagedown()
  CASE nLastkey == K_HOME
    rTb:gotop()
  CASE nLastkey == K_END
    rTb:gobottom()
  ENDCASE
  rTb:refreshcurrent()
ENDDO (.T.)
restscreen(0,0,24,79,cInscreen)
return nil


//-------------------------------------------------------------------------
static FUNCTION rColEdit(nWhichColumn)
local nDoTotal,cTitleLen,cBox
local cTitle1,cTitle2

SCROLL(22,2,23,77,0)
DO CASE
CASE nWhichColumn = 2   && contents
  rExprEdit()

CASE nWhichColumn = 3   && title
  SCROLL(22,2,23,77,0)
  cTitleLen = VAL(aWidths[nElement])
  @22,5 SAY "Ingrese ancho del T¡tulo " GET cTitleLen PICT "99"
  READ
  scroll(22,2,23,77,0)
  cTitle1 = padr(Takeout(aTitles[nElement],';',1),cTitleLen)
  cTitle2 = padr(Takeout(aTitles[nElement],';',2),cTitleLen)
  @22,5 SAY "T¡tulo: "
  @22,14 GET cTitle1 PICT "@S70"
  IF aValues[M_NTITL]=2
    @23,14 GET cTitle2 PICT "@S70"
  ENDIF (aValues[M_NTITL]=2)
  READ
  aTitles[nElement]=cTitle1
  IF aValues[M_NTITL]=2
    aTitles[nElement] = aTitles[nElement]+';'+cTitle2
  ENDIF (aValues[M_NTITL]=2)
  IF Ascan(aDbfFields,TRIM(aColumns[nElement])) > 0
    aWidths[nElement]= TRANS(MAX(aDbfLens[ascan(aDbfFields,trim(aColumns[nElement]))],cTitleLen),"99")
  ENDIF
CASE nWhichColumn = 4   && width
  scroll(22,2,23,77,0)
  @22,5 SAY "Ingrese ancho de columna " GET aWidths[nElement] PICT "99"
  READ
CASE nWhichColumn = 5  .AND.  rGetTypeOf(aColumns[nElement])=="N" && picture
  cBox = Makebox(05,20,20,70,sls_popcol())
  aPictures[nElement]=padr(aPictures[nElement],20)
  @06,22 SAY "Picture: " GET aPictures[nElement]
  @row()+2,22 SAY "  9   Un N£mero"
  @row()+1,22 SAY "  .   Posici¢n del punto decimal."
  @row()+1,22 SAY "  ,   Inserta una coma"
  @row()+1,22 SAY "  *   Inserta asteriscos adelante."
  @row()+1,22 SAY "  $   Inserta $ adelante"
  @row()+1,22 SAY "  @(  Encierra n£meros negativos en ()"
  @row()+1,22 SAY "  @B  Justifica n£meros a la izquierda"
  @row()+1,22 SAY "  @C  Muestra CR despu‚s de un nro > 0"
  @row()+1,22 SAY "  @X  Muestra DB despu‚s de un nro < 0"
  @row()+1,22 SAY "  @Z  Muestra espacios en lugar de ceros"
  READ
  aPictures[nElement]=Alltrim(aPictures[nElement])
  Unbox(cBox)
CASE nWhichColumn = 5
  Msg("Campos Num‚ricos solamente","Usar el constructor de expresiones")
CASE nWhichColumn = 6  && total
  IF (rGetTypeOf(aColumns[nElement])=="N")
    @22,5 PROMPT "Totaliza esta Columna"
    @23,5 PROMPT "No totaliza esta columna"
    MENU TO nDoTotal
    aTotalYN[nElement]=IIF(nDoTotal=1,"Y","N")
  ELSE
    Msg("No se puede totalizar una columna no num‚rica")
  ENDIF
ENDCASE

scroll(22,2,23,77,0)
RETURN ''

//-------------------------------------------------------------------------
static FUNCTION rExprEdit
local lIsNew,nTypeOf,nSpaces,cString,expWhatever
local nFieldorSpace,nWhichField,nFieldorEx

lIsNew := .T.
DO WHILE .T.
   IF !EMPTY(aColumns[nElement])
     @22,5 PROMPT "Elija nuevo valor para esta columna        "
     @23,5 PROMPT "Extenderlo con el Contructor de Expresiones"
     MENU TO nTypeOf
     scroll(22,2,23,77,0)
     lIsNew := (nTypeOf=1)
   ENDIF
   scroll(22,2,23,77,0)
   IF LASTKEY()=27
     EXIT
   ENDIF

   IF lIsNew
     @22,5 PROMPT "Elegir un campo para esta columna"
     @23,5 PROMPT "Usar Espacios (para llenar)"
     MENU TO nFieldorSpace

     scroll(22,2,23,77,0)
     DO CASE
     CASE nFieldorSpace = 1
       nWhichField= Mchoice(aDbfFields,10,50,20,70,"Select Field")
       IF nWhichField > 0
         IF aDbfTypes[nWhichField]=="M"
           Msg("Los campos memo no se pueden imprimir")
         ELSE
           @22,5 PROMPT "Usar el valor contenido en el campo:    "+aDbfFields[nWhichField]
           @23,5 PROMPT "Construir una expresi¢n para el campo : "+aDbfFields[nWhichField]
           MENU TO nFieldorEx

           scroll(22,2,23,77,0)
           IF !nFieldorEx=2
             aColumns[nElement] = aDbfFields[nWhichField]
             aTitles[nElement]= aDbfFields[nWhichField]
             aWidths[nElement]= TRANS(MAX(aDbfLens[nWhichField],LEN(aTitles[nElement])),"99")
             aTotalYN[nElement]="N"
           ELSE
             aColumns[nElement]= buildex("Contenido de la columna del Reporte",aDbfFields[nWhichField],.T.,aDbfFields,aDbfFields)
             aTitles[nElement]= aDbfFields[nWhichField]
             aWidths[nElement]= TRANS( LEN( TRANS(aColumns[nElement],"") )  ,"99")
             aTotalYN[nElement]="N"
             aPictures[nElement]=""
           ENDIF
         ENDIF
       ENDIF

     CASE nFieldorSpace = 2    && must be 'use spaces'
       nSpaces="1"
       @22,5 SAY "Ingrese N§ de espacios 1-9 (0 = nada) " GET nSpaces PICT "9"
       READ
       IF VAL(nSpaces) >0
         aColumns[nElement] = "SPACE("+Alltrim(nSpaces)+")"
         aTitles[nElement]= " "
         aWidths[nElement]= " "+nSpaces
         aTotalYN[nElement]="N"
         aPictures[nElement]=""
       ENDIF
     ENDCASE

   ELSE   // extend current expression
     aColumns[nElement] := buildex("Contenido de la Columna del Reporte",;
                  aColumns[nElement],.T.,aDbfFields,aDbfFields)
     aWidths[nElement]  := TRANS( LEN( TRANS(aColumns[nElement],"") )  ,"99")
     aTotalYN[nElement] :="N"
   ENDIF
   if !empty(aColumns[nElement])
      aPictures[nElement]=IIF(rGetTypeOf(aColumns[nElement])=="N",;
              aPictures[nElement],"")
      if rGetTypeOf(aColumns[nElement])=="N" .and. empty(aPictures[nElement])
          cString := STR(&(aColumns[nElement]))
          *- look for a decimal point
          IF "." $ cString
            expWhatever := len(cString)-AT(".",cString)
            aPictures[nElement] := REPLICATE("9", val(aWidths[nElement])-(expWhatever+1))
            aPictures[nElement] := aPictures[nElement]+'.'+REPL("9",expWhatever)
          ELSE
            aPictures[nElement] := REPLICATE("9", val(aWidths[nElement]))
          ENDIF
      endif
   endif
   EXIT
ENDDO
return nil


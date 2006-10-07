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

//-------------------------------------------------------------------
EXTERNAL Stuff, Ljust, Rjust, allbut, subplus, startsw, Stod, crunch, strtran
EXTERNAL centr, proper, doyear, womonth, woyear, trueval, dtow
EXTERNAL endswith, dtdiff, daysin, datecalc, begend, nozdiv, stretch, arrange
//-------------------------------------------------------------------

static aDbfFields,aDbfTypes,aDbfLens
static aValues

static aHeader    // report headers
static aFooter    // report footers

*- column descriptions
static aColumns   // column contents
static aTitles  // column titles (delimited with ; for multiple)
static aWidths  // column widths
static aTotalYN  // column totals Y/N
static aPictures  // column picture
static aNdxKeys

//====================================================

FUNCTION QUIKREPORT(cReportName)

local cReportFile := slsf_report()
local aTagged     := {}
local nChoice,nOldArea,cInScreen,cOldCOlor,nOldOrder
local lUseTag,lUseQuery,i

aValues := array(38)
aHeader := array(9)
aFooter := array(9)
aColumns := array(34)
aTitles := array(34)
aWidths := array(34)
aTotalYN := array(34)
aPictures := array(34)
aNdxKeys := array(15)


if !file(cReportFile+".DBF")
	MSG("El archivo de reportes no se encuentra")
	return ''
elseif!used()
    MSG("No hay DBF abierta")
    return ""
endif
for i = 1 to 15
    aNdxKeys[i] = indexkey(i)
next
nOldArea  := select()
nOldOrder := indexord(0)
SELECT 0
cOldCOlor := setcolor(sls_popcol())
cInScreen := savescreen(0,0,24,79)

makebox(21,0,24,79,setcolor(),0,0)
@21,2 say "[Reporte R pido]"

if !SNET_USE(cReportFile,"__REPORTS",.F.,5,.T.,"Error de Red abriendo archivo REPORTE. ¨Reintenta?")
  select (nOldArea)
  return ''
ENDIF

SELECT (nOldArea)
rLoadReport(cReportName)
select __REPORTS
use
select (nOldArea)

@22,2  PROMPT "Sin Filtrar "
@23,2  PROMPT "Registros Marcados"
@22,35 PROMPT "Construir Nueva Consulta"
IF !EMPTY(aValues[M_QUERY])
  @23,35 PROMPT "Usar la £ltima Consulta"
ENDIF
MENU TO nChoice
SCROLL(22,1,23,78,0)

lUseTag   := .F.
lUseQuery := .F.

IF nChoice = 2
  Tagit(aTagged)
  lUseTag := (LEN(aTagged) > 0)
ELSEIF nChoice = 3
  * use new Query parameters
  QUERY("","","","A Reportes")
  aValues[M_QUERY] := sls_query()
ELSEIF nChoice = 4
  lUseQuery := .t.
ENDIF

@22,2 say "¨Imprime ahora?"
@23,2  PROMPT "Si"
@23,10 PROMPT "No"
menu to nChoice
SCROLL(22,1,23,78,0)
if nChoice = 1
    rPrintRep({aValues,aHeader,aFooter,aColumns,aTitles,aWidths,aTotalYN,;
               aPictures},lUseQuery,lUseTag,aTagged)          && print it , sam
endif
unbox(cInScreen,0,0,24,79)
setcolor(cOldCOlor)
set order to (nOldOrder)

aDbfFields:=aDbfTypes:=aDbfLens:=aValues:=nil
aHeader:=aFooter:=aColumns:=aTitles:=aWidths:=nil
aTotalYN:=aPictures:=aNdxKeys:=nil

return ''

//-------------------------------------------------------------------------
static FUNCTION rLoadReport(cReportName)

local nCountMatch,cBuffer,nMatches,nIndexOrd
local newkey,oldarea,cDbfNAme
local aMatchRec
local aRepTitles,i
local nFoundkey,cStoredKey

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

*- modify for quickreport---
SELECT __REPORTS

IF cReportName#nil
   LOCATE FOR STARTSW(__reports->sf_title,cReportName) .AND. ;
            (__reports->sf_dbf=cDbfName) .and. !deleted()
   IF EOF()
     Msg("No se encontraron coincidentacias de:",cReportName)
   ENDIF
ELSE
   LOCATE FOR __reports->sf_dbf=cDbfName .and. !deleted()
   IF EOF()
     Msg("No se encontraron coincidencias "+cDbfName)
   ENDIF
ENDIF

DO WHILE !EOF()
  aValues[M_NDXKEY] = ""
  aValues[M_MAJKEY] = ""
  aValues[M_MINKEY] = ""
  IF cReportName==nil
     COUNT FOR __reports->sf_dbf=cDbfName .and. !deleted() TO nCountMatch
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

     nCountMatch := Mchoice(aRepTitles,10,20,20,70,"Reportes Guardados")
     IF nCountMatch = 0
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
        msg("Usando ¡ndice =>"+aValues[M_NDXKEY])
        set order to (nFoundKey)
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
RETURN ''

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



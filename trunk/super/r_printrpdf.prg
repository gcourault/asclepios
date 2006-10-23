

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

//-------------------------------------------------------------------------
static aValues
static aHeader,aFooter,aColumns,aTitles,aWidths,aTotalYN,aPictures
static lCatchup
static nPageNumber
static nLineNumber
static nDestination
static nStartPage
static lEjectPage
static cOutFileName
static cStHead1
static cStHead2
static lAbortPrint
memvar getlist

//-------------------------------------------------------------------------
FUNCTION rPrintRepPDF(aInvalues,lUseQuery,lUseTag,aTagged)

LOCAL nMaxDetailLines,cPrintLine
LOCAL expMajorKey, expMinorKey,lIsMajorGroup,lIsMinorGroup
LOCAL lIsTotal,lMajorHeading,lMinorHeading
LOCAL cColumnSep,bGetMajor,bGetMinor
LOCAL lDoPrint,nThisWidth,expThisColumn,cDoPrint
LOCAL bQuery,nCounter
LOCAL aColBlocks,aMinorTotals,aMajorTotals,aGrandTotals
LOCAL nInkey,nLastKey,lAbandoned,cBox
LOCAL lDoMajorHEad
LOCAL lDoMinorHead



aValues     := aInValues[1]
aHeader     := aInValues[2]
aFooter     := aInValues[3]
aColumns    := aInValues[4]
aTitles     := aInValues[5]
aWidths     := aInValues[6]
aTotalYN    := aInValues[7]
aPictures   := aInValues[8]

lAbortPrint  := .f.
lDoMajorHEad := upper(alltrim(aValues[M_MAJTEXT]))<>"NONE"
lDoMinorHead := upper(alltrim(aValues[M_MAJTEXT]))<>"NONE"

*- totals arrays
aMinorTotals:= array(aValues[M_NCOLS])
aMajorTotals:= array(aValues[M_NCOLS])
aGrandTotals:= array(aValues[M_NCOLS])
aColBlocks := array(aValues[M_NCOLS])
lUseQuery  := iif(lUseQuery#nil,lUseQuery,.f.)
lUseTag    := iif(lUseTag#nil,lUseTag,.f.)
lUseTag    := iif(!empty(aTagged),lUseTag,.f.)

Afill(aMinorTotals,0)
Afill(aMajorTotals,0)
Afill(aGrandTotals,0)

cOutFileName="Informe.pdf"

*- variables used in reporting process
nPageNumber := 0
* nLineNumber := 0
nLineNumber := 1

nMaxDetailLines := aValues[M_LENGTH]-(aValues[M_NHEAD]+aValues[M_NFOOT]+aValues[M_NTITL]+2)
nMaxDetailLines := nMaxDetailLines-IIF(aValues[M_STDHEAD],2,0)-aValues[M_TOPM]
nMaxDetailLines := nMaxDetailLines-1

cColumnSep      := repl(aValues[M_COLSEP],aValues[M_CSEPWID])
lMinorHeading   := .f.
lMajorHeading   := .f.
lEjectPage      := .f.

IF aValues[M_STDHEAD]
  cStHead1 := "Fecha:"+DTOC(DATE())+SPACE(aValues[M_WIDTH]-24)
  cStHead2 := "Hora :"+TIME()
ENDIF

lIsMajorGroup := (!EMPTY(aValues[M_MAJKEY]))
lIsMinorGroup := (!EMPTY(aValues[M_MINKEY]))
lIsTotal      := (Ascan(aTotalYN,"S")> 0)
lAbandoned    := .f.
expMajorKey   := ""
expMinorKey   := ""
lDoPrint      := .F.
DO WHILE .T.
   scroll(22,2,23,77,0)
   cPrintLine := ""
   @22,5 SAY "Salida a: "
   @22,10 PROMPT "Impresora"
   @23,10 PROMPT "Archivo  "
   MENU TO nDestination
   nDestination := MAX(1,nDestination)

   scroll(22,2,23,77,0)
   IF LASTKEY()=27
     EXIT
   ENDIF
   IF nDestination=2  && file
     @22,5 SAY "Nombre del archivo al cual imprimir"
     @23,5 GET cOutFileName
     READ
     scroll(22,2,23,77,0)
   ENDIF

   IF LASTKEY()=27
     EXIT
   ENDIF

   *- starting page
   nStartPage := 1
   @22,5 SAY "Comenzar en p쟥ina N�:" GET nStartPage PICT "999"
   READ
   scroll(22,2,23,77,0)
   IF LASTKEY()=27
     EXIT
   ENDIF

   lCatchup := (nStartPage > 1)
   lDoPrint := .T.
	cDoPrint := "S"
   @22,5 SAY "쭯omienza la impresi줻? (S/N) " GET cDoPrint PICT "!" valid(cDoPrint$"SN")
   READ
	lDoPrint := (cDoPrint == "S")
   scroll(22,2,23,77,0)
   IF LASTKEY()=27
     lDoPrint = .f.
   ENDIF

   EXIT
ENDDO
IF !lDoPrint
  RETURN ''
ENDIF

aStyle := { "Normal" , "Bold" , "Italic" , "BoldItalic" }
aFonts := { { "Times",     .t., .t., .t., .t. },;
            { "Helvetica", .t., .t., .t., .t. },;
            { "Courier",   .t., .t., .t., .t. } }
IF nDestination=2
  
  pdfOpen( cOutFileName , 200 , .t. )
  *  SET PRINTER TO (cOutFileName )
else
  cOutFileName := uniqfname( "pdf" )
  pdfOpen( cOutFileName , 200 , .t. )
ENDIF

pdfBookOpen()
if !empty( aValues[M_PRNCODE])
   pdfSetFont("Courier" , 0 , 7 ) 
else
   pdfSetFont("Courier" , 0 , 10 )
endif
  
@0,48 SAY "ESPACIO para detener - ESC para salir"
cBox = Makebox(1,0,24,79,sls_popcol(),0)

for nCounter = 1 TO aValues[M_NCOLS]
  aColBlocks[nCounter] := &("{||"+aColumns[nCounter]+"}")
next

do while .t.
  *- LOCATE CLAUSE
  GO TOP
  IF lUseQuery
    bQuery := &("{||"+aValues[M_QUERY]+"}")
    LOCATE FOR eval(bQuery) WHILE (inkey()#27)
  ELSEIF lUseTag
    bQuery := {||ascan(aTagged,recno())>0}
    LOCATE FOR eval(bQuery) WHILE (inkey()#27)
  ELSE
    LOCATE FOR .T.
  ENDIF (lUseQuery)

  if aValues[M_EJB4] .and. found()
    * rOutput(chr(12))   // Salto de p쟥ina
    pdfNewPage( "A4" , "P" , 6 ) 
  endif

  IF FOUND()
    IF lIsMajorGroup
      bGetMajor      := &("{||"+aValues[M_MAJKEY]+"}")
      expMajorKey    := eval(bGetMajor)
      lMajorHeading  := .t.
    ENDIF (lIsMajorGroup)
    IF lIsMinorGroup
      bGetMinor      := &("{||"+aValues[M_MINKEY]+"}")
      expMinorKey    := eval(bGetMinor)
      lMinorHeading  := .t.
    ENDIF
    rPrintHead()
  ENDIF

  DO WHILE FOUND() .and. !lAbortPrint
    cPrintLine := ""
    nLastKey   := lastkey()
    nInkey     := inkey()
    IF nLastKey=27 .or. nInkey = 27
       clear typeahead
       if messyn("쭭bandona el reporte?")
          lAbandoned := .t.
          exit
       endif
       keyboard "X"
       inkey()
    ELSEIF nLastKey=32 .or. nInkey=32
       CLEAR TYPEAHEAD
       INKEY(0)
       keyboard "X"
       inkey()
    ENDIF


    IF lIsMajorGroup
        if lIsMinorGroup
          IF expMinorKey <> eval(bGetMinor)
            IF lIsTotal
             rPrntTotals(TRANS(expMinorKey,"")+" subtotales:",;
                         aMinorTotals,aValues[M_MINCHR])
             else
               rOutput("")
            endif
            expMinorKey     := eval(bGetMinor)
            lMinorHeading   := .t.
            lEjectPage      := iif(aValues[M_EJMINOR],.t.,lEjectPage)
          ENDIF
        endif
        IF (expMajorKey <> eval(bGetMajor) )
           if lIsTotal
             rPrntTotals(TRANS(expMajorKey,"")+" subtotales:",;
                         aMajorTotals,aValues[M_MAJCHR])
           else
             rOutput("")
           endif
           lEjectPage   := iif(aValues[M_EJMAJOR],.t.,lEjectPage)
           lEjectPage   := iif(nLineNumber+aValues[M_NPLINES]> nMaxDetailLines,;
                               .t.,lEjectPage)
           expMajorKey  := eval(bGetMajor)
           lMajorHeading := .t.
        ENDIF
    ELSEIF lIsMinorGroup
      IF expMinorKey <> eval(bGetMinor)
        if lIsTotal
         rPrntTotals(TRANS(expMinorKey,"")+" subtotales:",;
                           aMinorTotals,aValues[M_MAJCHR])
      else
         rOutput("")
      endif
        expMinorKey     := eval(bGetMinor)
        lEjectPage      := iif(aValues[M_EJMINOR],.t.,lEjectPage)
        lEjectPage      := iif(nLineNumber+aValues[M_NPLINES]> nMaxDetailLines,;
                            .t.,lEjectPage)
        lMinorHeading   := .t.
      ENDIF
    ENDIF

    lEjectPage := iif(nLineNumber>= nMaxDetailLines,.t.,lEjectPage)

    IF lEjectPage
      for nCounter = nLineNumber to nMaxDetailLines
        rOutput("")
      next
      * nLineNumber   := 0
      nLineNumber := 1
      rPrintFeet()
      * rOutput(chr(12))
      pdfNewPage("A4", "P" , 6 )

      if aValues[M_PAUSE]
         @24,2 say "[En pausa....pulse una tecla  ]" color "*"+setcolor()
         inkey(0)
         @24,2 say "컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�"
      endif

      rPrintHead()
      lMajorHeading := lIsMajorGroup
      lMinorHeading := lIsMinorGroup

    ENDIF


    if lMajorHeading .and. lDoMajorHead
       rOutput(TRIM(aValues[M_MAJTEXT])+" "+trans(expMajorKey,""))
       if !lMinorHeading
         rOutput("")
       endif
       lMajorHeading    :=.f.
    endif
    if lMinorHeading .and. lDoMinorHead
       rOutput(TRIM(aValues[M_MINTEXT])+' '+TRANS(expMinorKey,""))
       rOutput("")
       lMinorHeading    := .f.
    endif

    * print detail line
    if aValues[M_FULLSUM]=="F"
      cPrintLine        := ""
    endif

    for nCounter = 1 TO aValues[M_NCOLS]
      *expThisColumn = &( aColumns[nCounter] )
      expThisColumn = eval(aColBlocks[nCounter])

      * handle totals
      IF aTotalYN[nCounter]=="S"
        IF lIsMinorGroup
          aMinorTotals[nCounter] +=expThisColumn
        ENDIF
        IF lIsMajorGroup
          aMajorTotals[nCounter] += expThisColumn
        ENDIF
        aGrandTotals[nCounter] += expThisColumn
      ENDIF
      nThisWidth := VAL(aWidths[nCounter])

      if !empty(aPictures[nCounter])
        expThisColumn = padr(TRANS(expThisColumn,aPictures[nCounter]),nThisWidth)
      else
        expThisColumn = padr(TRANS(expThisColumn,""),nThisWidth)
      endif

      if aValues[M_FULLSUM]=="F"
        cPrintLine += expThisColumn
        IF !nCounter=aValues[M_NCOLS]
          cPrintLine += cColumnSep
        ENDIF
      endif
    NEXT


    if aValues[M_FULLSUM]=="F"
       rOutput(cPrintLine)
    ENDIF

    cPrintLine := ""

    if aValues[M_FULLSUM]=="F"
      if aValues[M_SPACE]=1
        rOutput(repl(aValues[M_LINESEP],aValues[M_WIDTH]))
      endif
      @24,2 say "[L죒ea "+TRANS(nLineNumber,"9999")+"               ]"
    endif

    * issue a CONTINUE
    CONTINUE


    IF !found() .and. lIsTotal      // INDICATES END OF FILE OR CONDITION
      if lIsMinorGroup
        rPrntTotals(TRANS(expMinorKey,"")+;
                     " subtotales:",aMinorTotals,aValues[M_MINCHR])
        lEjectPage  := iif(aValues[M_EJMINOR],.t.,lEjectPage)
      endif
      IF lIsMajorGroup
          rPrntTotals(TRANS(expMajorKey,"")+" subtotales:",;
                     aMajorTotals,aValues[M_MAJCHR])
          lEjectPage := iif(aValues[M_EJMAJOR],.t.,lEjectPage)
          lEjectPage := iif(nLineNumber+aValues[M_NPLINES]> ;
                        nMaxDetailLines,.t.,lEjectPage)
      ENDIF
      lEjectPage := iif(nLineNumber>= nMaxDetailLines,.t.,lEjectPage)
      lEjectPage := iif(aValues[M_EJGRAND],.t.,lEjectPage)

      IF lEjectPage
        for nCounter = nLineNumber to nMaxDetailLines
          rOutput("")
        next

        rPrintFeet()
        * rOutput(CHR(12))
        pdfNewPage("A4" , "P" , 6 )
        rPrintHead()

      ENDIF
      rPrntTotals(" Total Total  :",aGrandTotals,aValues[M_MAJCHR])

      for nCounter = nLineNumber to nMaxDetailLines
        rOutput("")
      next
      rPrintFeet()
    ELSEIF !found()   // END OF REPORT, NO TOTALS TO BE DONE
      for nCounter = nLineNumber to nMaxDetailLines
        rOutput("")
      next
      rPrintFeet()
    ENDIF

  ENDDO (FOUND())

  if !lAbandoned
    rOutput("")
    IF aValues[M_EJAFT]
      * rOutput(CHR(12))
      pdfNewPage( "A4" , "P" , 6 )
    ENDIF (aValues[M_EJAFT])

    * rPrintCodes(.f.)
    SET PRINT OFF
    pdfClose()
    if nDestination = 1
       cComandoImpresion :=  "c:\archiv~1\ghostgum\gsview\gsprint -query " + cOutFileName + "> NUL"
       run &cComandoImpresion

       delete file &cOutFileName
   endif

    SCROLL(2,1,23,78,3)
    @21,1 SAY ""
    @22,1 SAY ""
    @23,1 SAY " Reporte Completo - Pulse una tecla "
    INKEY(0)
  else
    * rPrintCodes(.f.)
    pdfClose()
  endif
  exit
enddo
Unbox(cBox)
@0,48 SAY "                                "
SET PRINT OFF
SET PRINTER TO
* SET PRINTER TO (sls_prn())
aValues:=aHeader:=aFooter:=aColumns:=aTitles:=aWidths:=aTotalYN:=aPictures:=nil
lCatchup:=nPageNumber:=nLineNumber:=nDestination:=nStartPage:=nil
lEjectPage:=cOutFileName:=cStHead1:=cStHead2:=nil

RETURN ''


//-------------------------------------------------------------------------
STATIC FUNCTION rPrntTotals(cTotalDesc,aTally,cUnderLine)
local nValue,cValue,nThisWidth
local nCounter
local cPrintLine := ""
local cPrintUnder:= ""
rOutput("")
rOutput(cTotalDesc)
for nCounter = 1 TO aValues[M_NCOLS]
  nThisWidth := val(aWidths[nCounter])
  IF aTotalYN[nCounter]=="S"
    nValue := aTally[nCounter]
    if !empty(aPictures[nCounter])
      cValue := TRANS(nValue,aPictures[nCounter])
    else
      cValue := rNTrans(nValue)
    endif
    cPrintLine += padr(cValue,nThisWidth)
    aTally[nCounter] = 0
    if aValues[M_UNTOTAL]                  // if underline totals
      cPrintUnder += repl(cUnderLine,nThisWidth)
    endif
  ELSE
     cPrintLine += SPACE(nThisWidth)
     cPrintUnder += SPACE(nThisWidth)
  ENDIF
  IF !nCounter=aValues[M_NCOLS]                // if not last column, add colsep width
    cPrintLine += space(aValues[M_CSEPWID])
    cPrintUnder += space(aValues[M_CSEPWID])
  ENDIF
NEXT (nCounter)
rOutput(cPrintLine)
if aValues[M_UNTOTAL]                  // if underline totals
  rOutput(cPrintUnder)
endif
rOutput("")
RETURN ''

//-------------------------------------------------------------------------
static FUNCTION rPrintHead
local nCounter,cPrintLine,cThisTitle,nWidth,nCount2
lEjectPage  := .f.
* nLineNumber := 0
nLineNumber := 1
nPageNumber++
if nPageNumber=nStartPage .and. lCatchup
	* SET PRINT ON
        * rPrintCodes(.t.)
        lCatchup := .f.
endif
for nCounter = 1 to aValues[M_TOPM]
   rOutput("")
next

IF aValues[M_STDHEAD]
  rOutput(cStHead1+"P쟥ina "+TRANS(nPageNumber,"9999") )
  rOutput(cStHead2)
ENDIF
for nCounter = 1 TO aValues[M_NHEAD]
 rOutput(LEFT(aHeader[nCounter],aValues[M_WIDTH])) 
NEXT
FOR nCounter = 1 TO aValues[M_NTITL]
  cPrintLine = ""
  for nCount2 = 1 TO aValues[M_NCOLS]
    cThisTitle := aTitles[nCount2]
    nWidth     := VAL(aWidths[nCount2])
    cPrintLine +=padr(Takeout(cThisTitle,';',nCounter),nWidth)
    IF !nCount2=aValues[M_NCOLS]
      cPrintLine := cPrintLine+space(aValues[M_CSEPWID])
    ENDIF
  NEXT
  rOutput(cPrintLine)
NEXT
rOutput(REPL(aValues[M_TSEP],aValues[M_WIDTH]))
RETURN ''

//-------------------------------------------------------------------------
static FUNCTION rPrintFeet
local nCounter
IF aValues[M_NFOOT] > 0
  rOutput(REPL(aValues[M_TSEP],aValues[M_WIDTH]))
ENDIF (aValues[M_NFOOT] > 0)
for nCounter = 1 TO aValues[M_NFOOT]
  rOutput(LEFT(aFooter[nCounter],aValues[M_WIDTH]))
NEXT
RETURN ''


//-------------------------------------------------------------------------
STATIC FUNCTION rOutput(cPrintLine)
if lCatchup
   @10,10 say "Capturando...p쟥ina "
   ??nPageNumber
else
   SCROLL(2,1,23,78,1)
   * SET CONSOLE OFF
   * SET PRINT ON
   if nDestination = 1                          // printer
     if  !lAbortPrint
       * ?space(aValues[M_LEFTM])+cPrintLine
        pdfAtSay( space( aValues[ M_LEFTM] + 2 ) + hb_oemtoansi( cPrintLine ), nLineNumber*4 , 3 , "M" )
     else
       lAbortPrint := .t.
     endif
   else
     * ?space(aValues[M_LEFTM])+cPrintLine
     pdfAtSay( space( aValues[ M_LEFTM] )  + hb_oemtoansi( cPrintLine ) , nLineNumber*4 , 3 , "M" )
   endif
   * SET CONSOLE ON
   * SET PRINT OFF
   @23,1 SAY LEFT(cPrintLine,77)
endif
nLineNumber++
return ''


//-------------------------------------------------------------------------
STATIC FUNCTION rPrintCodes(lStart)
local nCount,cThisCode
static cBeforeCode,cAftCode

if lStart==nil
    cBeforeCode := ""
    cAftCode    := ""
    * parse print code
    nCount := 1
    if !empty(aValues[M_PRNCODE])
      if "@"$aValues[M_PRNCODE]
        cBeforecode := STRTRAN(aValues[M_PRNCODE],"@",CHR(27))
      else
        cThisCode := takeout(aValues[M_PRNCODE],',',nCount)
        do while !empty(cThisCode)
          cBeforeCode := cBeforeCode+chr(val(cThisCode))
          nCount++
          cThisCode := takeout(aValues[M_PRNCODE],',',nCount)
        enddo
      endif
    endif

    * parse print AFTER code
    nCount = 1
      if "@"$aValues[M_AFTCODE]
        cAftcode := STRTRAN(aValues[M_AFTCODE],"@",CHR(27))
      else
        cThisCode = takeout(aValues[M_AFTCODE],',',nCount)
        do while !empty(cThisCode)
          cAftCode := cAftCode+chr(val(cThisCode))
          nCount++
          cThisCode := takeout(aValues[M_AFTCODE],',',nCount)
        enddo
      endif
elseif lStart
    if !empty(cBeforeCode)
       IF p_ready(sls_prn(),nil,.f.)
         set console off
         set print on
         ??cBeforeCode
         set console on
         set print off
       ELSE
         lAbortPrint := .t.
       ENDIF
    endif
else
    if !empty(cAftCode)
       IF p_ready(sls_prn(),nil,.f.)
         set console off
         set print on
         ??cAftCode
         set console on
         set print off
       ELSE
         lAbortPrint := .t.
       ENDIF
    endif
endif
return ''

//-------------------------------------------------------
Static Function rNTrans(nValue)
local cValue
local cPicture :=""
cValue := STR(nValue)
IF "." $ nValue
  cPicture := REPLICATE("9", AT(".", cValue) - 1) + "."
  cPicture := cPicture + REPLICATE("9", LEN(cValue) - LEN(cPicture))
ELSE
  cPicture := REPLICATE("9", LEN(cValue))
ENDIF
RETURN TRAN(nValue,cPicture)




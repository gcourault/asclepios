#include "inkey.ch"
FUNCTION getdate(dStartDate)

local cInfoBox,cCalBox,dCalcDate,dGlobDate,nLastkey,dOldDate
local nOldRow,nOldCol,nOldCursor



dispbegin()
dOldDate := SET_DATE(1)
nOldRow  := row()
nOldCol    := col()
nOldCursor := SETCURSOR(0)
cInfoBox   := makebox( 3,48,19,76,sls_popcol())
@  4,53 SAY  "  AVAILABLE KEYS  "
@  5,50 SAY CHR(26)+"      D║a Sig"
@  6,50 SAY CHR(27)+"      D║a Anterior"
@  8,50 SAY "<HOME>  Primer d║a del mes"
@  9,50 SAY "<END>   Ultimo d║a del mes"
@ 11,50 SAY CHR(24)+"      Sig Semana"
@ 12,50 SAY CHR(25)+"      Semana Ant"
@ 14,50 SAY "PgDn    Mes Siguiente"
@ 15,50 SAY "PgUp    Mes Anterior"
@ 16,50 SAY "<ENTER> Selecciona Fecha"
@ 17,50 SAY "<ESC>   Sale "
cCalBox  := makebox( 2, 8,20,40,sls_popcol())
@  3,10 TO 19, 38 DOUBLE
@  5,10 SAY 'гдддбдддбдддбдддбдддбдддбддд╤'
@  7,10 SAY 'гдддедддедддедддедддедддеддд╤'
@  8,11 SAY  '   Ё   Ё   Ё   Ё   Ё   Ё'
@  9,10 SAY 'гдддедддедддедддедддедддеддд╤'
@ 10,11 SAY  '   Ё   Ё   Ё   Ё   Ё   Ё'
@ 11,10 SAY 'гдддедддедддедддедддедддеддд╤'
@ 12,11 SAY  '   Ё   Ё   Ё   Ё   Ё   Ё'
@ 13,10 SAY 'гдддедддедддедддедддедддеддд╤'
@ 14,11 SAY  '   Ё   Ё   Ё   Ё   Ё   Ё'
@ 15,10 SAY 'гдддедддедддедддедддедддеддд╤'
@ 16,11 SAY  '   Ё   Ё   Ё   Ё   Ё   Ё'
@ 17,10 SAY 'гдддедддедддедддедддедддеддд╤'
@ 18,11 SAY  '   Ё   Ё   Ё   Ё   Ё   Ё'
@ 19,10 SAY 'хмммомммомммомммомммомммоммм╪'

Setcolor(sls_popcol())
@  6,11 SAY  'DOMЁLUNЁMARЁMIEЁJUEЁVIEЁSAB'

IF VALTYPE(dStartDate)<>"D"
  dStartDate := DATE()
ELSE
  IF EMPTY(dStartDate)
    dStartDate := DATE()
  ENDIF
ENDIF
dCalcDate := dStartDate
dGlobDate := CTOD("  /  /  ")
dGlobDate := drawmonth(dCalcDate,dGlobDate)

dispend()

DO WHILE .T.
  nLastkey = INKEY(0)
  DO CASE
  CASE nLastkey = K_ESC
    dCalcDate := dStartDate
    EXIT
  CASE nLastkey = K_ENTER
    EXIT
  CASE nLastkey = K_RIGHT
    dCalcDate := datecalc(dCalcDate,1,1)
  CASE nLastkey = K_LEFT
    dCalcDate := datecalc(dCalcDate,-1,1)
  CASE nLastkey = K_PGDN
    dCalcDate := datecalc(dCalcDate,1,3)
  CASE nLastkey = K_PGUP
    dCalcDate := datecalc(dCalcDate,-1,3)
  CASE nLastkey = K_UP
    dCalcDate := datecalc(dCalcDate,-1,2)
  CASE nLastkey = K_DOWN
    dCalcDate := datecalc(dCalcDate,1,2)
  CASE nLastkey = K_HOME
    dCalcDate := bom(dCalcDate)
  CASE nLastkey = K_END
    dCalcDate := bom(datecalc(dCalcDate,1,3))- 1
  OTHERWISE
    ??CHR(7)
  ENDCASE
  dGlobDate := drawmonth(dCalcDate,dGlobDate)
ENDDO

unbox(cCalBox)
unbox(cInfoBox)
DEVPOS(nOldRow,nOldCol)
SETCURSOR(nOldCursor)
SET_DATE(dOldDate)
RETURN(dCalcDate)



//====================================================
static FUNCTION drawmonth(dWorkDate,dOldDate)
local nIter,nCurrentRow,nDayOfWeek,nWeek
local aColumns := array(7)
local nDaysin
local getlist := {}
local nDayOfMonth

DISPBEGIN()
for nIter = 1 TO 7
  aColumns[nIter] = 8+(4*nIter)
NEXT

IF (MONTH(dOldDate) # MONTH(dWorkDate))
  @4,11 SAY padc(CMONTH(dWorkDate)+"  "+STR(YEAR(dWorkDate),4) ,25)
  IF !EMPTY(dOldDate)
    FOR nWeek = 8 TO 18 STEP 2
      for nIter = 1 TO 7
        @  nWeek, aColumns[nIter] SAY '  '
      NEXT
    NEXT
  ENDIF
  
  nDaysin     := daysin(dWorkDate)
  nCurrentRow := 8
  nDayOfWeek  := DOW(bom(dWorkDate))
  FOR nIter = 1 TO nDaysin
    @ nCurrentRow,aColumns[nDayOfWeek] SAY TRANS(nIter,"99")
    IF nDayOfWeek=7
      nCurrentRow := nCurrentRow+2
      nDayOfWeek  := 1
    ELSE
      nDayOfWeek++
    ENDIF
  NEXT
ELSE
  nDayOfWeek   := DOW(dOldDate)
  nCurrentRow  :=  6+(2*((DAY(dOldDate)+(7-DOW(dOldDate))+(DOW(bom(dOldDate))-1)) /7))
    @ nCurrentRow,aColumns[nDayOfWeek] SAY TRANS(day(dOldDate) ,"99")
ENDIF
nDayOfWeek = DOW(dWorkDate)
nCurrentRow =  6+(2*((DAY(dWorkDate)+(7-DOW(dWorkDate))+(DOW(bom(dWorkDate))-1)) /7))
nDayOfMonth := day(dWorkDate)
@ nCurrentRow,aColumns[nDayOfWeek] GET nDayOfMonth picture "99"
getlist := {}
DISPEND()
RETURN dWorkDate

*: EOF: S_GETDAT.PRG


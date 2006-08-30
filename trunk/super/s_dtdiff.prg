#define INDAYS          1
#define INWEEKS         2
#define INMONTHS        3
#define INYEARS         4

FUNCTION dtdiff(dDate1,dDate2,nDiffType)
local nReturn,nGreater,nLesser,nIterator

DO CASE
CASE (EMPTY(dDate1) .OR. EMPTY(dDate2))
  nReturn := 0
CASE dDate1=dDate2
  nReturn :=0
CASE nDiffType = INDAYS
  nReturn := ABS(dDate1-dDate2)
CASE nDiffType = INWEEKS
  nReturn := INT(ABS(dDate1-dDate2)/7)
CASE nDiffType = INMONTHS
  nGreater := IIF(dDate1 > dDate2,dDate1,dDate2)
  nLesser  := IIF(dDate1 < dDate2,dDate1,dDate2)
  nReturn  := 0
  DO WHILE nLesser <= nGreater
    nReturn++
    nLesser := nLesser+daysin(nLesser)
  ENDDO
  nReturn  := nReturn-1
CASE nDiffType = INYEARS
  nGreater := VAL(DTOS(IIF(dDate1 > dDate2,dDate1,dDate2)))
  nLesser  := VAL(DTOS(IIF(dDate1 < dDate2,dDate1,dDate2)))
  nReturn  := 0
  DO WHILE nLesser < nGreater
    nReturn++
    nLesser := nLesser+10000
  ENDDO
  nReturn := nReturn-1
ENDCASE
RETURN nReturn


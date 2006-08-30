#define ISDAYS          1
#define ISWEEKS         2
#define ISMONTHS        3
#define ISYEARS         4

FUNCTION datecalc(dInDate,nAddorSubtract,nPeriodType)
LOCAL dReturn,cStringDate,nOldDate
LOCAL nTheDay,nTheMonth,nTheYear,nDaysInMonth,nTotalMonths

nOldDate = SET_DATE(1)
dReturn = dInDate
DO CASE
CASE EMPTY(dInDate)
  dReturn := dInDate
CASE nPeriodType = ISDAYS
  dReturn := dInDate + (nAddorSubtract)
CASE nPeriodType = ISWEEKS
  dReturn := dInDate + (7 * nAddorSubtract)
CASE nPeriodType = ISMONTHS
  nTheDay       := DAY(dInDate)
  nTheMonth     := MONTH(dInDate)
  nTheYear      := YEAR(dInDate)
  nTotalMonths  := (nTheYear*12)+nTheMonth+nAddorSubtract-1
  nTheYear      := INT(nTotalMonths/12)
  nTheMonth     := nTotalMonths%12+1
  nDaysInMonth  :=  {31,28,31,30,31,30,31,31,30,31,30,31}[nTheMonth]
  nTheDay       := MIN(nTheDay,nDaysInMonth)
  dReturn       := CTOD(STR(nTheMonth,2) + "/" + STR(nTheDay,2) +;
                   "/" + STR(nTheYear,4))
CASE nPeriodType = ISYEARS
  if month(dInDate)=2 .and. day(dInDate)=29
    dInDate   := dInDate-1   && adjust for leapyear
  endif
  cStringDate := VAL(DTOS(dInDate))
  cStringDate := Alltrim(STR(cStringDate + (nAddorSubtract*10000)))
  dReturn     := Stod(cStringDate)
ENDCASE
SET_DATE(nOldDate)
RETURN dReturn


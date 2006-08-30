#define THEBEGINNING    1
#define THEEND          0
#define OFWEEK          1
#define OFMONTH         2
#define OFQUARTER       3


FUNCTION BEGEND(dInDate,nBeginOrEnd,nWeekMonthQuarter,nFirstDayOfWeek)
LOCAL  tdate,nStoreDate

* change to AMERICAN date format, store old format
nStoreDate := SET_DATE(1)
DO CASE
CASE EMPTY(dInDate)
CASE nWeekMonthQuarter = OFWEEK
  DO WHILE !DOW(dInDate)=nFirstDayOfWeek
    dInDate := dInDate+ IIF(nBeginOrEnd=THEBEGINNING,-1,1)
  ENDDO
CASE nWeekMonthQuarter = OFMONTH
  tdate = LEFT(DTOS(dInDate),6)
  IF nBeginOrEnd = THEBEGINNING
    dInDate := Stod(tdate+"01")
  ELSE
    dInDate := Stod(tdate+RIGHT(STR(daysin(dInDate)+100),2))
  ENDIF
CASE nWeekMonthQuarter = OFQUARTER
  DO CASE
  CASE MONTH(dInDate) < 4
    dInDate := CTOD(IIF(nBeginOrEnd=THEBEGINNING,"01/01/","03/31/")+;
              RIGHT(DTOC(dInDate),2) )
  CASE MONTH(dInDate) < 7
    dInDate := CTOD(IIF(nBeginOrEnd=THEBEGINNING,"04/01/","06/30/")+;
              RIGHT(DTOC(dInDate),2) )
  CASE MONTH(dInDate) < 10
    dInDate := CTOD(IIF(nBeginOrEnd=THEBEGINNING,"07/01/","09/30/")+;
              RIGHT(DTOC(dInDate),2) )
  CASE MONTH(dInDate) < 13
    dInDate := CTOD(IIF(nBeginOrEnd=THEBEGINNING,"10/01/","12/31/")+;
              RIGHT(DTOC(dInDate),2) )
  ENDCASE
ENDCASE

* restore to old SET DATE format
SET_DATE(nStoreDate)
RETURN dInDate


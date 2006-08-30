/*
   _SET_DATEFORMAT       Character         SET DATE
     AMERICAN           mm/dd/yy
     ANSI               yy.mm.dd
     BRITISH            dd/mm/yy
     FRENCH             dd/mm/yy
     GERMAN             dd.mm.yy
     ITALIAN            dd-mm-yy
     JAPAN              yy/mm/dd
     USA                mm-dd-yy
*/

FUNCTION SET_DATE(nNewFormat)
local nOldFormat,cOldFormat

nOldFormat := 0
cOldFormat :=  SET(_SET_DATEFORMAT)
do case
case cOldFormat == "AMERICAN"
  nOldFormat := 1
case cOldFormat == "BRITISH"
  nOldFormat := 2
case cOldFormat == "FRENCH"
  nOldFormat := 2
case cOldFormat == "GERMAN"
  nOldFormat := 3
case cOldFormat == "ANSI"
  nOldFormat := 4
case cOldFormat == "ITALIAN"
  nOldFormat := 5
endcase

if nNewFormat#nil
  DO CASE
  CASE nNewFormat = 1
         SET DATE AMERICAN
  CASE nNewFormat = 2
         SET DATE BRITISH
  CASE nNewFormat = 3
         SET DATE GERMAN
  CASE nNewFormat = 4
         SET DATE ANSI
  CASE nNewFormat = 5
         SET DATE ITALIAN
  ENDCASE
endif

return nOldFormat


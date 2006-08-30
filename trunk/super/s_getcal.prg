#include "inkey.ch"
FUNCTION GETCALC( nStartValue, lMakeChar)
local nOldDec           := SET(_SET_DECIMALS,4)
local nLastKey, cLastKey
local nDisplaySize      := 20
local cMemoryBox
local lDecFlag          := .F.
local lMemError         := .F.
local cLastOperator     := "+"
local lErrorFlag        := .F.
local cMemoryValue      := "0"
local nPerc

local cOperand           := "0"
local cDisplay           := "0"
local cTotal             := "0"

local nOldCursor        := setcursor(0)
local cOldColor         := SETCOLOR()
local cCalcBox          := MAKEBOX(3,25,20,55,sls_popmenu())

lMakeChar := iif(lMakeChar#nil,lMakeChar,.t.)
drawcalc()

IF VALTYPE(nStartValue)=="N"
   cTotal   := stripz(ALLTRIM(STR(nStartValue)))
   cDisplay := cTotal
ENDIF

DO WHILE .T.
   @ 5,31 CLEAR TO 5,52
   @ 5,52-LEN(cDisplay) SAY cDisplay

   nLastKey := INKEY(0)
   cLastKey := upper(chr(nLastkey))


   IF lErrorFlag .AND. cLastKey#"C"
      LOOP
   ENDIF
   
   DO CASE
   CASE nLastKey = K_F1         && cMemoryValue +
      IF !(lMemError)
         IF cMemoryValue == "0"  && SET IF NOT ALREADY
            cMemoryValue := stripz(IIF(cDisplay <> "0",;
                            ALLTRIM(cDisplay),ALLTRIM(cTotal)))
            IF cMemoryBox==nil
               cMemoryBox = MAKEBOX(3,60,5,78,sls_popmenu())
               @ 3,64 SAY "  MEMORIA  "
            ENDIF
            @ 4,61 CLEAR TO 4,77
            @ 4,75-LEN(cMemoryValue) SAY cMemoryValue
         ELSE          && INCREMENT cMemoryValue
            cMemoryValue := stripz(ALLTRIM(STR(VAL(cMemoryValue) + ;
                        IIF(cOperand <> "0",VAL(cOperand),VAL(cTotal)))))
            IF LEN(cTotal) > 12
               lMemError = .T.
               cMemoryValue = "E R R O R"
            ENDIF
            @ 4,61 CLEAR TO 4,77
            @ 4,75-LEN(cMemoryValue) SAY cMemoryValue
         ENDIF
      ELSE
         dotone()
      ENDIF
   CASE nLastKey = K_F2         && cMemoryValue -
      IF !(lMemError)
         IF cMemoryValue = "0"  && SET IF NOT ALREADY
            cMemoryValue = stripz(IIF(cDisplay <> "0","-","")+;
                   IIF(cDisplay <> "0",ALLTRIM(cDisplay),ALLTRIM(cTotal)))
            IF cMemoryBox==nil
               cMemoryBox = MAKEBOX(3,60,5,78,sls_popmenu())
               @ 3,64 SAY "  MEMORIA  "
            ENDIF
            @ 4,61 CLEAR TO 4,77
            @ 4,75-LEN(cMemoryValue) SAY cMemoryValue
         ELSE          && DECREMENT cMemoryValue
            cMemoryValue = stripz(ALLTRIM(STR(VAL(cMemoryValue) - ;
                  IIF(cOperand <> "0",VAL(cOperand),VAL(cTotal)))))
            IF LEN(cTotal) > 12
               lMemError = .T.
               cMemoryValue = "E R R O R"
            ENDIF
            @ 4,61 CLEAR TO 4,77
            @ 4,75-LEN(cMemoryValue) SAY cMemoryValue
         ENDIF
      ELSE
         dotone()
      ENDIF
   CASE nLastKey = K_F3         && cMemoryValue CLEAR
      IF cMemoryBox#nil
         IF cMemoryValue <> "0"
            cMemoryValue := "0"
            lMemError    := .F.
            @ 4,61 CLEAR TO 4,77
            @ 4,75-LEN(cMemoryValue) SAY cMemoryValue
         ENDIF
      ELSE
         dotone()
      ENDIF
   CASE nLastKey = K_F4         && cMemoryValue RECALL
      IF cMemoryBox== NIL
         dotone()
      ELSE
         cDisplay := cMemoryValue
         cOperand := cMemoryValue
      ENDIF
   CASE cLastKey = "%"         && PERCENTAGE
      nPerc := (val(cOperand)/100)
      DO CASE
      CASE cLastOperator == "+"
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) + (nPerc*val(cTotal)) )))
      CASE cLastOperator == "-"
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) - (nPerc*val(cTotal)) )))
      CASE cLastOperator == "*"
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) * nPerc )))
      CASE cLastOperator == "/"
         IF VAL(cOperand) = 0
            lErrorFlag := .T.
            cDisplay   := "E R R O R"
            LOOP
         ENDIF
         cTotal = stripz(ALLTRIM(STR(VAL(cTotal) / (nPerc*val(cTotal)) )))
      ENDCASE
      cLastOperator     := "+"
      cOperand          := "0"
      lDecFlag          := .F.
      IF LEN(cTotal) > 12
         lErrorFlag     := .T.
         cDisplay       := "E R R O R"
      ENDIF
      cDisplay = cTotal
      *
   CASE nLastKey = K_ENTER .OR. cLastKey = "="  && EQUALS HIT
      DO CASE
      CASE cLastOperator == "+"
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) + VAL(cOperand))))
      CASE cLastOperator == "-"
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) - VAL(cOperand))))
      CASE cLastOperator == "*"
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) * VAL(cOperand))))
      CASE cLastOperator == "/"
         IF VAL(cOperand) = 0
            lErrorFlag := .T.
            cDisplay   := "E R R O R"
            LOOP
         ENDIF
         cTotal = stripz(ALLTRIM(STR(VAL(cTotal) / VAL(cOperand))))
      ENDCASE
      cLastOperator     := "+"
      cOperand          := "0"
      lDecFlag          := .F.
      IF LEN(cTotal) > 12
         lErrorFlag     := .T.
         cDisplay       := "E R R O R"
      ENDIF
      cDisplay = cTotal
   CASE cLastKey = "C"        // clear
      cTotal    := "0"
      cOperand  := "0"
      cDisplay  := "0"
      lDecFlag  := .F.
      lErrorFlag := .F.
   CASE cLastKey = "E"       //clear entry
      cOperand  := "0"
      lDecFlag  := .F.
      lErrorFlag := .F.
      cDisplay  := cTotal
   CASE nLastKey = K_ESC .OR. cLastKey = "Q"  && ESCAPE KEY - EXIT
      EXIT
   CASE cLastKey$"0123456789"   && NUMERIC KEY
      IF lDecFlag
         cOperand := cOperand + CHR(nLastKey)
      ELSE
         if cOperand == "0"
           cOperand := CHR(nLastKey)
         else
           cOperand += CHR(nLastKey)
         endif
      ENDIF
      cDisplay    := cOperand
      IF LEN(cOperand) > nDisplaySize
         lErrorFlag := .T.
         cDisplay   := "E R R O R"
      ENDIF
   CASE  cLastKey = "."        && DECIMAL HIT
      IF !lDecFlag
         lDecFlag := .T.
         cOperand += "."
      ELSE
         dotone()
      ENDIF
      cDisplay := cOperand
   CASE  cLastKey$"*+/-"

      cOperand = stripz(cOperand)
      @ 5,31 CLEAR TO 5,52
      @ 5,52-LEN(cOperand) SAY cOperand
      
      DO CASE
      CASE cLastOperator = "+"
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) + VAL(cOperand))))
      CASE cLastOperator = "-"
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) - VAL(cOperand))))
      CASE cLastOperator = "*"
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) * VAL(cOperand))))
      CASE cLastOperator = "/"
         IF VAL(cOperand) = 0
            lErrorFlag := .T.
            cDisplay   := "E R R O R"
            LOOP
         ENDIF
         cTotal := stripz(ALLTRIM(STR(VAL(cTotal) / VAL(cOperand))))
      OTHERWISE
         cTotal := stripz(cOperand)
      ENDCASE
      cLastOperator := CHR(nLastKey)
      cOperand      := "0"
      lDecFlag      := .F.
      cDisplay      := cTotal
      IF LEN(cTotal) > 12
         lErrorFlag = .T.
         cDisplay = "E R R O R"
      ENDIF
   OTHERWISE
         dotone()
   ENDCASE
ENDDO
SET(_SET_DECIMALS,nOldDec)
SETCURSOR(nOldCursor)
UNBOX(cCalcBox)
IF cMemoryBox#nil
   UNBOX(cMemoryBox)
ENDIF
SETCOLOR(cOldColor)
RETURN iif(lMakeChar,cTotal,val(cTotal))


//--------strips trailing zeros (beyond right of decimal point)                                                                && Line 236: After RETURN never executed
static FUNCTION stripz(cOldValue)
if "."$cOldValue
  return strtran(trim(strtran(cOldValue,"0"," "))," ","0")
endif
return cOldValue

//=====================================================
static function drawcalc                                                                                                       && Line 240: After RETURN never executed
@7,27 say "╟╟╟╟╟╟╟"
@ 7,35 SAY "Calculadora        "
@  4,27 SAY "зддддддддддддддддддддддддд©"
@  5,27 SAY "Ё                         Ё"
@  6,27 SAY "юддддддддддддддддддддддддды"
@  8,27 SAY "зд©зд©зд©зд©зд©здддддддддд©"
@  9,27 SAY "Ё7ЁЁ8ЁЁ9ЁЁ+ЁЁCЁЁF1 [mem +]Ё"
@ 10,27 SAY "юдыюдыюдыюдыюдыюдддддддддды"
@ 11,27 SAY "зд©зд©зд©зд©зд©здддддддддд©"
@ 12,27 SAY "Ё4ЁЁ5ЁЁ6ЁЁ-ЁЁEЁЁF2 [mem -]Ё"
@ 13,27 SAY "юдыюдыюдыюдыюдыюдддддддддды"
@ 14,27 SAY "зд©зд©зд©зд©зд©здддддддддд©"
@ 15,27 SAY "Ё1ЁЁ2ЁЁ3ЁЁ*ЁЁ ЁЁF3 [mem C]Ё"
@ 16,27 SAY "юдыюдыюдыюдыюдыюдддддддддды"
@ 17,27 SAY "зд©зд©зд©зд©зд©здддддддддд©"
@ 18,27 SAY "Ё0ЁЁ.ЁЁ=ЁЁ/ЁЁQЁЁF4 [mem R]Ё "
@ 19,27 SAY "юдыюдыюдыюдыюдыюдддддддддды"
return nil

static proc dotone
tone(300,1)
tone(600,1)
tone(300,1)
return






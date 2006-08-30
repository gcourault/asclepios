static aMemHold


#include "inkey.ch"
FUNCTION gened(lAppending,nTop,nBottom,aFieldNames,aFieldDesc)

local cUnderWear,nFirstField,nMaxInBox,nCurrRow
local nCounter,nFieldLen,nPadding,cFieldName,cKeyIntent
local nFieldCount,nMemoCount,lSaveIt,cScrollPict,expValue,cDbfAlias
local nIndexOrd,nOldCursor, bOldF10,bOldF3,bOldF9
local cAliasString,nIter
local aValues
local cMemoGet
local getlist := {}
local nThisRecord := recno()

*- no dbf, no function
IF !used()
  msg("Database required")
  RETURN .F.
ENDIF
lAppending := iif(lAppending#nil,lAppending,.f.)

if !lAppending
   IF !SREC_LOCK(5,.T.,"No se puede bloquear el registro para EDITARLO. ¨Reintenta?")
     return .f.
   ENDIF
endif

* save environment, set things up
cUnderWear := savescreen(0,0,24,79)
nOldCursor := setcursor(1)
bOldF10    := setkey(-9,{||ctrlw()} )
bOldF3     := setkey(-2)

nFieldCount := iif(aFieldNames#nil,len(aFieldNames),fcount())
aMemHold := {}

*- if no params for dimensions, determine approprate dimensions
IF VALTYPE(nTop) <> "N"
  nTop = MAX(1,12-INT(nFieldCount/2) )
ENDIF
IF VALTYPE(nBottom) <> "N"
  nBottom = MIN(nTop+2+nFieldCount,23)
ENDIF

*- make two arrays - aFieldNames and field descriptions
IF aFieldNames==nil
  aFieldNames := array(nFieldCount)
  Afields(aFieldNames)
ENDIF
IF aFieldDesc==nil
  aFieldDesc := aclone(aFieldNames)
ENDIF

cDbfAlias       := ALIAS()
cAliasString    := cDbfAlias+"->"
aValues := array(nFieldCount+2)

*- if appending, store empty values, else store dbf values
IF lAppending
  GO BOTT
  SKIP
  for nIter = 1 TO nFieldCount
    expValue = aFieldNames[nIter]
    *- fill with value from current dbf
    *- testing for related file with $">"
    IF (">"$expValue) .AND. (!cAliasString$expValue)
      aValues[nIter] = &expValue
    ELSE
      aValues[nIter] = &cDbfAlias->&expValue
    ENDIF
  NEXT
  dbgoto( nThisRecord )
ELSE
  for nIter = 1 TO nFieldCount
    expValue = aFieldNames[nIter]
    *- fill with value from current dbf
    *- testing for related file with $">"
    IF ">"$expValue .AND. (!cAliasString$expValue)
      aValues[nIter] = &expValue
    ELSE
      aValues[nIter] = &cDbfAlias->&expValue
    ENDIF
  NEXT
ENDIF


*- set up some variables
nMemoCount      := 0
lSaveIt         := .F.
cMemoGet        := " "
Readexit(.T.)



*- draw the edit window

dispbox(nTop,2,nBottom,78)
if lAppending
  @ nBottom,3 SAY padc("[  | PGUP | PGDN  | ESCAPE para salir | F10 para grabar | F9 para COPIAR ]",75,"Ä")
  bOldF9 := setkey(K_F9,{||fillcurr(nFieldCount,aValues,aFieldNames,cAliasString,getlist,cDbfAlias) })
else
  @ nBottom,3 SAY padc("[  | PGUP | PGDN  | ESCAPE para grabar | F10 para grabar]",75,"Ä")
endif

*- start at the first field
nFirstField := 1

DO WHILE .T.
  IF lAppending
    *- appending
    @ nTop,4 SAY  "[ AGREGANDO REGISTRO "+STR(RECCOUNT()+1)+" ]"
    *- turn F3 off
    SET KEY -2 TO
  ELSE
    *- editing
    @ nTop,4 SAY  "[ EDITANDO REGISTRO "+STR(RECNO())+" ]"
    *- turn F3 on
    SET KEY -2 TO do_mem_ed
  ENDIF
  
  *- clear the whole box each time
  Scroll(nTop+1,3,nBottom-1,77,0)
  
  *- figure out last field in the box
  nMaxInBox  := MIN(nFirstField+(nBottom-nTop-3),nFieldCount)
  
  *- current row is 1
  nCurrRow   := nTop+1
  
  *- set memo count to 0
  nMemoCount := 0
  
  *- for each field from the first in the box to the last in the box
  FOR nCounter = nFirstField TO nMaxInBox
    nFieldLen  := LEN(aFieldDesc[nCounter])
    nPadding   := 15-nFieldLen
    cFieldName := aFieldNames[nCounter]
    IF ">"$cFieldName  .AND. (!cAliasString$expValue)
      *- account for related aFieldNames
      IF lAppending
        @nCurrRow,3 SAY aFieldDesc[nCounter]+SPACE(nPadding)+"<related file>"
      ELSE
        @nCurrRow,3 SAY aFieldDesc[nCounter]+SPACE(nPadding)+aValues[nCounter]
      ENDIF
    ELSEIF TYPE(cFieldName) = "M"
      *- increment memo count
      nMemoCount++
      
      *- store name of memo field to array element matching memo count
      aadd(aMemHold,cFieldName)
      
      *- if not appending, allow memo field editing
      *- but if appending, do not
      IF !lAppending
        *- say the field description and GET the placeholder
        @nCurrRow,3 SAY aFieldDesc[nCounter]+SPACE(nPadding)+' (CAMPO MEMO - PULSE F3 PARA EDITAR)' GET cMemoGet PICT "Y"
        ATAIL(getlist):name := cFieldName
      ELSE
        *- just say the description - no GET
        @nCurrRow,3 SAY aFieldDesc[nCounter]+SPACE(nPadding)+' (CAMPO MEMO)'
      ENDIF
    ELSEIF TYPE(cFieldName) = "C"
      *- character field
      @nCurrRow,3 SAY aFieldDesc[nCounter]+SPACE(nPadding)
      
      *- make a variable to hold a scrolling get picture of the
      *- appropriate length
      cScrollPict = "@S" + LTRIM(STR(76-COL() ))
      @ROW(),COL()+1 GET aValues[nCounter] PICT cScrollPict
    ELSE
      *- otherwise, just get SAY and GET the variable
      @nCurrRow,3 SAY aFieldDesc[nCounter]+SPACE(nPadding) GET aValues[nCounter] PICTURE ed_g_pic(cFieldName)
    ENDIF
    
    *- increment row
    nCurrRow = nCurrRow+1
  NEXT
  
  *- now do the READ
  READ
  
  cKeyIntent = getakey(LASTKEY())
  
  
  DO CASE
  CASE cKeyIntent = "FWD"
    *- determine what first field in box should be - wrap around if needed
    IF nMaxInBox+ 1 > nFieldCount
      nFirstField = 1
    ELSE
      nFirstField = MIN(nMaxInBox + 1,nFieldCount)
    ENDIF
  CASE cKeyIntent = "BWD"
    *- determine what first field in box should be
    IF nFirstField = 1
      nFirstField = 1
    ELSE
      nFirstField = MAX(nFirstField - 20,1)
    ENDIF
  CASE cKeyIntent = "ESC"
    IF abort()
      EXIT
    ENDIF
  CASE cKeyIntent = "CTW"
    IF messyn("¨Graba los cambios?")
      IF lAppending
       IF !SADD_REC(5,.T.,"No se puede bloquear el registro para grabar. ¨Reintenta?")
          lSaveIt = .f.
          EXIT
       ENDIF
       * record is locked with successful APPEND BLANK
      ENDIF
      *- replace aFieldNames with memvars
      nIndexOrd = INDEXORD()
      SET ORDER TO 0
      for nIter = 1 TO nFieldCount
        expValue = aFieldNames[nIter]
        IF !TYPE(expValue)=="M"
          REPLACE &expValue WITH aValues[nIter]
        ENDIF
      NEXT
      SET ORDER TO (nIndexOrd)
      lSaveIt = .T.
    ENDIF
    EXIT
  ENDCASE
ENDDO
unlock
GOTO RECNO()  && TO flush

*- kill the box, restore the environment and exit
RESTSCREEN(0,0,24,79,cUnderWear)
SETCURSOR(nOldCursor)
SETKEY(-9,bOldF10)
SETKEY(-2,bOldF3)
if lAppending
  SETKEY(K_F9,bOldF9)
endif

aMemHold := nil

RETURN lSaveIt

//------------------------------------------------------------------------
static proc fillcurr(nFieldCount,aValues,aFieldNames,cAliasString,aGets,cDbfAlias)
local nIter,expValue

for nIter = 1 TO nFieldCount
  expValue = aFieldNames[nIter]
  *- fill with value from current dbf
  *- testing for related file with $">"
  IF ">"$expValue .AND. (!cAliasString$expValue)
    aValues[nIter] = &expValue
  ELSE
    aValues[nIter] = &cDbfAlias->&expValue
  ENDIF
NEXT
for nIter := 1 to len(aGets)
  aGets[nIter]:display()
next
return

//------------------------------------------------------------------------

FUNCTION do_mem_ed(cGarbage,cCrap,cVarname)
IF ascan(aMemHold,cVarName) >0
  editmemo(cVarName)
ENDIF
RETURN ''





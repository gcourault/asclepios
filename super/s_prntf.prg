
*/*/ Additional parameter
FUNCTION prntfrml( cTemplate, nPageWidth,nLeftMArgin )

EXTERNAL DTOW
EXTERNAL PROPER

LOCAL nLines, nIter, cCurrentLine, nLeftMark, nRightMark, lEvaluating
local _object_, cFieldType,lBadLine,expFieldVal,cFirstHalf,cLastHalf
local lProperize,cLMSpaces

*- determine width, and do we want to lProperize the strings
IF nPageWidth==nil
  nPageWidth = 80
ENDIF

if nLeftMArgin<>NIL
      cLMSpaces := space(nLeftMArgin)
else
      cLMSpaces := ""
endif

*- determine number of lines
nLines = MLCOUNT(cTemplate, nPageWidth)

*- loop for # of lines
FOR nIter = 1 TO nLines
  
  lEvaluating  := .F.
  
  *- get the next line
  cCurrentLine := MEMOLINE(cTemplate, nPageWidth, nIter)
  
  *- its still ok
  lBadLine  := .F.
  
  *- find the first chr(174)
  nLeftMark := AT(CHR(174), cCurrentLine)
  
  
  *- if one was found
  DO WHILE nLeftMark != 0 .AND. !lBadLine
    
    lProperize  := .F.
    lEvaluating := .T.
    
    *- find the next chr(175)
    nRightMark := AT(CHR(175), cCurrentLine)
    
    *- if no find, its a bad line
    IF nRightMark = 0
      lBadLine := .T.
    ELSE
      
      *- extract the item between the delimiters
      _object_ := SUBSTR(cCurrentLine, nLeftMark+1,nRightMark - nLeftMark-1)
      IF LEFT(_object_,1) == CHR(221)
        _object_   := SUBSTR(_object_,2)
        lProperize := .T.
      ENDIF

      IF !EMPTY(_object_)
       if !(  (cFieldType := type(_object_))=="U" .or. cFieldType=="UE")
           _object_ := &_object_
           cFieldType := VALTYPE(_object_)
           DO CASE
           CASE cFieldType == "C"
             IF lProperize
               expFieldVal := TRIM(proper(TRIM(_object_)))
             ELSE
               expFieldVal := TRIM(_object_)
             ENDIF
           CASE cFieldType == "D"
             expFieldVal := DTOC(_object_)
           CASE cFieldType == "N"
             expFieldVal := LTRIM(TRANS(_object_,"999,999,999,999.99"))
           CASE _object_  == "DTOW(DATE())" .OR. _object_ = "FORMDATE()"
             expFieldVal := DTOW(DATE())
           OTHERWISE
             expFieldVal = ""
           ENDCASE
       else
          expFieldVal = ""
       endif
      else
         expFieldVal = ""
      endif
      *- put the translated line together
      cFirstHalf   := SUBSTR(cCurrentLine, 1, nLeftMark - 1)
      cLastHalf    := SUBSTR(cCurrentLine, nRightMark + 1)
      cCurrentLine := cFirstHalf+expFieldVal+cLastHalf
      
      *- check for another chr(174)
      nLeftMark    := AT(CHR(174), cCurrentLine)
    ENDIF
    
  ENDDO
  
  *- print the line
  IF !lBadLine .AND. !(lEvaluating .AND. EMPTY(STRTRAN(cCurrentLine,',')) )
    ? cLMSpaces+SUBST(cCurrentLine,1,nPageWidth)
  ENDIF
  
  
NEXT
RETURN ''


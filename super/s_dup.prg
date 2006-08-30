#include "inkey.ch"

FUNCTION duplook(cAlsoDisplay,aOpenIndexes,aInFields,aInFdesc)
EXTERNAL kbdesc

local aFields,aFdesc,aTypes,aPicked,cHeader
local cIndexExpr       := ''
local bIndexExpr
local nFieldCount,lMoreInfo
local nIter
local cDupList          := ''
local cTempNTX          := ''
local cTempTextFile     := ''
local lCheckDone        := .F.
local nStartRec,nOldArea,cDbfName
local cOldList,nElement,nSelection,nHandle
local nDupsFound,nCounter,cPercent,expMacroCurrent,nRecordNbr,nChoice,cInscreen
local cPrintScreen,cOutFileName,cOldColor
local nOldCursor,bOldf10
local cUnderPick
local cCheckBox
local cWhereBox
local cWriteString
local bAlsoDisplay

IF !USED()
  RETURN ''
ENDIF
aOpenIndexes  := iif(aOpenIndexes#nil,aOpenIndexes,{})
asize(aOpenIndexes,10)
for nIter = 1 to 10
  if aOpenIndexes[niter]==nil
    aOpenIndexes[niter] := ""
  endif
next


*- store environment
cInscreen := SAVESCREEN(0,0,24,79)
cOldColor := Setcolor()
nOldCursor:= setcursor(0)
bOldf10   := SETKEY(K_F10)

*- was a paramater passed (addt'l info string)
lMoreInfo := (cAlsoDisplay#nil)
if lMoreInfo
  bAlsodisplay := &("{||"+cAlsoDisplay+"}")
endif

*- declare arrays for fields, types, and picked
if aInfields==nil
   nFieldCount     := Fcount()
   aFields         := array(nFieldCount)
   aTypes          := array(nFieldCount)
   Afields(aFields,aTypes)
else
   nFieldCount     := len(aInFields)
   aFields         := aclone(aInFields)
   aTypes          := array(nFieldCount)
   Fillarr(aFields,aTypes)
endif
if aInFdesc==nil
  aFdesc    := array(nFieldCount)
  acopy(aFields,aFdesc)
else
  aFdesc    := aclone(aInFdesc)
endif

aPicked := {}


Setcolor(sls_normcol())
@0,0,24,79 BOX sls_frame()
*- draw the screen
Setcolor(sls_popcol())
@1,1,7,45 BOX sls_frame()
@18,1,23,78 BOX sls_frame()

@09,1,14,78 BOX sls_frame()
@09,2 SAY '[ Instrucciones: ]'
@10,2 SAY "     Primero seleccione los campos en los cuales Ud. desea buscar "
@11,2 SAY "registros duplicados (Item del menu 1). Luego haga que la computadora"
@12,2 SAY "ejecute la b£squeda (Item 2). Finalmente mire o imprima un informe "
@13,2 SAY "(Item del men£ 3)                                         "

@1,2 SAY '[ Detector de Duplicados ]'
@18,2 SAY "[ Campos a Chequear: ]"
SET PRINTER TO (sls_prn())

*- main loop
DO WHILE .T.
  GO TOP
  
  *- save dups list
  cOldList := cDupList
  
  *- display duplist
  sfdu_sayl(aPicked,aFdesc)
  
  *- do the menu
  Setcolor(sls_popmenu())
  @02,3 PROMPT "Seleccione los campos a comparar"
  @03,3 PROMPT "Generar lista de duplicados"
  @04,3 PROMPT "Informe de Duplicados"
  @05,3 PROMPT "Puerto de impresora"
  ??"  (ahora "+sls_prn()+")"
  @06,3 PROMPT "Salir"
  MENU TO nSelection
  Setcolor(sls_popcol())
  
  
  DO CASE
  CASE nSelection = 1
    
    aPicked := TAGARRAY(aFDesc, "Seleccionar los campos con posibles duplicados")
    
  CASE nSelection = 2 .AND. len(aPicked)>0
    
    *- look for duplicates, write them to a file


    *- make a temp index
    cTempNTX := UNIQFNAME(RIGHT(INDEXEXT(),3),getdfp())

    *- build indexing expression and header
    sfdu_figgr(aPicked, aFields, aTypes, ;
                @cIndexExpr, @bIndexExpr,@cHeader,lMoreInfo)

    ProgOn("Indexing")
    dbcreateindex(cTempNtx,"("+cIndexExpr+")",{||ProgDisp( recno(),recc() ),eval(bIndexExpr) },.f.)
    ProgOff()

    *- instructions

    cCheckBox :=makebox(09,20,15,60,sls_popcol())

    @10,22 SAY "Pulse ESC para CANCELAR"

    if !empty(cTempTextFile)
       erase (getdfp()+cTempTextFile)
    endif
    
    cTempTextFile := UNIQFNAME("",getdfp())
    
    *- create the file
    nHandle := Fcreate(getdfp()+cTempTextFile)
    
    *- write the cHeader to the file
    writefile(nHandle,'Record #   '+cHeader)
    
    *- no dups found yet
    nDupsFound := 0
    @11,22 SAY "Duplicados encontrados : "+TRAN(nDupsFound,'9999')
    
    *- start at top
    GO TOP
    
    *- init a counter
    nCounter = 1
    locate for !empty(eval(bIndexExpr))
    *- do while ESC not pressed, and not end of file
    DO WHILE !EOF() .AND. !inkey() = 27
      
      *- determine cPercent done and display it
      cPercent = STR(INT(nCounter/RECCOUNT()*100),3)+'% hecho'
      @12,22 SAY cPercent
      
      *- get the value for the current record re: the index expression
      expMacroCurrent := eval(bIndexExpr)
      
      *- store the record #
      nRecordNbr = RECNO()
      
      *- go to next record
      SKIP
      
      *- increment nCounter by 1
      nCounter = nCounter + 1

      *- check for dups
      *- if the index expression for this record matches that of our
      *- previous one, Vern found a duplicate
      IF (!EOF()) .AND. (eval(bIndexExpr) == expMacroCurrent)

        *- write out the data on the first record
        skip -1
        IF lMoreInfo
          *- if there is an additional info string (param 1)
          *- include it as part of the print string
          cWriteString = STR(nRecordNbr,5)+SPACE(6)+expMacroCurrent+' '+eval(bAlsoDisplay)

        ELSE
          *- otherwise, just the record number + the index key
          cWriteString = STR(nRecordNbr,5)+SPACE(6)+expMacroCurrent

        ENDIF

        *- write the line to file
        writefile(nHandle,cWriteString)
        skip

        *- do while duplicate(s) found and no ESC key pressed
        DO WHILE (!EOF()) .AND. (eval(bIndexExpr) == expMacroCurrent) .AND.(! inkey() = 27)

          *- increment dups found counter
          nDupsFound = nDupsFound +1

          *- for each duplicate found, write out a line
          IF lMoreInfo
            cWriteString = STR(RECNO(),5)+SPACE(6)+&cIndexExpr.+' '+eval(bAlsoDisplay)
          ELSE
            cWriteString = STR(RECNO(),5)+SPACE(6)+eval(bIndexExpr)
          ENDIF
          writefile(nHandle,cWriteString)

          *- info user of progress
          @11,22 SAY "Duplicados encontrados : "+TRAN(nDupsFound,'9999')

          *- next record
          SKIP

          *- increment counter
          nCounter = nCounter + 1

        ENDDO

        *- write a blank line between duplicate sets
        writefile(nHandle,'  ')
      ENDIF
      
      
    ENDDO
    
    *- we've done a duplicates check
    lCheckDone = .T.
    
    *- close the dups file
    Fclose(nHandle)
    SET INDEX TO
    if !empty(cTempNtx)
       erase (getdfp()+cTempNtx)
    endif

    *- notify user
    @12,22 SAY "Fin de la b£squeda de duplicados"
    @13,22 SAY "[Pulse una tecla......]"
    INKEY(0)
    
    unbox(cCheckBox)
    
  CASE nSelection = 2
    msg("Primero seleccione los campos a chequear")
  CASE nSelection = 3 .AND. !lCheckDone
    *- can't view without locating first              && no locate done
    msg("Busque los duplicados primero (Opci¢n 2)" )
    
    
  CASE nSelection = 3 .AND. lCheckDone
    
    *- make a menu
    cWhereBox=makebox(09,21,14,61,sls_popmenu())
    DO WHILE .T.
      @10,23 PROMPT "Ver Lista de Duplicados"
      @11,23 PROMPT "Imprimir Lista de Duplicados"
      @12,23 PROMPT "Enviar la Lista a un archivo"
      @13,23 PROMPT "Salir"
      MENU TO nChoice
      
      *- based on nSelection
      DO CASE
        
      CASE nChoice = 1
        *- read file
        Fileread(2,2,23,78,getdfp()+cTempTextFile,"Duplicates")
        
      CASE nChoice = 2
        
        IF !messyn("¨Imprime esta lista?")
          LOOP
        ENDIF
        IF p_ready(sls_prn())
          SAVE SCREEN TO cPrintScreen
          COPY FILE (cTempTextFile) TO (sls_prn())
          RESTORE SCREEN FROM cPrintScreen
        ENDIF
        
        
      CASE nChoice = 3
        
        *- get filename
        cOutFileName = SPACE(12)
        popread(.F.,"Archivo al cual escribir... : ",@cOutFileName,"@!")
        
        *- write to the file
        IF !EMPTY(cOutFileName)
          SAVE SCREEN TO cPrintScreen
          COPY FILE (cTempTextFile) TO (cOutFileName)
          RESTORE SCREEN FROM cPrintScreen
        ENDIF
        
        
      CASE nChoice = 4
        EXIT
        
      ENDCASE
      
    ENDDO
    unbox(cWhereBox)
    
    
  CASE nSelection = 4
    sls_prn(prnport())   
  CASE nSelection = 5 .OR. nSelection = 0
    SET INDEX TO (aOpenIndexes[1]),(aOpenIndexes[2]),(aOpenIndexes[3]),(aOpenIndexes[4]),(aOpenIndexes[5]),(aOpenIndexes[6]),(aOpenIndexes[7]),(aOpenIndexes[8]),(aOpenIndexes[9]),(aOpenIndexes[10])
    if !empty(cTempNTX)
       erase (getdfp()+cTempNTX)
    endif
    if !empty(cTempTextFile)
       erase (getdfp()+cTempTextFile)
    endif
    RESTORE SCREEN FROM cInscreen
    Setcolor(cOldColor)
    setcursor(nOldCursor)
    SETKEY(-9,bOldf10)
    
    RETURN ''
    
  ENDCASE
ENDDO
return ''


FUNCTION sfdu_sayl(aPicked,aFdesc)
local cDupList := ""
local nIter
for nIter = 1 to len(aPicked)
  cDuplist+= aFdesc[ aPicked[nIter] ]+' '
next
Scroll(19,2,22,77,0)
@19,3 SAY SUBST(cDupList,1,70)
@20,3 SAY SUBST(cDupList,71,70)
@21,3 SAY SUBST(cDupList,141,70)
@22,3 SAY SUBST(cDupList,211,70)
RETURN ''


static FUNCTION sfdu_figgr (aPicked, aFields, aTypes, ;
                cIndexExpr, bIndexExpr,cHeader,lMoreInfo)
local cFieldType,cFieldName,nCounter,cIndexPart,nExpLength
local nNameLength,cHeaderElem
local cFiller

cIndexExpr  := ''
cHeader     := ''

*- check all fields in the
FOR nCounter = 1 TO len(aPicked)
  

    *- determine name and type
    cFieldType := aTypes[aPicked[nCounter]]
    cFieldName := aFields[aPicked[nCounter]]
    
    *- if its not a memo field
    IF !cFieldType == "M"
      
      *- determine index key expression for that field (eval to character type)
      *- also determine length of the field expression
      DO CASE
        
      CASE cFieldType == "C"
        cIndexPart := aFields[aPicked[nCounter]]
        nExpLength := LEN(&cFieldName)
        
      CASE cFieldType == "N"
        cIndexPart := 'TRANS('+aFields[aPicked[nCounter]]+',"@Z")'
        nExpLength := LEN(TRANS(&cFieldName,"@Z"))
        
      CASE cFieldType == "D"
        cIndexPart := "DTOC("+aFields[aPicked[nCounter]]+')'
        nExpLength := 8
        
      CASE cFieldType == "L"
        cIndexPart := 'IIF('+aFields[aPicked[nCounter]]+',"T","F")'
        nExpLength := 1
        
      ENDCASE
      
      *- determine length of the field name
      nNameLength := LEN(aFields[aPicked[nCounter]])
      
      *- create appropriate cHeader, left justified for char
      *- right justified for numeric
      *- and with appropriate filler space to match expression length
      IF cFieldType == "N"
        cHeaderElem := SPACE(MAX(0,nExpLength-nNameLength))+aFields[aPicked[nCounter]]
      ELSE
        cHeaderElem := aFields[aPicked[nCounter]]+SPACE(MAX(0,nExpLength-nNameLength))
      ENDIF
      
      cFiller := ALLTRIM(STR(MAX(0,LEN(cHeaderElem)-nExpLength)))
      cFiller := iif(empty(cFiller),"0",cFiller)
      
      *- format expression to match cHeader
      cIndexExpr +=  cIndexPart+ '+space('+cFiller+')+" "+'
      
      *- prepare cHeader
      cHeader += cHeaderElem+' '
      
    ENDIF
NEXT

*- remove final '+' from expression
cIndexExpr  := LEFT(cIndexExpr,LEN(cIndexExpr)-1)
bIndexExpr  := &("{||"+cIndexExpr+"}")

cHeader     := iif(lMoreInfo,cHeader+" Otra Informaci¢n",cHeader)

RETURN nil




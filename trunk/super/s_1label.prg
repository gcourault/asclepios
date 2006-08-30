static aThisLabel
static nDimHeight
static nDimWidth
static nDimMargin
static nNumberofEach
static nDimLinesBetween

function s1label(cLblfile)
local nChoice,cBox,i
local aContents
local nRow := row()
local nCol := col()
aThisLabel := array(17)
nDimHeight := 5
nDimWidth  := 35
nDimMargin := 0
AFILL(aThisLabel,SPACE(60))
if cLblFile#nil .and. file(cLblFile) .and. openlabel(cLblFile)
   aContents := fill_label()
   cBox      := makebox(3,0,23,79,SLS_POPCOL())
   @ 3,3 SAY "[Imprimir una sola etiqueta]"
   @ 21,1 to 21,78
   @ 21,0 SAY "Ã"
   @ 21,79 SAY "´"
   for i = 1 to nDimHeight
     @3+i,2 say aContents[i] color sls_normcol()
   next

   do while .t.
        @22,2 PROMPT 'Imprimir'
        @22,14 PROMPT 'Editar '
        @22,25 PROMPT 'Salir  '
        menu to nChoice
        do case
           CASE nChoice = 1
              print(aContents)
           CASE nChoice = 2
             aContents := ledit(aContents)
           CASE nChoice = 3
               exit
        endcase
   enddo
   unbox(cBox)
endif
devpos(nRow,nCol)
aThisLabel:=nDimHeight:=nDimWidth:=nDimMargin:=nil
nNumberofEach:=nDimLinesBetween:=nil
return nil


static proc print(aContents)
LOCAL I
PRNPORT()
IF p_ready(sls_prn())
  set printer to (sls_prn())
  SET console off
  SET PRINT ON
  FOR I = 1 TO nDimHeight
    ?space(nDimMargin)+aContents[i]
  NEXT
  FOR I = 1 TO nDimLinesBetween
    ?
  NEXT
  SET PRINT OFF
  SET CONSOLE ON
  set printer to
ENDIF
return

//----------------------------------------------
STATIC FUNCTION OPENLABEL(cFileName)
local lValidFile := .t.
local nIter
local cLine
IF READLABEL(getdfp()+cFileName)

   *- for 1 to # of lines
   FOR nIter = 1 TO nDimHeight

     *- get the next line into a test var
     cLine := aThisLabel[nIter]

     *- test the var
     IF !EMPTY(cLine)
       IF (TYPE(cLine) == "U" .OR. TYPE(cLine) == "UE")
         msg("Esta etiqueta no coincide con la base de datos")

         *- if no match, set ok indicator off
         lValidFile := .F.
         *- and exit loop
         EXIT
       ENDIF
     ENDIF
   NEXT
ELSE
   Msg("No se puede leer los datos del archivo de etiquetas")
ENDIF
RETURN lValidFile


//----------------------------------------------
STATIC FUNCTION READLABEL(cLabelFile)
local cBuffer,nHandle,nIter,nOffset,lSuccess
LOCAL nDimAcross,nDimSpaceBetween
lSuccess = .f.

*- ensure the file exists, and open it
IF FILE(cLabelFile)
  nHandle = FOPEN(cLabelFile,16)  && exclusive, read
  IF Ferror()== 0
        AFILL(aThisLabel,SPACE(60))
        cBuffer = SPACE(1)
        FSEEK(nHandle,61)
        Fread(nHandle,@cBuffer,1)
        nDimHeight := ASC(cBuffer)
        FSEEK(nHandle,63)
        Fread(nHandle,@cBuffer,1)
        nDimWidth := ASC(cBuffer)
        FSEEK(nHandle,65)
        Fread(nHandle,@cBuffer,1)
        nDimMargin := ASC(cBuffer)
        FSEEK(nHandle,67)
        Fread(nHandle,@cBuffer,1)
        nDimLinesBetween := ASC(cBuffer)
        FSEEK(nHandle,69)
        Fread(nHandle,@cBuffer,1)
        nDimSpaceBetween := ASC(cBuffer)
        FSEEK(nHandle,71)
        Fread(nHandle,@cBuffer,1)
        nDimAcross := ASC(cBuffer)

        *- read in the contents line by line
        cBuffer := SPACE(60)
        nIter   := 1
        FOR nIter = 1 TO nDimHeight
          nOffset := 13+(60*nIter)
          FSEEK(nHandle,nOffset)
          Fread(nHandle,@cBuffer,60)
          aThisLabel[nIter] := IIF(EMPTY(cBuffer),SPACE(60),cBuffer)
        NEXT

        *- close the file
        Fclose(nHandle)
        lSuccess = .t.
  endif
endif
RETURN lSuccess
//-------------------------------------------------------------
static function fill_label
local nLabelLine
local cMacro,cThisLine
local aValues := array(nDimHeight)
local aReturn := array(nDimHeight)
local nCounter:= 0
for nLabelLine = 1 TO nDimHeight
  *- macro expand the line stored in the .lbl file
  cMacro := aThisLabel[nLabelLine]
  IF !EMPTY(TRIM(cMacro))
    cThisLine := crunch(&cMacro,1)
    aValues[nLabelLine] := PADR(cThisLine,nDimWidth)
  else
    aValues[nLabelLine] := SPACE(nDimWidth)
  ENDIF
NEXT
afill(aReturn,space(nDimWidth))
for nLabelLine = 1 TO nDimHeight
  IF !EMPTY(aValues[nLabelLine])
     nCounter++
     aReturn[nCounter] := aValues[nLabelLine]
  ENDIF
NEXT
return aREturn

//---------------------------------------------
static function ledit(aContents)
local cMemo := ""
local i
scroll(22,2,22,78,0)
@22,2 say "F10 Graba    -  ESC Cancela    -   CTRL-Y borra l¡nea"
for i = 1 to nDimHeight
  cMemo += trim(aContents[i])+chr(13)+chr(10)
Next
setcolor(sls_normcol())
cMemo := memoedit(cMemo,4,2,4+nDimHeight-1,2+nDimWidth-1,.t.,"SLPR_UDF")
setcolor(sls_popcol())
for i = 1 to nDimHeight
  aContents[i] := PADR(memoline(cMemo,100,i),nDimWidth)
  @3+i,2 say aContents[i] color sls_normcol()
next
scroll(22,2,22,78,0)
return aContents

//---------------------------------------------
FUNCTION slpr_udf( nMode, nLine, nColumn )
local nReturnVal,nLastKey
nReturnVal := 0

IF nMode = 0
  nReturnVal = 0
ELSEIF nMode < 3
  *- store last keystroke
  nLastKey = LASTKEY()
  DO CASE
  CASE nLastKey = 27
      if messyn("¨Sale sin grabar los cambios?")
         nReturnVal = 0
      else
         nReturnVal = 32
      endif
  CASE nLastKey =-9
      if messyn("¨Grabar y Salir?","Grabar/Salir","No Salir")
       KEYBOARD CHR(23)
       nReturnVal = 0
      endif
  OTHERWISE
    nReturnVal = 0
  ENDCASE
ENDIF
RETURN nReturnVal


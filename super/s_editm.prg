
static lImport,lExport,lChanged,lDone
static nBoxTop,nBoxLeft

FUNCTION editmemo(cMemoName,nTop,nLeft,nBottom,nRight,lEdit,nLineWidth)
local nCursor,nOption,lDidChange
local cMemoBox,nWidth,cHoldit,cFileName,nShadPos

*- default memo field name = MEMO
IF Pcount() < 1
  cMemoName := "MEMO"
ENDIF

*- edit or view
IF VALTYPE(lEdit)<>"L"
  lEdit := .T.
ENDIF

*- if we don't see that field, or there's no DBF, get outa here
IF TYPE(cMemoName) <> "M"  .OR. (!USED())
  RETURN ''
ENDIF

nCursor := setcursor(1)

*- if we didn't get box coordinates, assign some
IF Pcount() < 5
  nTop    := 2
  nLeft   := 1
  nBottom := 20
  nRight  := 78
ELSEIF nRight-nLeft < 50
  nLeft   := 1
  nRight  := 78
ENDIF
nBoxTop  := nTop
nBoxLeft := nLeft

if valtype(nLineWidth)<>"N"
  nLineWidth := (nRight-nLeft)-1
endif
nShadPos := sls_shadpos()
IF nTop=0 .or. nBottom = 24 .or. nLeft = 0 .or. nRight = 79
        nShadPos = 0
ENDIF
*- draw the box
cMemoBox :=makebox(nTop,nLeft,nBottom,nRight,sls_popcol(),nShadPos)
@nTop,nLeft+1 SAY "[MEMO PAD]"
IF lEdit
  @nBottom,nLeft+1 SAY "[ F10:GRABA| ESC:SALE | F5:Importa|F6:Exporta]"
ELSE
  @nBottom,nLeft+1 SAY "[ ESC:SALIR ]"
ENDIF


*- do the MEMOEDIT
lChanged := .f.
lDone    := .F.
lImport  := .F.
lExport  := .F.
DO WHILE !lDone
  lDone  := .T.
  IF lEdit
    if SREC_LOCK(5,.T.,"Error de Red - No se puede bloquear registro. ¨Reintenta?")
      cHoldit := Memoedit(&cMemoName,nTop+1,nLeft+1,nBottom-1,nRight-1,lEdit,"sfme_udf",nLineWidth)
      IF !LASTKEY()==27
        REPLACE &cMemoName WITH cHoldit
      ENDIF
      IF lImport
        cFileName := SPACE(40)
        popread(.T.,"Archivo de texto a importar: (se pueden usar comodines, blancos = todos) ",@cFileName,"")
        cFileName := Alltrim(UPPER(cFileName))
        IF !LASTKEY() == 27
         IF EMPTY(cFileName) .OR. AT('*',cFileName) > 0
           IF EMPTY(cFileName)
             cFileName = "*.*"
           ENDIF
           cFileName := popex(cFileName)
         ENDIF
        ENDIF
        IF EMPTY(cFileName)
        ELSEIF FILE(cFileName)
          IF fileinfo(cFileName,1) > (MEMORY(0)*1000)
            msg("Archivo muy grande para la memoria existente")
          ELSE
            nOption = menu_v("Optiones: (CAMBIOS PERMANENTES)",;
                              "Reemplaza el contenido existente",;
                              "Agrega al contenido existente","Cancelar")
            DO CASE
            CASE nOption = 1
              if "\"$cFileName .or. ":"$cFileName
                REPLACE &cMemoName WITH MEMOREAD(cFileName)
              else
                REPLACE &cMemoName WITH MEMOREAD(getdfp()+cFileName)
              endif
            CASE nOption = 2
              if "\"$cFileName .or. ":"$cFileName
                REPLACE &cMemoName WITH &cMemoName+CHR(13)+CHR(10)+MEMOREAD(cFileName)
              else
                REPLACE &cMemoName WITH &cMemoName+CHR(13)+CHR(10)+MEMOREAD(getdfp()+cFileName)
              endif
            ENDCASE
          ENDIF
        ELSE
          msg("Archivo no encontrado")
        ENDIF
      ELSEIF lExport
        cFileName := SPACE(40)
        popread(.T.,"archivo de texto al que exportar :",@cFileName,"")
        cFileName := Alltrim(UPPER(cFileName))
        IF FILE(cFileName)
          IF messyn("El archivo existe - ¨Sobreescribe?")
          if "\"$cFileName .or. ":"$cFileName
            Memowrit(cFileName,cHoldit)
          else
            Memowrit(getdfp()+cFileName,cHoldit)
          endif
          ENDIF
        ELSE
          if "\"$cFileName .or. ":"$cFileName
            Memowrit(cFileName,cHoldit)
          else
            Memowrit(getdfp()+cFileName,cHoldit)
          endif
        ENDIF
      ENDIF
    ENDIF
  ELSE
    *#10-29-1990 Removed 7th param (.f.) so memo will stay on screen
    cHoldit = Memoedit(&cMemoName,nTop+1,nLeft+1,nBottom-1,nRight-1,lEdit)
  ENDIF
  lImport = .F.
  lExport = .F.
ENDDO
*- clean up
unbox(cMemoBox)
setcursor(nCursor)
lDidChange := lChanged
lImport:=lExport:=lChanged:=lDone:=nBoxTop:=nBoxLeft:=nil
RETURN lDidChange



FUNCTION sfme_udf( nMode, nLine, nColumn )
local nReturnVal,nLastKey

nReturnVal := 0
if nMode = 2
  lChanged = .t.
endif

IF nMode = 0
  *- show row/column
  @nBoxTop,nBoxLeft+15 SAY "L¡nea: " + TRANS(nLine, "9999")
  @ROW(),COL()+2 SAY "Columna:" + TRANS(nColumn, "9999")
  nReturnVal = 0
ELSEIF nMode < 3
  *- store last keystroke
  nLastKey = LASTKEY()
  DO CASE
  CASE nLastKey =-4
    lImport = .T.
    lDone = .F.
    KEYBOARD CHR(23)
    nReturnVal = 0
  CASE nLastKey =-5
    lExport = .T.
    lDone = .F.
    KEYBOARD CHR(23)
    nReturnVal = 0
  *#10-29-1990 Added MESSYN for ESCAPE key
  CASE nLastKey = 27
    if lChanged
      if messyn("¨Sale sin grabar los cambios?")
         nReturnVal = 0
      else
         nReturnVal = 32
      endif
    else
      nReturnVal = 0
    endif
  *#10-29-1990 Added MESSYN for F10 key
  CASE nLastKey =-9
    if lChanged
      if messyn("¨Graba y Sale?","Graba/Sale","No Sale")
       KEYBOARD CHR(23)
       nReturnVal = 0
      endif
    else
       KEYBOARD CHR(27)
       nReturnVal = 32
    endif
  OTHERWISE
    nReturnVal = 0
  ENDCASE
ENDIF
RETURN nReturnVal



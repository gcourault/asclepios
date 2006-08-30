static lImport,lExport,lChanged,lDone
static nBoxTop,nBoxLeft

FUNCTION editmemoV(cMemoBuff,nTop,nLeft,nBottom,nRight,lEdit,nLineWidth)
local nCursor,nOption
local cMemoBox,nWidth,cFileName,nShadPos

*- edit or view
IF VALTYPE(lEdit)<>"L"
  lEdit := .T.
ENDIF

nCursor := setcursor(1)

*- if we didn't get box coordinates, assign some
IF nTop==nil .or. nLeft==nil.or. nRight==nil .or. nBottom==nil
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
  nShadPos := 0
ENDIF
*- draw the box
cMemoBox := makebox(nTop,nLeft,nBottom,nRight,sls_popcol(),nShadPos)
@nTop,nLeft+1 SAY "[MEMO PAD]"
IF lEdit
  @nBottom,nLeft+1 SAY "[ F10:GRABA| ESC:SALE | F5:Importa|F6:Exporta]"
ELSE
  @nBottom,nLeft+1 SAY "[ ESC:SALE ]"
ENDIF


*- do the MEMOEDIT
lChanged := .f.
lDone    := .F.
lImport  := .F.
lExport  := .F.
DO WHILE !lDone
  lDone  := .T.
  IF lEdit
      cMemoBuff := Memoedit(cMemoBuff,nTop+1,nLeft+1,nBottom-1,nRight-1,lEdit,"sfme_udfv",nLineWidth)
      IF lImport
        cFileName := SPACE(40)
        popread(.T.,"Archivo de texto a Importar: (se pueden usar comodines - blanco para todos) ",@cFileName,"")
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
            msg("File too big for existing memory")
          ELSE
            nOption := menu_v("Optiones: (LOS CAMBIOS SON PERMANENTES)",;
                              "Reemplazar el contenido existente",;
                              "Agregar al contenido existente","Cancelar")
            DO CASE
            CASE nOption = 1
              if "\"$cFileName .or. ":"$cFileName
                cMemoBuff := MEMOREAD(cFileName)
              else
                cMemoBuff := MEMOREAD(getdfp()+cFileName)
              endif
            CASE nOption = 2
              if "\"$cFileName .or. ":"$cFileName
                cMemoBuff += chr(13)+chr(10)+MEMOREAD(cFileName)
              else
                cMemoBuff += chr(13)+chr(10)+MEMOREAD(getdfp()+cFileName)
              endif
            ENDCASE
          ENDIF
        ELSE
          msg("Archivo no encontrado")
        ENDIF
      ELSEIF lExport
        cFileName := SPACE(40)
        popread(.T.,"Archivo de texto al cual exportar :",@cFileName,"")
        cFileName := Alltrim(UPPER(cFileName))
        IF FILE(cFileName)
          IF messyn("El archivo existe ¨Sobreescriba?")
          if "\"$cFileName .or. ":"$cFileName
            Memowrit(cFileName,cMemoBuff)
          else
            Memowrit(getdfp()+cFileName,cMemoBuff)
          endif
          ENDIF
        ELSE
          if "\"$cFileName .or. ":"$cFileName
            Memowrit(cFileName,cMemoBuff)
          else
            Memowrit(getdfp()+cFileName,cMemoBuff)
          endif
        ENDIF
      ENDIF
  ELSE
    *#10-29-1990 Removed 7th param (.f.) so memo will stay on screen
    cMemoBuff := Memoedit(cMemoBuff,nTop+1,nLeft+1,nBottom-1,nRight-1,lEdit)
  ENDIF
  lImport = .F.
  lExport = .F.
ENDDO
*- clean up
unbox(cMemoBox)
setcursor(nCursor)
lImport:=lExport:=lChanged:=lDone:=nBoxTop:=nBoxLeft:=nil
RETURN cMemoBuff



FUNCTION sfme_udfv( nMode, nLine, nColumn )
local nReturnVal,nLastKey

nReturnVal := 0
if nMode = 2
  lChanged = .t.
endif

IF nMode = 0
  *- show row/column
  @nBoxTop,nBoxLeft+15 SAY "L¡nea: " + TRANS(nLine, "9999")
  @ROW(),COL()+2 SAY "Columna: " + TRANS(nColumn, "9999")
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
      if messyn("¨Graba y sale?","Graba/Sale","No Sale")
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




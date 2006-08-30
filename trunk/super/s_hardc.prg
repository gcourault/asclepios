//-------------------------------------------------------------
FUNCTION hardcopy(aFields,aFieldDesc,aFieldTypes)
local nRecorMem  := 1
local nTargetDev := 1
LOCAL cOutFile
LOCAL aMemos := {}
LOCAL i,nMemo,cMemo,nLineCount
LOCAL nLpp := 60,nCpp := 79

if aFields==nil .or. aFieldDesc==nil .or. aFieldTypes==nil
  aFields     := afieldsx()
  aFieldDesc  := afieldsx()
  aFieldTypes := aftypesx()
  aMemos      := afieldstype("M")
elseif aMatches(aFieldTypes,"M") > 0
  aMemos := acopym(aFields,aFieldTypes)
endif


DO WHILE .T.
  IF len(aMemos) > 0
    if ( nRecOrMem  := menu_v("Impresi¢n de:","Registro Activo   ",;
                  "Campo memo relacionado ") )=0
      EXIT
    endif
  ENDIF
  if (nTargetDev := menu_v("Enviar impresi¢n a:","Impresora           ","Archivo de Texto"))=0
    EXIT
  ENDIF
  popread(.t.,"L¡neas por p gina:",@nLpp,"99","Caracteres por L¡nea",@nCpp,"999")
  IF nTargetDev = 1
    sls_prn(prnport())  
    IF !p_ready(sls_prn())
      EXIT
    ENDIF
  ELSE
    cOutFile := SPACE(12)
    popread(.F.,"Archivo al cual enviar la impresi¢n ",@cOutFile,"@N")
    IF EMPTY(cOutFile)
      EXIT
    ENDIF
    IF FILE(cOutFile)
      IF !messyn("El archivo "+cOutFile+" ya existe, y podr¡a ser sobreescrito. ¨Contin£a?")
        LOOP
      ENDIF
    ENDIF
    SET PRINTER TO (getdfp()+cOutFile)
  ENDIF
  SET PRINT ON
  IF nRecOrMem = 1
    SET CONSOLE OFF
    for i = 1 TO len(aFieldDesc)
      ?padr(aFieldDesc[i],12)
      ??padr(aMacro(aFields[i]),nCpp-12)
      IF (i%nLpp)=0
        EJECT
      ENDIF
    NEXT
    IF (i%nLpp)<>0
      EJECT
    ENDIF
  ELSE
    IF len(aMemos) > 1
      if (nMemo := mchoice(aMemos,8,27,15,54,"Memo field to print"))=0
        RETURN ''
      ENDIF
      cMemo := &( aMemos[nMemo] )
    ELSE
      cMemo := &( aMemos[1] )
    ENDIF
    nLineCount := MLCOUNT(cMemo,200)
    SET CONSOLE OFF
    IF !EMPTY(cMemo)
      if messyn("Imprime: "+alltrim(str(nLineCount))+" l¡neas.",;
                 "Contin£a","Cancela")
        FOR i = 1 TO nLineCount
          ?LEFT(MEMOLINE(cMemo,200,i),nCpp)
          IF (i%nLpp)=0
            EJECT
          ENDIF 
        NEXT
        IF (i%nLpp)<>0
          EJECT
        ENDIF 
      endif
    ELSE
      msg("Este campo memo est  vac¡o")
    ENDIF
  ENDIF
  SET PRINTER TO (sls_prn())
  SET PRINT OFF
  SET CONSOLE ON
  EXIT
ENDDO
RETURN nil


//------------------------------------------------------
static FUNCTION aCopym(aSource,aTypes)
local i
local aReturn := {}
for i =1 to len(aSource)
 if aTypes[i]=="M"
   aadd(aReturn,aSource[i])
 endif
next
return aReturn


//--------------------------------------------------------------
static function aMacro(expThis)
local expValue := &(expThis)
if valtype(expValue)=="C" .and. (chr(13)$expValue .or. chr(141)$expValue)
  return "(memo)"
else
  return trans(&(expThis),"")
endif
return nil


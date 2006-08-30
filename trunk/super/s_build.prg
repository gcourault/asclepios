#include "inkey.ch"
#define MAXNEST  3

static aFields,aFdesc,aFtypes

static nNested   := 0
static lMultiple := .f.
static cExpDesc
static aActions
static aStack := {}
static cThisExpress := ""
static cThisType   := "C"
static lTypeChange := .f.
static nLeft       := 0

static cDateSkel


//==========================================================
static proc push
aadd(aStack,{cThisExpress,cThisType,lTypeChange,nLeft})
return


//==========================================================
static proc pop
cThisExpress := atail(aStack)[1]
cThisType    := atail(aStack)[2]
lTypeChange  := atail(aStack)[3]
nLeft        := atail(aStack)[4]
asize(aStack,len(aStack)-1)
return

//==========================================================

FUNCTION buildex( cExpname,cInExpress,lInTypeChange,aInFields,aInFdesc )

EXTERNAL STUFF, Ljust, Rjust, allbut, subplus, startsw, Stod, crunch, strtran
EXTERNAL centr, PROPER, doyear, womonth, woyear, trueval, dtow
EXTERNAL endswith, dtdiff, daysin, datecalc, begend, nozdiv, stretch, arrange

local nStackCount  := 0
local aExpStack    := {}
local aTypeStack   := {}
local cIntype
local cUnderbox
local nMainChoice
local nfieldCount
local lDone := .f.
local nOldCursor
local cReturn
local getlist := {}

push()

cExpDesc    := cExpName
ltypeChange := iif(lInTypeChange#nil,lInTypeChange,.t.)

if valtype(aInFields)<>"A"
     nfieldCount:= fcount()
     aFields := array(nfieldCount)
     aFdesc  := array(nfieldCount)
     afields(aFields)
     afields(aFdesc)
else
     nfieldCount:= aleng(aInfields)
     aFields := array(nfieldCount)
     aFdesc  := array(nfieldCount)
     acopy(aInFields,aFields)
     acopy(aInFdesc,aFdesc)
endif
aFtypes := array(nfieldCount)
fillarr(aFields,aFtypes)

if !empty(cInExpress)
   cInType := &cInExpress
   cInType := VALTYPE(cInType)
else
   cInType := "C"
endif

IF cInType=="L" .OR. (!USED())
  RETURN cInExpress
ENDIF

nNested         := MIN(nNested+1,MAXNEST)
lMultiple       := (nNested< MAXNEST)
cDateSkel       := set(_SET_DATEFORMAT)
nLeft           := 4+(nNested*2)
nOldCursor      := setcursor(1)
cThisExpress    := cInExpress
nStackCount     := 0
cThisType       := UPPER(cInType)
cUnderBox       := makebox(2,nLeft,23,nLeft+50,sls_popcol())

@3,nLeft+1 SAY centr(stretch("GENERADOR DE EXPRESIONES",'ù',1),49)
@4,nLeft+1 TO 4,nLeft+49 DOUBLE
@20,nLeft+1 TO 20,nLeft+49

DO WHILE !lDone
  BEGIN SEQUENCE
    
    @20,nLeft+2 SAY "Trabajando sobre ["+cExpDesc+"]"
    @21,nLeft+2 say padr(cThisExpress,46)

    *- clear box and display expression name and type
    Scroll(5,nLeft+1,19,nLeft+49,0)
    
    
    *- fill arrays appropriately for TYPE
    aActions := sfbx_expf(cthistype)
    
    *- get selection
    SET KEY 27 TO
    nMainChoice:= sfbx_echoi(6,nLeft+2,19,nLeft+49,aActions)
    SETKEY(27,{||getlist := {},break(nil)} )
    Scroll(5,nLeft+1,18,nLeft+49,0)
    
    *- say the action to be done
    @5,nLeft+2 SAY aActions[nMainChoice]
    
    DO CASE
    CASE nMainChoice < 2
      lDone:= .T.
    CASE nMainChoice = 2
      sfbx_xtest()
    CASE nMainChoice = 3  .AND. nStackCount > 0
      nStackCount--
      asize(aExpStack,nStackCount)
      asize(aTypeStack,nStackCount)
      cThisExpress:= IIF(nStackCount> 0,aExpStack[nStackCount],cInExpress)
      cThisType:= IIF(nStackCount>0,aTypeStack[nStackCount],cInType)
      BREAK
    CASE nMainChoice = 4
      @7,nLeft+1 SAY " Una EXPRESION es una combinac¢n de      :"
      @ROW()+1,nLeft+1 SAY  ""
      @ROW()+1,nLeft+1 SAY  " - CAMPOS     valores de la base de datos"
      @ROW()+1,nLeft+1 SAY  " - OPERADORES i.e. + - * /"
      @ROW()+1,nLeft+1 SAY  " - CONSTANTES escrtas por el usuario"
      @ROW()+1,nLeft+1 SAY  " - FUNCIONES  operadores 'extendidos'"
      @ROW()+1,nLeft+1 SAY  "             i.e. TRIM() saca espacios delanteros"
      @ROW()+1,nLeft+1 SAY  ""
      @ROW()+1,nLeft+1 SAY  " Por ejemplo, el campo APELLIDO puede ser "
      @ROW()+1,nLeft+1 SAY  " EXPRESADO como LEFT(APELLIDO,5) el cual toma los"
      @ROW()+1,nLeft+1 SAY  " 5 caracteres de la izquierda o como"
      @ROW()+1,nLeft+1 SAY  " APELLIDO+NOMBRE que combina ambos campos."
      INKEY(0)
      BREAK
    CASE cThisType == "C"
      IF sfbx_char(nMainChoice)
        nStackCount++
        aadd(aExpStack,cThisExpress)
        aadd(aTypeStack,cThisType)
      ENDIF
    CASE cThisType == "D"
      IF sfbx_date(nMainChoice)
        nStackCount++
        aadd(aExpStack,cThisExpress)
        aadd(aTypeStack,cThisType)
      ENDIF
    CASE cThisType == "N"
      IF sfbx_numb(nMainChoice)
        nStackCount++
        aadd(aExpStack,cThisExpress)
        aadd(aTypeStack,cThisType)
      ENDIF
    ENDCASE
    
  END
  
ENDDO
SET KEY 27 TO
setcursor(nOldCursor)
cInType  := cThisType
nNested--
cReturn := cThisExpress
pop()
unbox(cUnderBox)
RETURN cReturn


//===========================================================
static FUNCTION sfbx_char(nChoice)
LOCAL nLenExp      := LEN(&cThisExpress)
LOCAL cLenExp      := Alltrim(STR(nLenExp))
local getlist := {}
local aSubAction   := {}
local nSubchoice   := 0
local cLeftRight
local nCharCount
local cCharCount
local nStartPos
local cStartPos
local nNewPos
local cNewPos
local cExtractSay
local cHoldParam
local nExtractMore
local nAddIns
local cTypeIn
local cTypeIn2
local n2ndfield
local c2ndExp
local cPicture
local nIter
DO CASE
CASE nChoice = 5
  asize(aSubAction,5)
  aSubAction[1] := "<x> caracteres de la izq"
  aSubAction[2] := "<x> caracteres de la der"
  aSubAction[3] := "Desde  <x> para <y>, <x> para <y>..."
  aSubAction[4] := "Todo menos los <x> caracteres de la der"
  aSubAction[5] := "Rearmar el orden de los caracteres"
  nSubChoice     := sfbx_echoi(8,nLeft+2,14,nLeft+45,aSubAction,5)
  Scroll(5,nLeft+2,18,nLeft+49,0)
  IF nSubChoice > 0
    @5,nLeft+2 SAY aSubAction[nSubChoice]
  ENDIF
  DO CASE
  CASE nSubChoice = 1 .OR. nSubChoice = 2
    cLeftRight  := IIF(nSubChoice = 1,"LEFT","RIGHT")
    nCharCount  := (nLenExp-1)
    @9,nLeft+2 SAY "¨Cu ntos caracteres de la "+cLeftright+"? ";
      GET nCharCount PICT REPL("9",LEN(cLenExp))
    @10,nLeft+2 SAY "(La expresi¢n es "+cLenExp+" caracteres de largo)"
    READ
    cCharCount  := Alltrim(STR(ABS(nCharCount)))
    cThisExpress:= cLeftRight+'('+cThisExpress+','+cCharCount+')'
  CASE nSubChoice = 3
    nExtractMore:= 0
    cExtractSay:= 'Extracting from '
    cHoldParam  := ''
    @8,nLeft+2 SAY "La expresi¢n es  "+cLenExp+' caracteres de largo.'
    for nIter = 1 TO 4
      nStartPos:= 1
      @11,nLeft+2 SAY "¨Extraer desde qu‚ posici¢n?" ;
        GET nStartPos PICT REPL("9",LEN(cLenExp))
      READ
      nCharCount:= (nLenExp-nStartPos)+1
      cStartPos:= Alltrim(STR(ABS(nStartPos)))
      @12,nLeft+2 SAY "¨Cu ntos caracteres extraer?        " ;
        GET nCharCount PICT REPL("9",LEN(cLenExp))
      READ
      IF nCharCount > 0
        cCharCount:= Alltrim(STR(ABS(nCharCount)))
        cHoldParam:= cHoldParam+","+cStartPos+","+cCharCount
        cExtractSay:= cExtractSay+IIF(nIter>1,"; desde "," ")+cStartPos+' hasta '+cCharCount
      ELSE
        RETURN .F.
      ENDIF
      Scroll(9,nLeft+2,19,nLeft+49,0)
      @9,nLeft+2 SAY SUBST(cExtractSay,1,50)
      nExtractMore:= 0
      IF nIter = 4
        EXIT
      ENDIF
      asize(aSubAction,2)
      aSubAction[1] :="Extraer porciones adicionales"
      aSubAction[2] :="Terminado "
      nExtractMore:= sfbx_echoi(10,nLeft+2,18,nLeft+30,aSubAction,2)
      IF !(nExtractMore=1)
        EXIT
      ENDIF
      Scroll(10,nLeft+2,19,nLeft+49,0)
    NEXT
    cThisExpress:= 'SUBPLUS('+cThisExpress+cHoldParam+')'
  CASE nSubChoice = 4
    nCharCount:= (nLenExp-1)
    @10,nLeft+2 SAY "(M ximo "+cLenExp+")"
    @9,nLeft+2 SAY "¨Cu ntos caracteres desde la derecha? ";
      GET nCharCount PICT REPL("9",LEN(cLenExp))
    READ
    *- check for > 0 and < full length
    IF nCharCount > 0 .AND. nCharCount < nLenExp
      cCharcount:= Alltrim(STR(nCharCount))
      cThisExpress:= 'ALLBUT('+cThisExpress+','+cCharCount+')'
    ENDIF
  CASE nSubChoice = 5
    nStartPos := 1
    nCharCount := 1
    nNewPos := 1
    @7,nLeft+2 SAY "Comenzando desde la posici¢n:" GET nStartPos PICT "99"
    @8,nLeft+2 SAY "Cu ntos caracteres extraer  :" GET nCharCount PICT "99"
    @9,nLeft+2 SAY " (0 para el RESTO) "
    @10,nLeft+2 SAY "Y moverlos desde la posici¢n:" GET nNewPos  PICT"99"
    @9,nLeft+2 SAY " (0 para el COMIENZO, 99 para FIN)"
    READ
    cStartPos:= Alltrim(STR(nStartPos))
    cCharCount:= Alltrim(STR(nCharCount))
    cNewPos  := Alltrim(STR(nNewPos))
    cThisExpress:= 'ARRANGE('+cThisExpress+','+cStartPos+','+cCharCount+','+cNewPos+')'
  ENDCASE
CASE nChoice = 6
  asize(aSubAction,3)
  aSubAction[1]:= "Justificado a la izq"
  aSubAction[2]:= "Justificado a la der"
  aSubAction[3]:= "Centrado en <x> esp."
  nSubChoice:= sfbx_echoi(8,nLeft+2,10,nLeft+25,aSubAction,3)
  Scroll(5,nLeft+2,18,nLeft+49,0)
  DO CASE
  CASE nSubChoice = 1
    cThisExpress:= 'LJUST('+cThisExpress+')'
  CASE nSubChoice = 2
    cThisExpress:= 'RJUST('+cThisExpress+')'
  CASE nSubChoice = 3
    nCharCount := nLenExp
    @7,nLeft+2 SAY aSubAction[nSubChoice]
    @9,nLeft+2 SAY "¨Ancho Total? " ;
      GET nCharCount PICT REPL("9",LEN(cLenExp))
    @10,nLeft+2 SAY "(ENTER para el actual)"
    READ
    IF nCharCount > 0
      cCharcount  := Alltrim(STR(nCharCount))
      cThisExpress:= 'CENTR('+cThisExpress+','+cCharCount+')'
    ELSE
      cThisExpress:= 'CENTR('+cThisExpress+')'
    ENDIF
  ENDCASE
CASE  nChoice = 7
  asize(aSubAction,3)
  aSubAction[1]:= "May£scula"
  aSubAction[2]:= "Min£scula"
  aSubAction[3]:= "Capitalizar"
  nSubChoice:= sfbx_echoi(8,nLeft+2,10,nLeft+25,aSubAction,3)
  Scroll(5,nLeft+2,18,nLeft+49,0)
  DO CASE
  CASE nSubChoice = 1
    cThisExpress:= 'UPPER('+cThisExpress+')'
  CASE nSubChoice = 2
    cThisExpress:= 'LOWER('+cThisExpress+')'
  CASE nSubChoice = 3
    cThisExpress:= 'PROPER('+cThisExpress+')'
  ENDCASE
CASE  nChoice = 8
  asize(aSubAction,2)
  aSubAction[1]:= "Mover todos los espacios a la derecha "
  aSubAction[2]:= "Moverlos a la derecha menos a los solos"
  nSubChoice:= sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction)
  Scroll(5,nLeft+2,18,nLeft+49,0)
  DO CASE
  CASE nSubChoice = 1
    cThisExpress:= 'CRUNCH('+cThisExpress+',0)'
  CASE nSubChoice = 2
    cThisExpress:= 'CRUNCH('+cThisExpress+',1)'
  ENDCASE
CASE  nChoice = 9
  asize(aSubAction,4)
  aSubAction[1]:= "Agregar a la izquierda"
  aSubAction[2]:= "Lado derecho"
  aSubAction[3]:= "Insertar <caracteres> cada <x> caracteres"
  aSubAction[4]:= "Algo en la posici¢n <x>"
  nSubChoice:= sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,4)
  Scroll(5,nLeft+2,18,nLeft+49,0)
  DO CASE
  CASE nSubChoice = 0
    RETURN .F.
  CASE nSubChoice < 3
    asize(aSubAction,2)
    nAddIns:= 1
    aSubAction[1]:= "Escribir caracteres"
    aSubAction[2]:= "Usar <x> copias del caracter <y>"
    IF lMultiple
    asize(aSubAction,3)
      aSubAction[3]:= "Generar una expresi¢n secundaria"
    ENDIF
    nAddIns := sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,IIF(lMultiple,3,2))
    Scroll(5,nLeft+2,18,nLeft+49,0)
    DO CASE
    CASE nAddins = 1 .OR. nAddIns = 2
      IF nAddins = 1
        ctypeIn := SPACE(20)
        @8,nLeft+2 SAY "Tipear caracteres a agregar: "
        @9,nLeft+2 GET cTypeIn
        READ
        cTypeIn:= IIF(EMPTY(TRIM(cTypeIn))," ",TRIM(cTypeIn))
      ELSE
        cTypeIn    := " "
        nCharCount := 1
        @8,nLeft+2 SAY "Caracteres a usar       " ;
          GET cTypeIn
        @9,nLeft+2 SAY "N£mero de caracteres    " ;
          GET nCharCount PICT "99"
        READ
        cTypeIn := REPL(cTypeIn,nCharCount)
      ENDIF
      DO CASE
      CASE nSubChoice = 1
        cThisExpress:= '("'+cTypeIn+'"+'+cThisExpress+')'
      CASE nSubChoice = 2
        cThisExpress:= '('+cThisExpress+'+"'+cTypeIn+'")'
      ENDCASE
    CASE nAddins = 3
      n2ndField  := sfbx_getf("C")
      IF EMPTY(n2ndField)
        RETURN .F.
      ELSE
        c2ndExp  := buildex(cExpDesc,aFields[n2ndField],.F.,aFields,aFdesc)
      ENDIF
      IF !EMPTY(c2ndExp)
        cThisExpress := '('+cThisExpress+'+'+c2ndExp+')'
      ENDIF
    ENDCASE
  CASE nSubChoice = 3
    @8,nLeft+2 SAY aSubAction[nSubChoice]
    nCharCount := 1
    cTypeIn   := ' '
    @11,nLeft+2 SAY "Insertar cada cu ntos caracteres     :" ;
      GET nCharCount PICT "9"
    @12,nLeft+2 SAY "Caracter(es) a usar (default=ESPACIO:)" ;
      GET cTypeIn
    READ
    cCharCount := Alltrim(STR(nCharCount))
    ctypeIn    := IIF(EMPTY(Alltrim(ctypeIn))," ",Alltrim(cTypeIn))
    cThisExpress:= 'STRETCH('+cThisExpress+',"'+cTypeIn+'",'+cCharCount+')'
  CASE nSubChoice = 4
    cTypeIn  := SPACE(20)
    nStartPos:= 0
    @7,nLeft+2 SAY "Texto a insertar (algo):" GET cTypeIn
    @8,nLeft+2 SAY "Posici¢n a insertarlo  :" GET nStartPos PICT "99"
    READ
    cTypeIn := IIF(EMPTY(TRIM(cTypeIn))," ",TRIM(cTypeIn) )
    cStartpos:= Alltrim(STR(nStartPos))
    cThisExpress:= 'STUFF('+cThisExpress+','+cStartPos+',0,"'+cTypeIn+'")'
  ENDCASE
CASE  nChoice = 10
  cTypeIn  := SPACE(30)
  ctypeIn2 := SPACE(30)
  @6,nLeft+2 SAY "(usar ~ para espacios)"
  @7,nLeft+2 SAY   "Texto a buscar    :   " GET cTypeIn PICT "@S20"
  READ
  IF !EMPTY(cTypeIn)
    cTypeIn  := TRIM(cTypeIn)
    cTypeIn  := STRTRAN(cTypeIn,"~"," ")
    cTypeIn2 := SPACE(LEN(cTypeIn))
    cPicture := LTRIM(TRANS(LEN(cTypeIn2),"99"))

    @8,nLeft+2 SAY "(usar ~ para espacios)"
    @9,nLeft+2 SAY "Reemplazar con      :" GET cTypeIn2 PICT "@S"+cPicture
    READ
    cTypeIn2    := STRTRAN(cTypeIn2,"~"," ")
    cThisExpress:= 'STRTRAN('+cThisExpress+',"'+cTypeIn+'","'+cTypeIn2+'")'
  ENDIF
CASE  nChoice = 11
  asize(aSubAction,3)
  aSubAction[1]:= "Primer conjunto de nros a resultado NUMERICO"
  aSubAction[2]:= "Todos los nros a resultado NUMERICO"
  aSubAction[3]:= "Convertir a fecha desde "+cDateSkel+" o YYYMMDD desde"
  nSubChoice:= sfbx_echoi(8,nLeft+2,12,nLeft+49,aSubAction,3)
  Scroll(8,nLeft+2,12,nLeft+49,0)
  cThisType:= "N"
  DO CASE
  CASE nSubChoice = 1
    cThisExpress := 'VAL('+cThisExpress+')'
  CASE nSubChoice = 2
    cThisExpress := 'TRUEVAL('+cThisExpress+')'
  CASE nSubChoice = 3
    asize(aSubAction,2)
    aSubAction[1]:= "Convertir desde forma "+cDateSkel+" a fecha"
    aSubAction[2]:= "Convertir desde forma YYYYMMDD a fecha"
    nSubChoice   := sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,2)
    Scroll(8,nLeft+2,12,nLeft+49,0)
    IF nSubChoice = 1
      cThisExpress:= 'CTOD('+cThisExpress+')'
    ELSEIF nSubChoice = 2
      cThisExpress:= 'STOD('+cThisExpress+')'
    ENDIF
    cThisType:= "D"
  ENDCASE
ENDCASE
RETURN .T.


//===========================================================
static FUNCTION sfbx_date(nChoice)
local aSubAction := {}
local nSubChoice
local cPeriodType
local nPlusOrMinus
local cPlusOrMinus
local nBegEnd
local cBegEnd
local nWkMoQtr
local nIter
local nDayOfWeek
local nDayWkMoYr
local cDayWkMoYr
local dDate
local nDateField
local c2ndExp
local getlist := {}
DO CASE
CASE nChoice = 5
  asize(aSubAction,4)
  aSubAction[1]:= "D¡as     m s o menos"
  aSubAction[2]:= "Semanas  m s o menos"
  aSubAction[3]:= "Meses    m s o menos"
  aSubAction[4]:= "A¤os     m s o menos"
  nSubChoice:= sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,4)
  Scroll(8,nLeft+2,12,nLeft+49,0)
  cPeriodType  := Alltrim(STR(nSubChoice))
  @10,nLeft+2 SAY "(entre un '-' para menos)"
  nPlusOrMinus := 0
  @9,nLeft+2 SAY "M s o menos #"+LEFT(aSubAction[nSubChoice],6)+':' ;
    GET nPlusOrMinus PICT "99999"
  READ
  cPlusOrMinus := Alltrim(STR(nPlusOrMinus))
  DO CASE
  CASE nPlusOrMinus = 0
    RETURN .F.
  OTHERWISE
    cThisExpress:= 'DATECALC('+cThisExpress+','+cPlusOrMinus+','+cPeriodType+')'
  ENDCASE
CASE nChoice = 6
  nBegEnd := 1
  asize(aSubAction,2)
  aSubAction[1]:= "Comienzo de "
  aSubAction[2]:= "Fin de "
  nBegEnd  :=  sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,2)
  cBegEnd  := aSubAction[nBegEnd]
  nWkMoQtr := 1
  asize(aSubAction,3)
  aSubAction[1] := "Semana  - "+cBegEnd
  aSubAction[2] := "Mes     - "+cBegEnd
  aSubAction[3] := "Cuatrim - "+cBegEnd
  nWkMoQtr  :=  sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,3)
  Scroll(7,nLeft+2,10,nLeft+49,0)
  IF nWkMoQtr = 1
    asize(aSubAction,7)
    FOR nIter = 1 TO 7
      aSubAction[nIter]:= CDOW( DATE()+(7-DOW(DATE()))  +nIter)
    NEXT
    @ 7,nLeft+2 SAY cBegEnd+" semanas de las:"
    nDayOfWeek:= sfbx_echoi(9,nLeft+2,18,nLeft+49,aSubAction,7)
    nDayOfWeek:= MAX(1,nDayOfWeek)
  ENDIF
  Scroll(7,nLeft+2,16,nLeft+49,0)
  cThisExpress:= 'BEGEND('+cThisExpress+','+Alltrim(STR(nBegEnd))+','+;
                 Alltrim(STR(nWkMoQtr))+;
                 IIF(nWkMoQtr=1,','+Alltrim(STR(nDayOfWeek))+')',')')
  
CASE nChoice = 7
  asize(aSubAction,3)
  aSubAction[1]:= "Semana (1-7)  "
  aSubAction[2]:= "Mes    (1-31) "
  aSubAction[3]:= "A¤o   (1-356) "
  nSubChoice:= sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,3)
  Scroll(8,nLeft+2,10,nLeft+49,0)
  DO CASE
  CASE nSubChoice = 1
    cThisExpress:= 'DOW('+cThisExpress+')'
  CASE nSubChoice = 2
    cThisExpress:= 'DAY('+cThisExpress+')'
  CASE nSubChoice = 3
    cThisExpress:= 'DOYEAR('+cThisExpress+')'
  ENDCASE
  cThisType:= "N"
CASE nChoice = 8
  asize(aSubAction,2)
  aSubAction[1]:= "Mes  (1-5)"
  aSubAction[2]:= "A¤o  (1-52)"
  nSubChoice:= sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,2)
  Scroll(8,nLeft+2,10,nLeft+49,0)
  DO CASE
  CASE nSubChoice = 1
    cThisExpress:= 'WOMONTH('+cThisExpress+')'
  CASE nSubChoice = 2
    cThisExpress:= 'WOYEAR('+cThisExpress+')'
  ENDCASE
  cThisType:= "N"
CASE nChoice = 9
  cThisExpress:= 'MONTH('+cThisExpress+')'
  cThisType:= "N"
CASE nChoice = 10
  cThisExpress:= 'YEAR('+cThisExpress+')'
  cThisType:= "N"
CASE nChoice = 11
  asize(aSubAction,3)
  aSubAction[1]:= "Fecha  ie.    [Ene 1, 1989]"
  aSubAction[2]:= "Mes    ie.  [Enero]"
  aSubAction[3]:= "D¡a    ie. [Martes]"
  nSubChoice:= sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,3)
  Scroll(8,nLeft+2,10,nLeft+49,0)
  DO CASE
  CASE nSubChoice = 1
    cThisExpress:= 'DTOW('+cThisExpress+')'
  CASE nSubChoice = 2
    cThisExpress:= 'CMONTH('+cThisExpress+')'
  CASE nSubChoice = 3
    cThisExpress:= 'CDOW('+cThisExpress+')'
  ENDCASE
  cThisType:= "C"
CASE nChoice = 12
  asize(aSubAction,2)
  aSubAction[1]:= cDateSkel
  aSubAction[2]:= "yyyymmdd"
  nSubChoice:= sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,2)
  Scroll(8,nLeft+2,10,nLeft+49,0)
  DO CASE
  CASE nSubChoice = 1
    cThisExpress:= 'DTOC('+cThisExpress+')'
  CASE nSubChoice = 2
    cThisExpress:= 'DTOS('+cThisExpress+')'
  ENDCASE
  cThisType:= "C"
CASE nChoice = 13
  nDayWkMoYr := 1
  asize(aSubAction,4)
  aSubAction[1]:= "DIAS   - n£mero de d¡as entre ellos"
  aSubAction[2]:= "SEMANAS- n£mero de semanas entre ellos"
  aSubAction[3]:= "MESES  - n£mero de meses entre ellos"
  aSubAction[4]:= "A¥OS   - n£mero de a¤os entre ellos"
  nDayWkMoYr:=  sfbx_echoi(8,nLeft+2,18,nLeft+49,aSubAction,4)
  Scroll(8,nLeft+2,10,nLeft+49,0)
  cDayWkMoYr := Alltrim(STR(nDayWkMoYr))
  @7,nLeft+2 SAY "Comparar expresi¢n con:"
  nSubChoice:= 1
  asize(aSubAction,2)
  aSubAction[1]:= "Fecha de hoy"
  aSubAction[2]:= "Escribir fecha"
  IF lMultiple
    asize(aSubAction,3)
    aSubAction[3]:= "Usar expresi¢n de fecha secundaria"
  ENDIF
  nSubChoice:= sfbx_echoi(9,nLeft+2,18,nLeft+49,aSubAction)
  Scroll(9,nLeft+2,10,nLeft+49,0)
  DO CASE
  CASE nSubChoice = 1
    cThisExpress:= 'DTDIFF('+cThisExpress+',date(),'+cDayWkMoYr+')'
  CASE nSubChoice = 2
    dDate:= CTOD("  /  /  ")
    @7,nLeft+2 SAY "Date to compare =>" GET dDate
    READ
    cThisExpress:= 'DTDIFF('+cThisExpress+',CTOD("'+DTOC(dDate)+'"),'+cDayWkMoYr+')'
  CASE nSubChoice = 3
    nDateField:= sfbx_getf("D")
    IF nDateField > 0
      c2ndExp =  buildex(cExpDesc,aFields[nDateField],.F.,aFields,aFdesc)
      IF !EMPTY(c2ndExp)
        cThisExpress:= 'DTDIFF('+cThisExpress+','+c2ndExp+','+cDayWkMoYr+')'
      ENDIF
    ENDIF
  ENDCASE
  cThisType:= "N"
ENDCASE
RETURN .T.

//===========================================================
static function sfbx_numb(nChoice)
local aSubAction := {}
local nSubChoice
local nAction
local cTypeIn
local nTypeIn
local nField
local cPicture
local getlist := {}
DO CASE
CASE nChoice = 5
  asize(aSubAction,5)
  aSubAction[1]:= "M s un valor "
  aSubAction[2]:= "Menos un valor"
  aSubAction[3]:= "Por por un valor"
  aSubAction[4]:= "Divido por un valor"
  aSubAction[5]:= "Dividido en un valor"
  nSubChoice:= sfbx_echoi(9,nLeft+2,18,nLeft+49,aSubAction,5)
  Scroll(8,nLeft+2,11,nLeft+49,0)
  IF nSubChoice > 0
    @9,nLeft+2 SAY aSubAction[nSubChoice]
    nAction = 1
    IF lMultiple
      asize(aSubAction,2)
      aSubAction[1]:= "Escribir un valor"
      aSubAction[2]:= "Generar una expresi¢n secundaria"
      nAction := sfbx_echoi(11,nLeft+2,18,nLeft+49,aSubAction)
      Scroll(11,nLeft+2,11,nLeft+49,0)
    ENDIF
    IF nAction = 1
      cTypeIn:= SPACE(15)
      @11,nLeft+2 SAY "VALUE: " ;
        GET cTypeIn PICT "###############"
      READ
      cTypeIn:= Alltrim(cTypeIn)
    ELSEIF nAction = 2
      Scroll(7,nLeft+2,12,nLeft+49,0)
      nField := sfbx_getf("N")
      IF nField > 0
        cTypeIn= buildex(cExpDesc,aFields[nField],.F.,aFields,aFdesc)
      ENDIF
    ENDIF
    IF !EMPTY(cTypeIn)
      DO CASE
      CASE nSubChoice = 1
        cThisExpress:= '('+cThisExpress+'+'+cTypeIn+')'
      CASE nSubChoice = 2
        cThisExpress:= '('+cThisExpress+'-'+cTypeIn+')'
      CASE nSubChoice = 3
        cThisExpress:= '('+cThisExpress+'*'+cTypeIn+')'
      CASE nSubChoice = 4 .AND. !(VAL(cTypeIn)=0)
        cThisExpress:= '('+cThisExpress+'/'+cTypeIn+')'
      CASE nSubChoice = 5
        cThisExpress:= '(('+cTypeIn+')/NOZDIV('+cThisExpress+'))'
      ENDCASE
    ENDIF
  ENDIF
CASE nChoice = 6
  nTypeIn:= 0
  @8,nLeft+2 SAY "Redondeado a cu ntos decimales (0-9) :" ;
    GET nTypeIn PICT "99"
  READ
  IF nTypeIn >= 0
    cTypeIn:= Alltrim(TRANS(nTypeIn,"99"))
    cThisExpress:= 'ROUND('+cThisExpress+','+cTypeIn+')'
  ENDIF
  
CASE nChoice = 7
  cThisExpress:= 'INT('+cThisExpress+')'
CASE nChoice = 8
  cThisExpress:= 'ABS('+cThisExpress+')'
CASE nChoice = 9
  cPicture:= SPACE(20)
  @7,nLeft+2 SAY "Picture: " ;
    GET cPicture
  @ROW()+2,nLeft+3 SAY "  9   Un n£mero"
  @ROW()+1,nLeft+3 SAY "  .   Posici¢n del punto decimal."
  @ROW()+1,nLeft+3 SAY "  ,   Inserta una coma"
  @ROW()+1,nLeft+3 SAY "  *   Inserta asteriscos en los blancos."
  @ROW()+1,nLeft+3 SAY "  $   Inserta signo $ en los blancos."
  @ROW()+1,nLeft+3 SAY "  @(  Negativos entre par‚ntesis."
  @ROW()+1,nLeft+3 SAY "  @B  N£meros justificados a la izq."
  @ROW()+1,nLeft+3 SAY "  @C  Muestra CR despu‚s de los positivos."
  @ROW()+1,nLeft+3 SAY "  @X  Muestra DB despu‚s de los negativos."
  @ROW()+1,nLeft+3 SAY "  @Z  Mustra espacios en lugar de ceros."
  READ
  cThisExpress := 'TRANS('+cThisExpress+',"'+Alltrim(cPicture)+'")'
  cThisType  := "C"
ENDCASE
RETURN .t.

//===========================================================
static PROC sfbx_xtest
local nCurrRec
local expActual
local cResult
local getlist := {}

Scroll(6,nLeft+1,19,nLeft+49,0)
@7,nLeft+2 SAY 'Ejemplo de salida cuando la expre- '
@8,nLeft+2 SAY 'si¢n es comparada con los registros'
@9,nLeft+2 SAY 'Pulse <- -> para ver otros registros'
@10,nLeft+2 SAY 'Pulse ENTER para terminar la prueba'
@11,nLeft+1 TO 11,nLeft+49
nCurrRec:= RECNO()
DO WHILE nCurrRec > 0
  expActual := &cThisExpress
  cResult   := trans(expActual,"")
  @17,nLeft+2 SAY "Registro # "+TRANS(RECNO(),"9999999999")
  @13,nLeft+2 SAY SUBST(cResult,1,40)
  @14,nLeft+2 SAY SUBST(cResult,41,40)
  @15,nLeft+2 SAY SUBST(cResult,82,40)
  INKEY(0)
  Scroll(13,nLeft+2,15,nLeft+49,0)
  IF LASTKEY() = K_ENTER
    GO nCurrRec
    EXIT
  ELSEIF LASTKEY() = K_RIGHT
    SKIP 1
  ELSEIF LASTKEY() = K_LEFT
    SKIP -1
  ENDIF
ENDDO
RETURN

//===========================================================
static FUNCTION sfbx_expf(cType)
local aAction := array(15)
local nSize

aAction[1]      :=  "SALIR        y retornar la expresi¢n"
aAction[2]      :=  "PROBAR       en la base de datos "
aAction[3]      :=  "DESHACER     £ltimo cambio"
aAction[4]      :=  "AYUDA        ayuda del generador"
DO CASE
CASE cType  == "C"
  aAction[5]    :=  "EXTRAER      subconjunto o rearmado"
  aAction[6]    :=  "JUSTIFICAR   izq derecha centrado"
  aAction[7]    :=  "LETRA        min£scula may£scula Capit."
  aAction[8]    :=  "MOVER        espacios al final"
  aAction[9]    :=  "AGREGAR      o insertar caracteres"
  aAction[10]   := "SUSTITUIR    un vslor por otro"
  nSize         := 10
  IF lTypeChange
    aAction[11] := "DIFERENTE    cambia a fecha o num‚rico"
    nSize       := 11
  ENDIF
CASE cType  == "D"
  aAction[5]    := "MAS        + o - d¡as, semanas, meses, a¤os"
  aAction[6]    := "FIN          o comienzo de semana,mes,cuatr"
  nSize:= 6
  IF lTypeChange
    aAction[7]  :=  "DIA          de semana-mes-a¤o como nro"
    aAction[8]  :=  "SEMANA       de mes,a¤o como n£mero"
    aAction[9]  :=  "MES          de a¤o como nro"
    aAction[10] :=  "A¥O          como n£mero"
    aAction[11] :=  "PALABRAS     d¡a, mes, fecha completa"
    aAction[12] := "CARACTER     como "+cDateSkel+" o aaaammdd"
    aAction[13] := "ENTRE      d¡as/sem/meses/a¤os entre fechas"
    nSize       := 13
  ENDIF
  
CASE cType  == "N"
  aAction[5]    :=  "CALCULOS     (mas menos por dividido)"
  aAction[6]    :=  "REDONDEO     a <x> decimales"
  aAction[7]    :=  "ENTERO       corte de decimales, sin redondeo"
  aAction[8]    :=  "ABSOLUTO     valor absoluto ignorando signo"
  nSize         := 8
  IF lTypeChange
    aAction[9]  :=  "DIFERENTE    convertir a un tipo de caracter"
    nSize       := 9
  ENDIF
ENDCASE
asize(aAction,nSize)
RETURN aAction

//===========================================================
static FUNCTION sfbx_getf(cForcetype)
LOCAL nFieldSel,cUnderBox

cUnderBox := makebox(5,nLeft+2,19,nLeft+49)
@7,nLeft+3 TO 7,nLeft+48
@6,nLeft+3 SAY "S E L E C C I O N E   C A M P O   C O M I E N Z O"
DO WHILE .T.
  nFieldSel := sfbx_echoi(8,nLeft+4,18,nLeft+48,aFdesc)
  IF !aFtypes[nFieldSel]$cForcetype
    msg("Debe ser del tipo "+cForcetype)
  ELSE
    EXIT
  ENDIF
ENDDO
unbox(cUnderBox)
RETURN nFieldSel



//===========================================================
FUNCTION sfbx_echoi(nTop,nLeft,nBottom,nRight,aList)
local nAlen     := len(aList)
local nSelect   := 0
local nElement  := 1
local cFirst    := ""
local nWidth    := nRight-nLeft+1
local nIter, nKey
local oBrowse := tbrowsenew(nTop,nLeft,nBottom,nRight)
memvar getlist
oBrowse:addcolumn(tbcolumnnew("",{||padr(aList[nElement],nWidth)} ))
oBrowse:skipblock     := {|n|askip(n,@nElement,nAlen)}
oBrowse:gobottomblock := {||nElement := len(aList)}
oBrowse:gotopblock    := {||nElement := 1}
SETKEY(27)
FOR nIter = 1 TO nAlen
  cFirst:= cFirst+UPPER(Left(aList[nIter],1))
NEXT
while .t.
  while !oBrowse:stabilize()
  end
  nKey := inkey(0)
  do case
  case nKey == K_UP
    oBrowse:up()
  case nKey == K_DOWN
    oBrowse:down()
  case nKey == K_ESC
    BREAK
  case nKey == K_ENTER
    nSelect := nelement
    exit
  case upper(chr(nKey)) $ cFirst
    nElement := at(upper(chr(nKey)),cFirst)
    oBrowse:refreshall()
  endcase
end
SETKEY(27,{||getlist := {},break(nil)} )
RETURN nSelect


//============================================================
static function askip(n,curr_row,aMax)
  local skipcount := 0
  do case
  case n > 0
    do while curr_row+skipcount < aMax  .and. skipcount < n
      skipcount++
    enddo
  case n < 0
    do while curr_row+skipcount > 1 .and. skipcount > n
      skipcount--
    enddo
  endcase
  curr_row += skipcount
return skipcount


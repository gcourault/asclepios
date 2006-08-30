static aFieldNames,aFieldDesc,aFieldTypes
static aCharFields,aNumFields,aDateFields,aLogFields
static nFieldCount
static cThisExpression  := ""
static cThisFldType  := ""
static cThisOperator := ""
static cThisAndOr    := ""
static cThisCompare  := ""
static nLongestDesc  := 0
static lUseBuildex


FUNCTION QUERY(cInFieldNames,cInFieldDesc,cInFieldTypes,cQuitPhrase,lUseBx)

local cOldQuery   := sls_query()
local nMainSelect := 1
local cOldcolor   := setcolor(sls_normcol())
local cUnder      := savescreen(0,0,maxrow(),maxcol())
local nOldcursor  := setcursor()
local lOldexact   := setexact()
local nOldarea    := SELECT()
local nAtRecord   := RECNO()
local cQueryFile  := slsf_query()+".DBF"
local cQDescription := ""

lUseBuildex := iif(lUseBx#nil,lUseBx,.f.)

EXTERNAL _wildcard
CTOD("")

IF !( VALTYPE(cInFieldNames)+VALTYPE(cInFieldDesc)+VALTYPE(cInFieldTypes))=="AAA"
  nFieldCount := Fcount()+1
  aFieldNames := array(nFieldCount)
  aFieldDesc  := array(nFieldCount)
  aFieldTypes := array(nFieldCount)
  Afields(aFieldNames,aFieldTypes)
  Afields(aFieldDesc)
ELSE
  nFieldCount := aleng(cInFieldNames)+1
  aFieldNames := array(nFieldCount)
  aFieldDesc  := array(nFieldCount)
  aFieldTypes := array(nFieldCount)
  Acopy(cInFieldNames,aFieldNames)
  Acopy(cInFieldDesc,aFieldDesc)
  Acopy(cInFieldTypes,aFieldTypes)
ENDIF
AINS(aFieldNames,1)
AINS(aFieldDesc,1)
AINS(aFieldTypes,1)
aFieldNames[1] :="DELETED()"
aFieldDesc[1]  :="< 쭮orrado? >"
aFieldTypes[1] :="L"
nLongestDesc   := bigelem(aFieldDesc)

IF !(VALTYPE(cQuitPhrase)=="C")
  cQuitPhrase := ""
ENDIF
SET EXACT ON

*- build field-type arrays
buildtypes()


*- draw the screen
Setcolor(sls_popcol())
@3,15,18,50 BOX sls_frame()
@3,16 SAY '[Generador de Consultas]'
*- main loop
DO WHILE .T.
  *- go to the beg of file each loop
  GO TOP
  
  *- save the query each loop
  cOldQuery := sls_query()
  IF !EMPTY(sls_query())
    @17,18 say 'Consulta Activa  ' color "*"+setcolor()
  ELSE
    @17,18 say 'Consulta Inactiva'
  ENDIF
  *- do the menu
  Setcolor(sls_popmenu())
  @5,18 PROMPT  "Generar Consulta Nueva"
  @6,18 PROMPT  "Aumentar Consulta Activa"
  @7,18 PROMPT  "Contar registros consultados"
  @8,18 PROMPT  "Limpiar Consulta Activa"
  @9,18 PROMPT  "Grabar consulta al disco"
  @10,18 PROMPT "Traer Consulta desde el disco"
  @11,18 PROMPT "Borrar consultas guardadas"
  @12,18 PROMPT "Cu쟫 es la Consulta Activa"
  @13,18 PROMPT "Editar Consulta Activa"
  @14,18 PROMPT "Ver los registros consultados"
  @15,18 PROMPT "Salir a "+cQuitPhrase
  MENU TO nMainSelect
  Setcolor(sls_popcol())
  
  *- do the selected action
  DO CASE
  CASE nMainSelect == 1 .OR. (nMainSelect == 2 .AND. !EMPTY(sls_query()) )
      *- build or add to query
      IF nMainSelect == 1
        *- clear query expr, and/or var
        cThisAndOr:= ""
        sls_query("")
        BUILDQUERY()
      ELSEIF GETANDOR()
        BUILDQUERY()
      ENDIF
      *- if after all that the query_exp is empty, restore the old query
      IF EMPTY(Alltrim(sls_query()))
        sls_query(cOldQuery)
      ELSE
        sls_bquery( &("{||"+sls_query()+"}")  )
      ENDIF
  CASE nMainSelect = 3  .AND. !EMPTY(sls_query())
      COUNTQUERY()
  CASE nMainSelect = 4
      *- init the query string to ''
      sls_query("")
      sls_bqzap()
  CASE nMainSelect = 5 .AND. !EMPTY(sls_query())
      cQDescription := PUTQUERY(cQDescription)
  CASE nMainSelect = 6
      cQDescription := GETQUERY()
      if !empty(sls_query())
        sls_bqzap()
        sls_bquery( &("{||"+sls_query()+"}")  )
      endif
  CASE nMainSelect = 7
      PURGEQ()
  CASE nMainSelect = 8
      msg("Consulta Activa ",SUBST(sls_query(),1,60), ;
                           SUBST(sls_query(),61,60),;
                           SUBST(sls_query(),121,60),;
                           SUBST(sls_query(),181,60))
  CASE nMainSelect = 9
      EDITQUERY()
      if !empty(sls_query())
        sls_bqzap()
        sls_bquery( &("{||"+sls_query()+"}")  )
      endif
  CASE nMainSelect = 10 .AND. !EMPTY(sls_query())
      VIEWQUERY()
  CASE nMainSelect = 11  .OR. nMainSelect = 0
      *- restore the various environment elements as found
      SELECT (nOldarea)
      IF nAtRecord > 0
        GO nAtRecord
      ENDIF
      Restscreen(0,0,maxrow(),maxcol(),cUnder)
      Setcolor(cOldColor)
      setexact(lOldexact)
      setcursor(nOldcursor)
      if !empty(sls_query())
        sls_bqzap()
        sls_bquery( &("{||"+sls_query()+"}")  )
      endif
      *- pass back the query string
      RETURN sls_query()
  ENDCASE
ENDDO

aFieldNames := nil
aFieldDesc  := nil
aFieldTypes := nil
aCharFields := nil
aNumFields  :=  nil
aDateFields := nil
aLogFields  := nil
nFieldCount := nil
cThisExpression  := nil
cThisFldType  := nil
cThisOperator := nil
cThisAndOr    := nil
cThisCompare  := nil
nLongestDesc  := nil
lUseBuildex   := nil

return nil

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STATIC FUNCTION GETAFIELD
local cUnder,nRight
local nSelection,expActual

nRight := MAX(45+MAX(23,MIN(31,nLongestDesc))+1,70)
cUnder := makebox(7,45,22,nRight,sls_popmenu())
@7,46 SAY '[Lista de Campos]'
@20,46 TO 20,nRight-1
@21,47 SAY "ENTER para seleccionar "
nSelection := SACHOICE(8,47,19,nRight-1,aFieldDesc)
unbox(cUnder)

*- determine the return value
cThisExpression := IIF(nSelection > 0,aFieldNames[nSelection],'')
cThisFldType := IIF(nSelection > 0,aFieldTypes[nSelection],'')
IF lUseBuildex .AND. nSelection > 0 .AND. (!cThisFldType$"ML")
  IF !messyn("쭱xtiende el campo "+cThisExpression+" con el GENERADOR DE EXPRESIONES?","No","Si")
    cThisExpression := BUILDEX("Expresi줻 Compleja para CONSULTA",;
                       cThisExpression,.t.,;
                       ACOPY(aFieldNames,ARRAY(nFieldCount),2),;
                       ACOPY(aFieldDesc,ARRAY(nFieldCount),2))
    expActual       := &cThisExpression
    cThisFldType    := VALTYPE(expActual)
  ENDIF
ENDIF
*- return a value
RETURN !(EMPTY(cThisExpression))


//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STATIC FUNCTION GetOperator
local aOperators := BUILDOP()
local nLongest   := bigelem(aOperators[1])
local nRight,nBottom
local cUnder,nSelection

nRight  := MAX(45+nLongest+2,63)
nBottom := 6+len(aOperators[1])+2
cUnder  := makebox(6,45,nBottom,nRight,sls_popmenu())
@8,46 SAY '[Operaci줻 de Elecci줻]'
nSelection := SACHOICE(7,46,nBottom-1,nRight-1,aOperators[1])
unbox(cUnder)
cThisOperator = IIF(nSelection > 0, Alltrim(aOperators[2,nSelection]),'')
RETURN !EMPTY(cThisOperator)


//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
static FUNCTION BUILDOP
IF cThisFldType=="M"
  RETURN { {"$   (CONTIENE)","E   (ESTA VACIO)","N   (NO ESTA VACIO)"},;
           {"$","N","E"} }
ELSEIF cThisFldType == "L"
  RETURN { {"T   Verdad/Si","F   Falso/No"},{"=","#"} }
ELSEIF cThisFldType == "N"
  RETURN { {;
            "=   (EXACTAMENTE IGUAL A)",;
            "<>  (DISTINTO A)",;
            "<   (MENOR QUE)",;
            ">   (MAYOR QUE)",;
            "<=  (MENOR O IGUAL QUE)",;
            ">=  (MAYOR O IGUAL QUE)";
           },{"=","<>","<",">","<=",">="} }
ELSEIF cThisFldType == "D"
  RETURN { {;
            "=   (EXACTAMENTE IGUAL A)",;
            "<>  (DISTINTO A)",;
            "<   (MENOR QUE)",;
            ">   (MAYOR QUE)",;
            "<=  (MENOR O IGUAL QUE)",;
            ">=  (MAYOR O IGUAL QUE)";
           },{"=","<>","<",">","<=",">="} }
ELSEIF cThisFldType == "C"
  RETURN { {;
            "=   (EXACTAMENTE IGUAL A)",;
            "<>  (DISTINTO A)",;
            "<   (MENOR QUE)",;
            ">   (MAYOR QUE)",;
            "<=  (MENOR O IGUAL QUE)",;
            ">=  (MAYOR O IGUAL QUE)",;
            "$   (CONTIENE)",;
            "!$  (NO CONTIENE)",;
            "?*  (COMODINES)",;
            "S   (ES PARECIDO A)",;
            "B   (EMPIEZA CON)",;
            "E   (TERMINA CON)";
           },{"=","<>","<",">","<=",">=","$","!$","?","QL","B","E"}}
ENDIF
RETURN ''



//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
static FUNCTION buildtypes
local nCounter
aCharFields := {}
aNumFields  := {}
aDateFields := {}
aLogFields  := {}
FOR nCounter = 1 TO nFieldCount
  DO CASE
  CASE aFieldTypes[nCounter] == "C"
    AADD(aCharFields,aFieldNames[nCounter])
  CASE aFieldTypes[nCounter] == "N"
    AADD(aNumfields,aFieldNames[nCounter])
  CASE aFieldTypes[nCounter] == "D"
    AADD(aDatefields,aFieldNames[nCounter])
  CASE aFieldTypes[nCounter] == "L"
    AADD(aLogfields,aFieldNames[nCounter])
  ENDCASE
NEXT
return nil



//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STATIC FUNCTION OTHERFIELD
local aThis,nSelection
DO CASE
CASE cThisFldType == "C"
  nSelection   := mchoice(aCharFields,5,30,15,60,'[Pick Field]')
  cThisCompare := IIF(nSelection = 0, '',aCharFields[nSelection])
CASE cThisFldType == "N"
  nSelection   := mchoice(aNumfields,5,30,15,60,'[Pick Field]')
  cThisCompare := IIF(nSelection = 0, '',aNumfields[nSelection])
CASE cThisFldType == "D"
  nSelection   := mchoice(aDatefields,5,30,15,60,'[Pick Field]')
  cThisCompare := IIF(nSelection = 0, '',aDatefields[nSelection])
CASE cThisFldType == "L"
  nSelection   := mchoice(aLogfields,5,30,15,60,'[Pick Field]')
  cThisCompare := IIF(nSelection = 0, '',aLogfields[nSelection])
ENDCASE
RETURN !EMPTY(cThisCompare)

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

STATIC FUNCTION GETANDOR
local cUnder
local nSelection := 1

*- draw the box, do the menu, close the box
cUnder = makebox(8,45,14,58,sls_popmenu())
@09,47 PROMPT 'LISTO'
@10,47 PROMPT 'Y'
@11,47 PROMPT 'O '
@12,47 PROMPT 'Y NO'
@13,47 PROMPT 'O NO'
MENU TO nSelection
nSelection := max(nSelection,1)
unbox(cUnder)

cThisAndOr := {"",".AND.",".OR.",".AND.!",".OR.!"}[nSelection]

RETURN  !(EMPTY(cThisAndOr))


//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STATIC FUNCTION FROMLIST
local cToSmalls

DO CASE
CASE cThisFldType == 'C'
  cToSmalls := cThisExpression
CASE cThisFldType == 'D'
  cToSmalls := 'dtoc('+cThisExpression+')'
CASE cThisFldType == 'N'
  cToSmalls := 'str('+cThisExpression+')'
CASE cThisFldType == 'L'
  cToSmalls := 'iif('+cThisExpression+',"Verdad","Falso")'
OTHERWISE
  RETURN .F.
ENDCASE
smalls(cToSmalls)
IF LASTKEY() = 13
  cThisCompare = &cThisExpression
  RETURN .T.
ELSE
  cThisCompare = ""
  RETURN .F.
ENDIF
RETURN .F.


//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FUNCTION sfq_like(cInString1,cInString2)
IF (SOUNDEX(cInString1) == SOUNDEX(cInString2))
  RETURN .T.
ELSE
  RETURN .F.
ENDIF
return .f.

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STATIC FUNCTION VIEWQUERY
local nIndexOrd := INDEXORD()
local cUnder
local aPriorStack := {}
local nMaxInBox   := 0
local nFirstField := 1
local nCurrRow
local nCounter
local cFieldName,cFieldDesc
local nMemos
local aMemos
local cThisMemo
local nIter
local nSelection
local cUnder2
local cOldColor

set order to 0
go top
plswait(.T.,"Buscando...")
CLEAR TYPEAHEAD
LOCATE WHILE (inkey()#27) FOR eval(sls_bquery())
plswait(.F.)

*- if no matches, back to the main routine
IF !FOUND()
  IF EOF()
    msg("No hay coincidencias")
  ELSE
    msg("El usuario cancel� el proceso")
  ENDIF
  RETURN ''
ENDIF

cUnder := makebox(3,5,20,75,sls_popcol())
nMemos = akount(aFieldTypes,"M")
IF nMemos > 0
  aMemos := array(nMemos)
  nCounter := 0
  FOR nIter = 1 TO nFieldCount
    IF aFieldTypes[nIter] = "M"
      nCounter++
      aMemos[nCounter] := aFieldNames[nIter]
    ENDIF
  NEXT
  @20,7 SAY '[ ( S )Sig   ( A )Ant    ( F )Salir  (V)er Memo    ()Mas]'
else
  @20,7 SAY '[ ( S )Sig   ( A )Ant    ( F )Salir  ()Mas]'
ENDIF

DO WHILE .T.
  
  *- display the record #, clear the box
  @ 3,12 SAY  "REGISTRO "+STR(RECNO())+" ]"
  Scroll(4,11,19,69,0)
  
  *- determine last field to be displayed from field subscript
  *- and box size
  nMaxInBox := MIN(nFirstField+14,nFieldCount)
  
  *- current row starts at 1
  nCurrRow := 4
  
  *- draw each of the field/field descriptions that fit in the box
  FOR nCounter = nFirstField TO nMaxInBox
    *- get field description, make it a uniform length
    cFieldDesc := aFieldDesc[nCounter]+REPL(' ',20-LEN(aFieldDesc[nCounter]))
    cFieldName := aFieldNames[nCounter]
    IF aFieldTypes[nCounter]="M"
      @nCurrRow,12 SAY cFieldDesc+ ' (CAMPO MEMO)'
    ELSE
      *- get a piece of the value to show
      @nCurrRow,12 SAY cFieldDesc+' '+left(trans(&cFieldName,""),35)
    ENDIF
    *- increment the current row
    nCurrRow++
  NEXT
  
  *- wait for Vern to press a key
  INKEY(0)
  
  *- do the appropriate
  DO CASE
    
  CASE lastkey() = 83 .OR. lastkey() = 115
    aadd(aPriorStack,recno())

    *- blinking message while searching for next record
    cOldColor = Setcolor('*'+Setcolor())
    @3,50 SAY '[ Buscando... ]'
    SKIP
    LOCATE WHILE (inkey()#27) FOR eval(sls_bquery())
    
    *- put the box back as it was
    Setcolor(cOldColor)
    @3,50 SAY '컴컴컴컴컴컴컴컴'
    
    *- if no go, we're outa here
    IF !FOUND()
      IF EOF()
        msg("No hay m쟳 coincidencias")
      ELSE
        msg("El usuario cancel� el proceso")
      ENDIF
      EXIT
    ENDIF
  CASE lastkey() = 65 .OR. lastkey() = 97  && prior
     if len(aPriorStack) > 0
       go ATAIL(aPriorStack)
       asize(aPriorStack,len(aPriorStack)-1)
     endif
    
  CASE lastkey() = 70 .OR. lastkey() = 102  && quit
    EXIT

  *#06-19-1990 Added this for View Memo capability
  CASE lastkey() = 118 .or. lastkey() = 86 .and. nMemos > 0 && V view memos
      nSelection := 1
      IF nMemos > 1
        nSelection := mchoice(aMemos,2,15,3+nMemos,26,"Seleccione Memo:")
      ENDIF
      IF nSelection > 0
        cUnder2   := makebox(0,15,24,79,Setcolor(),0)
        cThisMemo := aMemos[nSelection]
        @0,18 SAY '[VIENDO CAMPO MEMO: '+cThisMemo+' Pulse ESCAPE para salir]'
        Memoedit(&cThisMemo,1,16,23,78,.F.,'',79)
        unbox(cUnder2)
      ENDIF
  CASE lastkey() = 5
    *- decrease starting field #
    nFirstField = IIF(nFirstField=1,1,MAX(nFirstField-20,1) )
    
    
  CASE lastkey() = 24
    *- increase starging field #
    nFirstField = IIF(nMaxInBox+1 > nFieldCount,1,MIN(nMaxInBox+1,nFieldCount) )
    
  ENDCASE
  
ENDDO
*- back to the beg of file
GO TOP
*- and back to the main proc
unbox(cUnder)
SET ORDER TO (nIndexOrd)
RETURN ''


//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FUNCTION sfq_cntain(cInstring,cDelimstr)
local nIter,cPartOf
nIter := 1
cPartOf = takeout(cDelimStr,';',nIter)
DO WHILE !EMPTY(cPartOf)
  IF cPartOf$cInstring
    RETURN .T.
  ENDIF
  nIter++
  cPartOf = takeout(cDelimStr,';',nIter)
ENDDO
RETURN .F.

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STATIC FUNC putquery(cQDescription)
local cQueryfile := slsf_query()+".DBF"
local nOldArea   := select()
local cQueryDesc := padr(cQDescription,30)
local lOverWrite := .t.
local lSaved     := .f.

*- open up the next available area
SELECT 0

while .t.
 *- check for /build the dbf to hold the queries
 IF !FILE(cQueryFile)
    DBCREATE(cQueryFile,{  {"DBF","C",12,0},;
                           {"DES","C",30,0},;
                           {"FQUERY","C",220,0} } )
 ENDIF

 *- open the QUERIES.DBF file
 IF !SNET_USE(cQueryFile,"__QUERIES",.F.,5,.F.,"No se puede abrir archivo de consultas. 쮀eintenta?")
    USE
    EXIT
 ENDIF

 *- init a value for a description and get it
 popread(.F.,"Ingrese una descripci줻 para esta consulta",@cQueryDesc,"@K!")

 *- if a description was given, store the record
 IF !EMPTY(cQueryDesc) .AND.!LASTKEY()=27
   locate for alltrim(__QUERIES->DBF)==ALIAS(nOldarea) ;
        .and. __QUERIES->des == cQueryDesc .and. !deleted()
   if !found()
      locate for deleted()     // if there's a deleted record, re-use it
      if found() .and. SREC_LOCK(5,.f.)
      ELSEIF !SADD_REC(5,.T.,"Error de red agregando registro. 쮀eintenta?")
            USE
            SELECT (nOldarea)
            EXIT
      endif
   else
      lOverWrite := messyn("쮁obreescribe?")
   endif

   if lOverWrite
      IF SREC_LOCK(5,.T.,"Error de red bloqueando el registro. 쮀eintenta?")
          *- store the dbf alias too
          lSaved := .t.
          REPLACE DBF WITH ALIAS(nOldarea)
          REPLACE des WITH cQueryDesc
          REPLACE fquery WITH sls_query()
          DBRECALL()
      endif
   endif
 ENDIF
 USE
 exit
END
SELECT (nOldarea)
if lSaved
 return cQueryDesc
endif
return cQDescription
//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STATIC FUNCTION GetQuery
local cQueryfile := slsf_query()+".DBF"
local nOldArea   := select()
local cAlias     := ALIAS()
local nSelection := 0
local cStoredQuery
local cQDescription := ""

local aDescript := {}

while .t.
    IF FILE(cQueryFile)
      *- open the next available area and use the queries dbf
      SELECT 0
      IF !SNET_USE(cQueryFile,"__QUERIES",.F.,5,.F.,"No se puede abrir archivo de CONSULTAS. 쮀eintenta?")
         EXIT
      ENDIF
      
      *- see if anything in the dbf matches the current alias
      *- (I realize ALIAS() will not always return current DBF name)
      
      LOCATE FOR UPPER(Alltrim(__QUERIES->dbf))==TRIM(cAlias) ;
                       .and. !deleted()
      
      IF !FOUND()
        USE
        msg("No hay consultas guardadas")
      ELSE
        WHILE FOUND()
          *- while matching records found, load them into array
          AADD(aDescript, __QUERIES->des)
          CONTINUE
        END
      ENDIF
      
      *- if nCounter is more than 1, we found at least one match
      IF len(aDescript) > 0
        
        *- have the user select the query to restore
        Asort(aDescript)
        nSelection = mchoice(aDescript,5,22,16,55,"[Seleccione Consulta]")
        
        *- if the selects one, locate the record
        IF nSelection > 0
          
          LOCATE for aDescript[nSelection]==__QUERIES->des
          cStoredQuery := __QUERIES->fquery
          USE
          SELECT (nOldarea)
          *- test the query against TYPE() to ensure its a valid
          *- expression in the current environment
          *- notify the user if it is not
          *- ignoring indeterminate error UI , which is given
          *- for functions not in CLIPPER.LIB mostly
          
          IF !(TYPE(cStoredQuery) == "U" .OR. TYPE(cStoredQuery) == "UE")
            sls_query(Alltrim(cStoredQuery))
            sls_bquery( &("{||"+sls_query()+"}")  )
            cQDescription := aDescript[nSelection]
          ELSE
            msg("Esta consulta parece ser que no coincide con la base de datos")
          ENDIF
        ELSE
          USE
        ENDIF
      ELSE
        USE
      ENDIF
    ELSE
      *- if no query dbf found, notify the user
      msg("No se encontraron consultas en el archivo" )
    ENDIF
    EXIT
end
select (nOldArea)
return cQDescription

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STATIC PROC EDITQUERY
local cUnder,cEdit
local getlist := {}

 Readinsert(.T.)
 *- draw boxes
 cUnder  := makebox(2,1,20,78,sls_popcol())
 @2,3 SAY "[Evaluaci줻 de una Expresi줻 de Consulta]"
 @4,3 SAY "    Una expresi줻 de consulta puede tener diferentes operadores."
 @ROW()+1,3 SAY "    Cada operaci줻 se efect즑 en un orden particular,"
 @ROW()+1,3 SAY "    con la precedencia que sigue:"
 @ROW()+1,3 SAY ""
 @ROW()+1,3 SAY "    1. Operaciones entre par굈tesis                 ()"
 @ROW()+1,3 SAY "    2. Concatenaciones de expresiones de caracter   + -"
 @ROW()+1,3 SAY "    3. Operaciones Matem쟴icas (en este orden)      ^*/%-+"
 @ROW()+1,3 SAY "    4. Operaciones de comparaci줻                   = < > != $ =="
 @ROW()+1,3 SAY "    5. Operaciones L줳icas (en este orden)          .NOT. .AND. .OR."
 @ROW()+1,3 SAY ""
 @ROW()+1,3 SAY "    Para asegurarse que una operaci� se haga primero, encerrarlo entre par굈tesis."

 @17,2 TO 17,77

 @17,2 SAY '[Editar Consulta]'

 *- fill out the query exp with spaces, store it to the temp var
 cEdit := sls_query()+REPL(' ',220-LEN(sls_query()))

 *- allow the user to edit the temp var - scroll within 65 characters
 @18,3 SAY "Consulta:"
 @19,3 GET cEdit PICT "@S65"
 SET CURSOR ON
 READ
 SET CURSOR OFF

 *- save this thing ?
 IF !EMPTY(cEdit) .AND. !(TRIM(cEdit)==TRIM(sls_query()))
   IF messyn("쭳raba?")
     *- test it against TYPE() for valid expression
     IF !(TYPE(cEdit) == "U" .OR. TYPE(cEdit) == "UE")
       *- if valid, store it back to query_exp
       sls_query(Alltrim(cEdit))
       sls_bquery( &("{||"+sls_query()+"}")  )
     ELSE
       msg("Esta consulta no parece ser coincidente con la base de datos", "O existe una expresi줻 no v쟫ida en la consulta")
     ENDIF
   ENDIF
 ENDIF

 *-
 unbox(cUnder)
return

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
STATIC PROC COUNTQUERY
local nIndexOrd := INDEXORD()
*- save the index order and set it to 0 for rapid count
SET ORDER TO 0
GO TOP

ProgCount(SLS_BQUERY(),"Contando",.t.)
SET ORDER TO (nIndexOrd)
return

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
static PROC BUILDQUERY
local nCompareType
local cUnder,cCurrQuery
local nSpaces
local nLengthCompare
local getlist := {}
DO WHILE GETAFIELD()   // getafield() sets cThisExpression and cThisFldType
  IF !(GetOperator())  // getoperator sets cThisOperator
    EXIT
  ENDIF
  *- get the comparison value now
  nCompareType  := 1
  IF !cThisFldType $ "LM"
    nCompareType := menu_v("Comparar con ",;
                           "Escribir un valor a comparar ", ;
      "Seleccionar un valor de la base de datos (Buscar) ",;
      "Comparar con otro campo de la misma base de datos")
  ENDIF

  DO CASE
  CASE nCompareType == 0 // pressed escape
    LOOP
  CASE nCompareType == 1 // type it in
    IF !(cThisFldType == "L" .OR. (cThisFldType=="M".AND. cThisOperator $"EN"))
      cUnder = makebox(18,9,23,70,sls_popcol())
    ENDIF
    SET CURSOR ON
    DO CASE
    CASE cThisFldType == "M" .AND. cThisOperator=="$"
      cThisCompare= SPACE(60)
      @19,10 SAY "Donde "+LEFT(cThisExpression,60)+" Contiene "
      @20,10 GET cThisCompare
      @21,10 SAY "Usar ; para separar varios 죜ems a comparar"
      @22,10 SAY "p.e. Ralph;Fred;Joe;Eddie   - hasta 10 죜ems"
      READ
      IF EMPTY(cThisCompare)
        cThisCompare = 'EMPTY('+cThisExpression+')'
      ELSE
        cThisCompare = TRIM(cThisCompare)
        cThisCompare = '"'+cThisCompare+'"'
      ENDIF
    CASE cThisFldType =="M" .AND. cThisOperator=="E"
      cThisCompare = 'EMPTY('+cThisExpression+')'
    CASE cThisFldType =="M" .AND. cThisOperator=="N"
      cThisCompare = '!EMPTY('+cThisExpression+')'
    CASE cThisFldType = "C"
      *- figure the size if its a character field - max 40
      cThisCompare = SPACE(MIN(LEN(&cThisExpression),40))
      IF cThisOperator$"$"
        cThisCompare = SPACE(60)
      ENDIF
      *- get the comparison value
      @19,10 SAY "VALOR A COMPARAR     (CARACTERES)"
      @20,10 GET cThisCompare
      IF cThisOperator $ "$"
        @21,10 SAY "Usar ; para separar varios 죜ems a comparar"
        @22,10 SAY "p.e. Ralph;Fred;Joe;Eddie   - hasta 10 죜ems"
      ELSEIF cThisOperator $"?"
        @21,10 SAY "Comodines. Usar ? para representar un solo"
        @22,10 SAY "caracter, * para representar un grupo de caracteres"
      ENDIF
      READ
      *- if its empty, use the EMPTY() function to compare it
      IF EMPTY(cThisCompare)
        IF !(messyn("El valor a comparar ha sido dejado en blanco","Buscar vac죓s (null)","Buscar espacio(s)"))
          nSpaces := 1
          popread(.F.,"N� de espacios a buscar",@nSpaces,"99")
          cThisCompare = 'SPACE('+TRANS(nSpaces,"99")+')'
        ENDIF
      ENDIF
      IF EMPTY(cThisCompare) .AND. cThisOperator == '='
        cThisCompare = 'EMPTY('+cThisExpression+')'
      ELSEIF EMPTY(cThisCompare) .AND. cThisOperator == '<>'
        cThisCompare = '!EMPTY('+cThisExpression+')'
      ELSEIF !("SPACE(" $ cThisCompare)
        cThisCompare = TRIM(cThisCompare)
        cThisCompare = '"'+cThisCompare+'"'
      ENDIF


    CASE cThisFldType = "N"
      *- start with 0
      cThisCompare := 0

      *- get the comparison number - (expand the picture for larger numbers)
      @19,10 SAY "VALOR A COMPARAR " GET cThisCompare PICTURE ed_g_pic(cThisExpression)
      @20,10 SAY "(NUMERO)"
      READ
      cThisCompare := Alltrim(STR(cThisCompare))

    CASE cThisFldType == "D"

      *- store no-date, and get the comparison value
      cThisCompare := DATE()
      @19,10 SAY "VALOR A COMPARAR " GET cThisCompare
      @20,10 SAY "(FECHA)"
      READ
      cThisCompare := DTOC(cThisCompare)
      cThisCompare := 'CTOD("'+cThisCompare+'")'

    CASE cThisFldType == "L"
      cThisCompare := IIF(cThisOperator=="=",cThisExpression,'!'+cThisExpression)
    ENDCASE
    SET CURSOR OFF
    IF !(cThisFldType == "L" .OR. (cThisFldType=="M".AND. cThisOperator $"EN"))
      unbox(cUnder)
    ENDIF
  CASE nCompareType = 2 //select by scrolling
    IF !(FROMLIST())
      LOOP
    ENDIF
    DO CASE
    CASE cThisFldType == "C"
      cThisCompare := TRIM(cThisCompare)
      cThisCompare := '"'+cThisCompare+'"'
    CASE cThisFldType == "N"
      cThisCompare = Alltrim(STR(cThisCompare))
    CASE cThisFldType == "D"
      cThisCompare := DTOC(cThisCompare)
      cThisCompare := 'CTOD("'+cThisCompare+'")'
    CASE cThisFldType == "L"
      cThisCompare := IIF(cThisCompare,cThisExpression,'!'+cThisExpression)
    ENDCASE

  CASE nCompareType == 3 //compare to another field
    IF !(OTHERFIELD())
      LOOP
    ENDIF
  ENDCASE

  *- store the query to a temp variable
  cCurrQuery = sls_query()

  *- here we finish building this portion of the query string
  DO CASE
  CASE cThisFldType $ "CM"
    *- field of type Character
    IF cThisFldType =="C"
      IF !("SPACE(" $ cThisCompare)
        nLengthCompare = LTRIM(TRANS(LEN(cThisCompare)-2,"999"))
      ELSE
        nLengthCompare = LTRIM(TRANS(nSpaces,"999"))
      ENDIF
    ENDIF

    IF LEFT(cThisCompare,5)="EMPTY"
      *- if comparing EMPTY()
      sls_query(sls_query()+ cThisAndOr+'('+cThisCompare+')')
    ELSEIF LEFT(cThisCompare,6)="!EMPTY"
      *- if comparing NOT EMPTY()
      sls_query(sls_query()+ cThisAndOr+'('+cThisCompare+')')
    ELSEIF "$"$cThisOperator
      *- if comparing substring
      IF "!"$cThisOperator
        cThisAndOr := cThisAndOr+"!"
      ENDIF
      IF ";"$cThisCompare
       sls_query(sls_query()+cThisAndOr+'SFQ_CNTAIN('+cThisExpression+','+;
                 cThisCompare+')' )
      ELSE
        sls_query(sls_query()+ cThisAndOr+'('+cThisCompare+"$"+;
                 cThisExpression+')')
      ENDIF
    ELSEIF cThisOperator =="?"
      sls_query(sls_query()+ cThisAndOr+'(_WILDCARD('+;
             cThisCompare+','+cThisExpression+'))' )
    ELSEIF cThisOperator = "QL"
      *- if comparing SIMILIAR SOUNDING
      sls_query(sls_query()+ cThisAndOr+'(SFQ_LIKE('+cThisExpression+','+;
                cThisCompare+'))')
    ELSEIF cThisOperator = "B"
      sls_query(sls_query()+ cThisAndOr+'(left('+cThisExpression+','+;
                nLengthCompare+')=='+cThisCompare+')')
    ELSEIF cThisOperator = "E"
      IF !("SPACE(" $ cThisCompare)
        sls_query(sls_query()+ cThisAndOr+'(right(trim('+cThisExpression+'),'+;
                  nLengthCompare+')=='+cThisCompare+')')
      ELSE
        sls_query(sls_query()+ cThisAndOr+'(right('+cThisExpression+','+;
                  nLengthCompare+')=='+cThisCompare+')')
      ENDIF
    ELSE
      *- otherwise, must just be a string
      sls_query(sls_query()+ cThisAndOr+'('+cThisExpression+cThisOperator+;
                cThisCompare+')')
    ENDIF


  CASE cThisFldType = "N"
    *- numeric field type
    sls_query(sls_query() + cThisAndOr+'('+cThisExpression+cThisOperator+;
              cThisCompare+')')


  CASE cThisFldType = "D"
    *- date field type
    sls_query(sls_query() + cThisAndOr+'('+cThisExpression+cThisOperator+;
             cThisCompare+')')

  CASE cThisFldType = "L"
    sls_query(sls_query() + cThisAndOr+'('+cThisCompare+')')
  ENDCASE

  *- check for line-length boundary (actual boundary is 255, but to be
  *-  safe...)
  IF LEN(sls_query()) > 220
    *- if its too long, restore old query string
    sls_query(cCurrQuery)
    msg('LA CONSULTA HA EXCEDIDO EL LIMITE MAXIMO')
  ENDIF

  *- get AND/OR/NOT etc
  IF !(GETANDOR())
    EXIT
  ENDIF
ENDDO
RETURN

STATIC PROC PURGEQ
local cQueryFile  := slsf_query()+".DBF"
local nOldarea    := SELECT()
IF FILE(cQueryFile)
  SELECT 0
  IF !SNET_USE(cQueryFile,"",.f.,5,.F.,;
     "No se puede abrir archivo de consultas. 쮀eintenta?")
  else
     purgem()
     USE
  ENDIF
ELSE
  MSG("No se encontr� archivo de consultas.")
ENDIF
SELECT (nOldarea)
return

*: EOF: S_QUERY.PRG


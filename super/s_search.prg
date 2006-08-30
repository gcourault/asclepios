
#define SEARCH_FIELD   1
#define SEARCH_QUERY   2
#define SEARCH_EOF     3
#define SEARCH_BOF     4
#define SEARCH_DELETED 5
#define SEARCH_MEMO    6
#define SEARCH_ABORT   7

static lCanContinue     := .f.
static bLocateBlock

FUNCTION searchme(aFieldnames,aFieldtypes,aFieldlens)

local lContinuing,  nOldRecord
local nSearchType
local nOldCursor,lOldExact


if (aFieldnames==nil .or. aFieldtypes==nil .or. aFieldlens==nil)
  aFieldnames :=array(fcount())
  aFieldtypes :=array(fcount())
  aFieldlens  :=array(fcount())
  Afields(aFieldnames,aFieldtypes,aFieldlens)
endif

lOldExact = setexact()
nOldCursor = iif(set(16)=0,.f.,.t.)
SET CURSOR ON
lContinuing = .F.

*- if a CONTINUE is applicable, find out from the user if it is
*- desirable
IF lCanContinue
  lContinuing = messyn("¨Contin£a desde la £ltima b£squeda","Continuar..","B£squeda Nueva")
ENDIF

nOldRecord = RECNO()
*- if no CONTINUE is wanted, build the LOCATE string
while .t.

   IF lContinuing
     if !trycontinue()       // attempt to do a continue
       go (nOldRecord)
     endif
   ELSE
     bLocateBlock  := nil
     nSearchType = SEARCH_FIELD

     nSearchType = menu_v("[Buscar por:]","Contenido de un campo     ",;
                          "Consulta   ","Fin de Archivo","Comienzo del Archivo",;
                          "Registros Marcados","Contenido Campos Memo","Salir")

     IF !( nSearchType = 0 .OR. nSearchType = SEARCH_ABORT )

        IF nSearchType = SEARCH_FIELD
          searchfld(aFieldNames,aFieldTypes,aFieldLens)
        ELSEIF nSearchType = SEARCH_QUERY
          IF !EMPTY(sls_query())
            IF messyn("¨Modifica la consulta?")
              QUERY()
            endif
            IF !EMPTY(sls_query())
              bLocateBlock := sls_bquery()
            ENDIF
          ELSEIF isloaded("QUERY()")
            IF messyn("No existe consulta .....¨HACE UNA AHORA?")
              QUERY()
              IF !EMPTY(sls_query())
                bLocateBlock := sls_bquery()
              ENDIF
            ENDIF
          ENDIF
        ELSEIF nSearchType = SEARCH_EOF
          GO BOTT
          LOCATE for .t. while .t.
          lCanContinue = .F.
          exit
        ELSEIF nSearchType = SEARCH_BOF
          GO TOP
          LOCATE for .t. while .t.
          lCanContinue = .F.
          exit
        ELSEIF nSearchType = SEARCH_DELETED
          bLocateBlock := {||DELETED()}
        ELSEIF nSearchType = SEARCH_MEMO
          searchmemo(aFieldNames,aFieldTypes)
        ENDIF

        if bLocateBlock#nil
          plswait(.T.,"Buscando...")
          go top
          locate for eval(bLocateBlock) while (inkey()#27)
          plswait(.F.)
          IF .NOT. FOUND()
            GO nOldRecord
            IF !LASTKEY()=27
              msg("No hay coincidencias ...")
            ELSE
              msg("El usuario cancel¢ el proceso...")
            ENDIF
            lCanContinue = .F.
          ELSE
            *- if we found one, there may be others. Set lCanContinue to .t.
            lCanContinue = .T.
          ENDIF
        endif
     endif
   ENDIF  // continue
   exit
end
SET CURSOR (nOldCursor)
setexact(lOldExact)

RETURN bLocateBlock


//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
STATIC FUNCTION getmemos(aFieldNames,aFieldTypes)
local nIterator
local nMemoCount   := 0
local aMemoFields  := {}
FOR nIterator = 1 TO len(aFieldNames)
  IF aFieldTypes[nIterator] == "M"
    nMemoCount++
    aadd(aMemoFields,aFieldNAmes[nIterator])
  ENDIF
NEXT
RETURN aMemoFields


//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
STATIC FUNCTION charops    // character operators
return { "== es exactamente igual a",;
         ">  es mayor que",;
         "<  es menor que",;
         ">= es mayor o igual a",;
         "<= es menor o igual a",;
         "#  es distinto a",;
         "$  contiene",;
         "S  comienza con",;
         "E  termina con",;
         "?  COMODINES"  }

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
STATIC FUNCTION dnoops    // date/numeric operators
return { "=  es igual a",;
         ">  es mayor que",;
         "<  es menor que",;
         ">= es mayor o igual que",;
         "<= es menor o igual que",;
         "#  es distinto que"  }

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

STATIC FUNCTION trycontinue
  *- execute the CONTINUE
  SET EXACT OFF
  plswait(.T.,"Buscando...")
  CONTINUE
  plswait(.F.)
  IF .NOT. FOUND()
    msg("No hay m s coincidencias... ")
    lCanContinue = .F.
  ELSE
    *- if we found something, set lCanContinue to .t. to allow more CONTINUE's
    lCanContinue = .T.
  ENDIF
return found()

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
#define MEMO_CONTAINS 1
#define MEMO_ISEMPTY  2
#define MEMO_NOTEMPTY 3

STATIC FUNCTION searchmemo(aFieldNames,aFieldTypes,nFieldSelection)
local    aOperators  :={"$  contiene",;
                        "E  est  vac¡o",;
                        "N  no est  vac¡o"}
local    aMemoFields := getmemos(aFieldNames,aFieldtypes)
local    cMemoTargetField := ""
local    nMemoSelection
local    nOperatorSelection,cOperatorDescription,cTargetValue


   IF nFieldSelection#nil
     cMemoTargetField := aFieldNames[nFieldSelection]
   ELSEIF len(aMemoFields)==0
     msg("No hay campos memo en esta base de datos.")
   ELSEIF len(aMemoFields) > 1
     nMemoSelection = mchoice(aMemoFields,2,50,9,77,"Memo field to SEARCH")
     IF nMemoSelection > 0
       cMemoTargetField = aMemoFields[nMemoSelection]
     ENDIF
   ELSE
     cMemoTargetField := aMemoFields[1]
   ENDIF

   if !empty(cMemoTargetField)
      nOperatorSelection   := mchoice(aOperators,5,20,13,60,;
              "Buscar registro donde campo memo "+cMemoTargetField+":")
      nOperatorSelection   := MAX(nOperatorSelection,1)
      cOperatorDescription := SUBST(aOperators[nOperatorSelection],4)

      IF nOperatorSelection == MEMO_CONTAINS
          cTargetValue = SPACE(60)
          popread(.T.,padr('Buscar '+cMemoTargetField+;
                  ' contiene  : ',70),@cTargetValue,"")
          cTargetValue := Alltrim(cTargetValue)
          IF !EMPTY(cTargetValue)
            bLocateBlock := ;
              {||cTargetValue$fieldget(fieldpos(cMemoTargetField))}
          ENDIF
      ELSEIF nOperatorSelection == MEMO_ISEMPTY
        bLocateBlock := {||empty(fieldget(fieldpos(cMemoTargetField)))}
      ELSEIF nOperatorSelection == MEMO_NOTEMPTY
        bLocateBlock := {||!empty(fieldget(fieldpos(cMemoTargetField)))}
      ENDIF
   ENDIF  // any memo fields selected
RETURN nil


//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
#define OCHAR_EXACT 1
#define OCHAR_GT    2
#define OCHAR_LT    3
#define OCHAR_GTE   4
#define OCHAR_LTE   5
#define OCHAR_NOTEQUAL    6
#define OCHAR_CONTAINS    7
#define OCHAR_STARTSWITH  8
#define OCHAR_ENDSWITH    9
#define OCHAR_WILDCARD    10
#define DN_EQ      1
#define DN_GT      2
#define DN_LT      3
#define DN_GTE     4
#define DN_LTE     5
#define DN_NOT     6

static function searchfld(aFieldNames,aFieldTypes,aFieldLens)
local nFieldSelection,cTargetField,cSearchString
local aOperators,nOperatorSelection,cOperatorDescription
local nLengthOfSearch
local cTargetValue,nTargetValue,dTargetValue,lTargetValue
local cInstruction,cLengthPicture

  *- call MCHOICE() to do an achoice on the aFieldnames[] array
  nFieldSelection = mchoice(aFieldnames,5,20,20,50,;
              "[  Seleccione Campo De Base de Datos  ] ")

  *- Vern made a selection!
  IF nFieldSelection # 0
    *- cTargetField contains the name of the selected field to LOCATE on
    cTargetField  := aFieldnames[nFieldSelection]
    cSearchString := aFieldnames[nFieldSelection]

    DO CASE
    CASE aFieldtypes[nFieldSelection] == "C"
        aOperators  := charops()
        nOperatorSelection   := mchoice(aOperators,5,20,16,60,;
           "[ Buscar registros donde "+aFieldnames[nFieldSelection]+": ] ")
        nOperatorSelection   := MAX(nOperatorSelection,1)
        cOperatorDescription := SUBST(aOperators[nOperatorSelection],4)
        DO CASE
        CASE nOperatorSelection = OCHAR_WILDCARD
          cInstruction = "COMODIN (*=grupo de caracteres, ?=un solo caracter) para "+aFieldnames[nFieldSelection]
        OTHERWISE
          cInstruction = padr('Buscar '+aFieldnames[nFieldSelection]+' '+cOperatorDescription+'   ',70)
        ENDCASE
        cTargetValue = SPACE(aFieldlens[nFieldSelection])
        cLengthPicture = "@S"+LTRIM(STR(MIN(aFieldlens[nFieldSelection],65)))
        popread(.T.,cInstruction,@cTargetValue,cLengthPicture)
        IF nOperatorSelection > OCHAR_EXACT   // if not exact, trim it
          cTargetValue = Alltrim(cTargetValue)
        ENDIF
        IF nOperatorSelection < OCHAR_CONTAINS  //7
          DO CASE
          CASE nOperatorSelection==OCHAR_EXACT
            bLocateBlock := {||fieldget(fieldpos(cTargetField))==cTargetValue}
          CASE nOperatorSelection==OCHAR_GT
            bLocateBlock := {||fieldget(fieldpos(cTargetField)) > cTargetValue}
          CASE nOperatorSelection==OCHAR_LT
            bLocateBlock := {||fieldget(fieldpos(cTargetField)) < cTargetValue}
          CASE nOperatorSelection==OCHAR_GTE
            bLocateBlock := {||fieldget(fieldpos(cTargetField)) >= cTargetValue}
          CASE nOperatorSelection==OCHAR_LTE
            bLocateBlock := {||fieldget(fieldpos(cTargetField)) <= cTargetValue}
          CASE nOperatorSelection==OCHAR_NOTEQUAL
            bLocateBlock := {||fieldget(fieldpos(cTargetField)) # cTargetValue}
          ENDCASE
        ELSEIF nOperatorSelection = OCHAR_CONTAINS
          bLocateBlock := {||cTargetValue$fieldget(fieldpos(cTargetField))}
        ELSEIF nOperatorSelection = OCHAR_STARTSWITH
          nLengthOfSearch := LEN(cTargetValue)
          bLocateBlock := ;
            {||LEFT(fieldget(fieldpos(cTargetField)),nLengthOfSearch)==;
            cTargetValue}
        ELSEIF nOperatorSelection = OCHAR_ENDSWITH
          nLengthOfSearch := LEN(cTargetValue)
          bLocateBlock := ;
            {||SUBST(TRIM(fieldget(fieldpos(cTargetField))),-nLengthOfSearch);
            ==cTargetValue}
        ELSEIF nOperatorSelection = OCHAR_WILDCARD
          bLocateBlock := ;
            {||_WILDCARD(cTargetValue,fieldget(fieldpos(cTargetField)))}
        ENDIF
    CASE aFieldtypes[nFieldSelection] == "D"
        aOperators  := dnoops()
        nOperatorSelection   := mchoice(aOperators,5,20,16,60,;
           "[ Buscar registros donde "+aFieldnames[nFieldSelection]+": ] ")
        nOperatorSelection   := MAX(nOperatorSelection,1)
        cOperatorDescription := SUBST(aOperators[nOperatorSelection],4)
        dTargetValue = CTOD("  /  /  ")
        popread(.T.,'Buscar '+aFieldnames[nFieldSelection]+' '+cOperatorDescription+'  : '+SPACE(1),@dTargetValue,'')
        DO CASE
        CASE nOperatorSelection == DN_EQ
          bLocateBlock := {||fieldget(fieldpos(cTargetField))=dTargetValue}
        CASE nOperatorSelection == DN_GT
          bLocateBlock := {||fieldget(fieldpos(cTargetField))>dTargetValue}
        CASE nOperatorSelection == DN_LT
          bLocateBlock := {||fieldget(fieldpos(cTargetField))<dTargetValue}
        CASE nOperatorSelection == DN_GTE
          bLocateBlock := {||fieldget(fieldpos(cTargetField))>=dTargetValue}
        CASE nOperatorSelection == DN_LTE
          bLocateBlock := {||fieldget(fieldpos(cTargetField))<=dTargetValue}
        CASE nOperatorSelection == DN_NOT
          bLocateBlock := {||fieldget(fieldpos(cTargetField))#dTargetValue}
        ENDCASE
    CASE aFieldtypes[nFieldSelection] == "N"
        aOperators  := dnoops()
        nOperatorSelection   := mchoice(aOperators,5,20,16,60,;
           "[ Buscar registros donde "+aFieldnames[nFieldSelection]+": ] ")
        nOperatorSelection   := MAX(nOperatorSelection,1)
        cOperatorDescription := SUBST(aOperators[nOperatorSelection],4)
        nTargetValue = 0
        popread(.T.,'Buscar '+aFieldnames[nFieldSelection]+' '+cOperatorDescription+'  : '+SPACE(15),@nTargetValue,ed_g_pic(cTargetField))
        DO CASE
        CASE nOperatorSelection == DN_EQ
          bLocateBlock := {||fieldget(fieldpos(cTargetField))=nTargetValue}
        CASE nOperatorSelection == DN_GT
          bLocateBlock := {||fieldget(fieldpos(cTargetField))>nTargetValue}
        CASE nOperatorSelection == DN_LT
          bLocateBlock := {||fieldget(fieldpos(cTargetField))<nTargetValue}
        CASE nOperatorSelection == DN_GTE
          bLocateBlock := {||fieldget(fieldpos(cTargetField))>=nTargetValue}
        CASE nOperatorSelection == DN_LTE
          bLocateBlock := {||fieldget(fieldpos(cTargetField))<=nTargetValue}
        CASE nOperatorSelection == DN_NOT
          bLocateBlock := {||fieldget(fieldpos(cTargetField))#nTargetValue}
        ENDCASE
    CASE aFieldtypes[nFieldSelection]=="L"
        *- if its a LOGICAL, we just have one operator (=)
        nOperatorSelection   := 1
        cOperatorDescription := "="
        lTargetValue = .F.
        popread(.T.,'Buscar '+aFieldnames[nFieldSelection]+' '+cOperatorDescription+'  : '+SPACE(1),@lTargetValue,'')
        if lTargetValue
         bLocateBlock := {||fieldget(fieldpos(cTargetField))}
        else
         bLocateBlock := {||!fieldget(fieldpos(cTargetField))}
        endif
    CASE aFieldtypes[nFieldSelection]=="M"
      searchmemo(aFieldNames,aFieldTypes,nFieldSelection)
    ENDCASE
  endif //nFieldSelection > 0
RETURN NIL


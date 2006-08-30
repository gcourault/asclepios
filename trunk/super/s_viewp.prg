static nElement := 1


#include "getexit.ch"
#include "inkey.ch"
#include "box.ch"
FUNCTION viewport(lEditAddFlag,aFieldNames,aFieldDesc,aFieldPicts,;
      aFieldValids,aFieldLookups,aOtherMenu,aEditable,lCarryFlag,cTitle)

local aMemos := {}
local aFieldTypes,aFieldLens,aFieldDeci,aValBlocks
local aGetSet,aValues,oTB
local cInScreen := savescreen(0,0,24,79)
local lReadExit  := Readexit(.T.)
local nOldCursor := setcursor(1)
local bOldF2     := setkey(-1)
local bOldF10    := setkey(-9,{||ctrlw()})
local lOtherMenu := .f.
local aOtherPrompt := {}
local aOtherProc   := {}
local cOldColor    := Setcolor(sls_normcol())
local aIndexKeys   := fillkeys()
local nMainChoice
local cBrowseBox
local nRecord,nSubChoice,cMemoBox,cOtherBox,lDoCarry
local i

nElement        := 1
lEditAddFlag    := iif(lEditAddFlag#nil,lEditAddFlag,.t.)
lCarryFlag      := iif(lCarryFlag#nil,lCarryFlag,.t.)
aFieldNames     := iif(VALTYPE(aFieldNames)#"A",fillfields(),aFieldNames)
aFieldDesc      := iif(VALTYPE(aFieldDesc)#"A",fillfields(),aFieldDesc)

aFieldTypes := array(len(aFieldNames))
aFieldLens  := array(len(aFieldNames))
aFieldDeci  := array(len(aFieldNames))
fillarr(aFieldNames,aFieldTypes,aFieldLens,aFieldDeci)

if !(VALTYPE(aFieldPicts)=="A" .and. len(aFieldPicts)=len(aFieldNames))
  aFieldPicts := array(len(aFieldNames))
  afill(aFieldPicts,"")
endif
if !(VALTYPE(aFieldValids)=="A" .and. len(aFieldValids)=len(aFieldNames))
  aFieldValids := array(len(aFieldNames))
  afill(aFieldValids,"")
endif
if !(VALTYPE(aFieldLookups)=="A" .and. len(aFieldLookups)=len(aFieldNames))
  aFieldLookups := array(len(aFieldNames))
  afill(aFieldLookups,"")
endif
if !(VALTYPE(aEditable)=="A" .and. len(aEditable)=len(aFieldNames))
  aEditable := array(len(aFieldNames))
  afill(aEditable,.t.)
endif
aValBlocks  := makevalid(aFieldValids)

IF VALTYPE(aOtherMenu)=="A"
  lOtherMenu := .T.
  for i = 1 TO len(aOtherMenu)
    aadd(aOtherPrompt,takeout(aOtherMenu[i],';',1))
    aadd(aOtherProc,takeout(aOtherMenu[i],';',2))
  NEXT
  aadd(aOtherPrompt,"Salir del Otro Menú")
  aadd(aOtherProc,"")
ENDIF
aGetSet := makegetset(aFieldNames,aEditable)
aValues := array(len(aFieldNames))
fillvalues(aGetset,aValues)
oTB     := maketb(aFieldDesc,aValues,aFieldPicts,aFieldtypes)
aMemos  := figmemos(aFieldNames,aFieldTypes)


@ 0,15,24,79 BOX B_SINGLE
* @ 0,15,24,79 BOX "ÚÄ¿³ÙÄÀ³ "
if valtype(cTitle)=="C"
  @0,18 SAY cTitle
else
  @0,18 SAY "  ACCESO para archivo: "+TRIM(ALIAS())+' '
endif
IF len(aFieldNames) > 22
  @24,18 SAY "< Pgup Pgdn >"
ENDIF
Setcolor(sls_popcol())
@ 0,0,24,14 box B_DOUBLE
* @ 0,0,24,14 BOX "ÉÍ»º¼ÍÈº "
* @18,1 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄ"
@18,1 say space(12)
@0,2 SAY " Menú "
* display the menu screen
*----------------------
*- main loop

*- fill in the first set of field pictures
nMainChoice = 1

DO WHILE .T.
  DISPBEGIN()
    while !oTb:stabilize()
    end
    SETCURSOR(0)
    SET COLOR TO (sls_popmenu())
    @2,2       PROMPT "Siguiente   " 
    @ROW()+1,2 PROMPT "Anterior    "
    @ROW()+1,2 PROMPT "Buscar      "
    @ROW()+1,2 PROMPT "Por Clave   "
    @ROW()+1,2 PROMPT "Visión      "
    @ROW()+1,2 PROMPT "Hardcopy    "
    @ROW()+1,2 PROMPT "Ver Memo    "
    @ROW()+1,2 PROMPT "Consultar   "
    @ROW()+1,2 PROMPT "Orden Campos"
    IF lEditAddFlag
      @ROW()+1,2 PROMPT "Editar      "
      @ROW()+1,2 PROMPT "Nuevo       "
      @ROW()+1,2 PROMPT "Editar Memo "
      @ROW()+1,2 PROMPT IIF(DELETED(),"DesBorra","Borra   ")
    ENDIF
    IF lOtherMenu
      @ROW()+1,2 PROMPT "Otro Menú "
    ENDIF
    @ROW()+1,2 PROMPT "Terminar   "


    @19,2 SAY "Rec# "
    @20,2 SAY STR(RECNO())
    @21,2 SAY "de # "
    @22,2 SAY STR(RECCOUNT())
    @23,2 SAY IIF(DELETED(),"Borrado","       ")
  DISPEND()

  MENU TO nMainChoice

  SET COLOR TO (sls_popcol())
  DO CASE
  //---------------------------------------------------------
  CASE lastkey()==K_PGUP
    oTb:rowpos := 1
    nElement := iif(nElement==1,nElement,nElement-1)
    oTb:refreshall()
  //---------------------------------------------------------
  CASE lastkey()==K_PGDN
    if nElement+21 < len(aFieldNames)
      oTb:rowpos := 1
      nElement := iif(nElement==len(aFieldNames),nElement,nElement+1)
      oTb:refreshall()
    endif
  //---------------------------------------------------------
  CASE nMainChoice = 1
    SKIP
    if eof()
      go bott
    endif
    fillvalues(aGetset,aValues)
    oTb:refreshall()
  //---------------------------------------------------------
  CASE nMainChoice = 2
    SKIP -1
    fillvalues(aGetset,aValues)
    oTb:refreshall()
  //---------------------------------------------------------
  CASE nMainChoice = 3
    searchme(aFieldNames,aFieldTypes,aFieldLens)
    fillvalues(aGetset,aValues)
    oTb:refreshall()
  //---------------------------------------------------------
  CASE nMainChoice = 4
    getseek(aIndexKeys)
    fillvalues(aGetset,aValues)
    oTb:refreshall()
  //---------------------------------------------------------
  CASE nMainChoice = 5
    cBrowseBox = makebox(0,0,24,79,Setcolor(),0)
    @2,1 TO 2,78
    @1,1 SAY "Use Up Down Right Left PGUP PGDN HOME END        Pulse ENTER para salir"
    Setcolor(sls_normcol())
    DBEDIT(3,1,23,78, aFieldNames,'','',aFieldDesc)
    Setcolor(sls_popcol())
    unbox(cBrowseBox)
    fillvalues(aGetset,aValues)
    oTb:refreshall()
  //---------------------------------------------------------
  CASE nMainChoice = 6
    hardcopy(aFieldDesc,aValues,aFieldTypes,aMemos)
  //---------------------------------------------------------
  CASE nMainChoice = 7
    IF len(aMemos) > 0
      nSubchoice = 1
      IF len(aMemos) > 1
        nSubchoice = mchoice(aMemos,2,15,3+len(aMemos),26,"¿Cuál Memo:?")
        if nSubchoice = 0
          loop
        endif
      ENDIF

      cMemoBox := makebox(0,15,24,79,Setcolor(),0)
      @0,18 SAY '[VIENDO CAMPO MEMO: '+aMemos[nSubchoice]+' Pulse ESCAPE para salir]'
      Memoedit(HARDCR(&(aMemos[nSubChoice])),1,16,23,78,.F.,'',200)
      unbox(cMemoBox)
    ELSE
      msg("No se detectaron campos memo","")
    ENDIF
  //---------------------------------------------------------
  CASE nMainChoice = 8
    QUERY(aFieldNames,aFieldDesc,aFieldTypes,"a Acceso")
  //---------------------------------------------------------
  CASE nMainChoice = 9
    orderfields(aFieldNames,aFieldDesc,aFieldPicts,;
      aFieldValids,aFieldLookups,aEditable,aFieldTypes,aFieldLens,;
      aFieldDeci,aValues,aGetSet)
    fillvalues(aGetset,aValues)
    oTb:refreshall()
  //---------------------------------------------------------
  CASE nMainChoice = 10 .AND. lEditAddFlag .AND. RECCOUNT()>0
    SETCURSOR(1)
    if vpedit(aValues,oTb,aValBlocks,aFieldLookups,aFieldPicts,;
            aFieldTypes,aEditable)
       if messyn("¨Graba?")
          saverecord(aValues,aGetSet,aEditable,aFieldtypes)
       endif
    endif
    SETCURSOR(0)
    UNLOCK
    fillvalues(aGetset,aValues)
    oTb:refreshall()
  //---------------------------------------------------------
  CASE nMainChoice = 11 .AND. lEditAddFlag
    nRecord := recno()
    lDoCarry := .f.
    IF RECCOUNT()>0 .and. lCarryFlag
      IF !messyn("Mantiene el contenido del registro anterior","No","Si")
        lDoCarry := .t.
      ENDIF
    ENDIF
    if !lDocarry
      go bottom
      skip
      fillvalues(aGetset,aValues)
    endif
    SETCURSOR(1)
    if vpedit(aValues,oTb,aValBlocks,aFieldLookups,aFieldPicts,;
            aFieldTypes,aEditable)
       if messyn("¿Graba?")
          addrecord(aValues,aGetSet,aEditable,aFieldtypes)
       else
          go nRecord
       endif
    else
      go nRecord
    endif
    SETCURSOR(0)
    UNLOCK
    fillvalues(aGetset,aValues)
    oTb:refreshall()
  //---------------------------------------------------------
  CASE nMainChoice = 12 .AND. lEditAddFlag    && edit memo
    IF len(aMemos) > 0
      nSubchoice = 1
      IF len(aMemos) > 1
        nSubchoice = mchoice(aMemos,2,15,3+len(aMemos),26,"¿Cuál Memo?:")
        if nSubchoice = 0
          loop
        endif
      ENDIF
      editmemo(aMemos[nSubchoice],0,15,24,79,.t.)
    ELSE
      msg("No se detectaron campos memo","")
    ENDIF

  //---------------------------------------------------------
  CASE nMainChoice = 13 .AND. lEditAddFlag
    if SREC_LOCK(5,.T.,"Error de red bloqueando registro. ¿Reintenta?")
      IF DELETED()
        RECALL
      ELSE
        DELETE
      ENDIF
      unlock
      goto recno()
    endif
  //---------------------------------------------------------
  CASE (nMainChoice = 10.OR. nMainChoice=14) .AND. (lOtherMenu)
    *- other
    cOtherBox := makebox(8,6,10+len(aOtherPrompt),6+BIGELEM(aOtherPrompt)+2)
    @9,8 PROMPT aOtherPrompt[1]
    for i = 2 TO len(aOtherPrompt)
      @ROW()+1,8 PROMPT aOtherPrompt[i]
    NEXT
    MENU TO nSubChoice
    unbox(cOtherBox)
    IF nSubChoice > 0 .AND. nSubChoice < len(aOtherPrompt)
      i := &( aOtherProc[nSubChoice] )
    ENDIF
  //---------------------------------------------------------
  OTHERWISE
    IF MESSYN("¿Sale?")
      SETCURSOR(nOldCursor)
      SETKEY(-1,bOldF2)
      SETKEY(-9,bOldF10)
      Readexit(lReadExit)
      Setcolor(cOldColor)
      restscreen(0,0,24,79,cInScreen)
      exit
    endif
  ENDCASE
ENDDO
nElement := nil
return nil

//-------------------------------------------------------------
static FUNCTION hardcopy(aFieldDesc,aValues,aFieldTypes,aMemos)
local nRecorMem  := 1
local nTargetDev := 1
LOCAL cOutFile
LOCAL i,nMemo,cMemo,nLineCount

DO WHILE .T.
  IF len(aMemos) > 0
    if ( nRecOrMem  := menu_v("Hardcopy de:","Registro actual  ",;
                  "Memo asociado al campo ") )=0
      EXIT
    endif
  ENDIF
  if (nTargetDev := menu_v("Enviar HardCopy a:","Impresora         ","Archivo de texto"))=0
    EXIT
  ENDIF
  IF nTargetDev = 1
    sls_prn(prnport())  
    IF !p_ready(sls_prn())
      EXIT
    ENDIF
  ELSE
    cOutFile := SPACE(12)
    popread(.F.,"Archivo al cual imprimir ",@cOutFile,"@N")
    IF EMPTY(cOutFile)
      EXIT
    ENDIF
    IF FILE(cOutFile)
      IF !messyn("El Archivo "+cOutFile+" ya existe y se sobreescribir . ¿Continúa?")
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
      IF aFieldTypes[i]=="M"
        ??"(memo)"
      ELSE
        ??padr(TRANS(aValues[i],""),65)
      ENDIF
      IF (i%60)=0
        EJECT
      ENDIF
    NEXT
    IF (i%60)<>0
      EJECT
    ENDIF
  ELSE
    IF len(aMemos) > 1
      if (nMemo := mchoice(aMemos,8,27,15,54,"Campo Memo a Imprimir"))=0
        RETURN ''
      ENDIF
      cMemo := &( aMemos[nMemo] )
    ELSE
      cMemo := &( aMemos[1] )
    ENDIF
    nLineCount = MLCOUNT(cMemo,79)
    SET CONSOLE OFF
    IF !EMPTY(cMemo)
      if messyn("Se imprimirán: "+alltrim(str(nLineCount))+" líneas.",;
                 "Contin£a","Cancela")
        FOR i = 1 TO nLineCount
          ?MEMOLINE(cMemo,79,I)
          IF (i%60)=0
            EJECT
          ENDIF 
        NEXT
        IF (i%60)<>0
          EJECT
        ENDIF 
      endif
    ELSE
      msg("Este campo memo está vacío")
    ENDIF
  ENDIF
  SET PRINTER TO (sls_prn())
  SET PRINT OFF
  SET CONSOLE ON
  EXIT
ENDDO
RETURN nil

//--------------------------------------------------------------
static function makegetset(aFields,aEditable)
local i
local aGetSet := {}
for i = 1 to len(aFields)
  do case
  case iseditable(aFields[i])
    aadd(aGetSet,getwb(aFields[i]))
  case isfield(aFields[i])
    aadd(aGetSet,getwb(aFields[i]))
    aEditable := .f.
  otherwise
    aadd(aGetSet,getexpb(aFields[i]))
    aEditable := .f.
  endcase
next
return aGetSet

//--------------------------------------------------------------
static proc fillvalues(aGetSet,aValues)
local i
for i= 1 to len(aGetSet)
  aValues[i] := eval(aGetSet[i])
next
return

//--------------------------------------------------------------
static function getexpb(combo)
local bBlock
bBlock := &("{||"+combo+"}")
return bBlock

//--------------------------------------------------------------

static function getwb(combo)
local workarea
if "->"$combo
  workarea := select( getalias(combo) )
else
  workarea := select()
endif
return fieldwblock(getfield(combo),workarea)

//--------------------------------------------------------------

static function getalias(combo)
if "->"$combo
  return left(combo,at("-",combo)-1)
else
  return alias()
endif
return ''

//--------------------------------------------------------------

static function getfield(combo)
if "->"$combo
  return subst(combo,at(">",combo)+1)
else
  return combo
endif
return ''

//--------------------------------------------------------------

static function isfield(f)
local lAliased := "->"$f
local cFieldName,cAliasNAme
local lIsField
if lAliased
  cFieldName    := subst(f,at("->",f)+2)
  cAliasNAme    := left(f,at("->",f)-1)
else
  cFieldName     := f
  cAliasNAme := alias()
endif
if select(cAliasNAme)==0
  lIsField := .f.
else
  lIsField := ( (cAliasNAme)->(fieldpos(cFieldName)) ) > 0
endif
return lIsField

//--------------------------------------------------------------
static function isthisarea(f)
local lAliased := "->"$f
local cFieldName,cAliasNAme
local lIsThisArea := .t.
if lAliased
  cAliasNAme    := left(f,at("->",f)-1)
  lIsThisArea   := ALLTRIM(UPPER(cAliasName))==ALLTRIM(UPPER(alias()))
endif
return lIsThisArea

//--------------------------------------------------------------
static function iseditable(f)
return isfield(f) .and. isthisarea(f)
//--------------------------------------------------------------
static function maketb(aDesc,aValues,aPict,aFieldtypes)
//local tb      := tbrowsenew(2,16,22,78)
local tb      := tbrowsenew(2,16,min(22,len(aDesc)+1),78)
local cColor  := subst(setcolor(),1,at(",",setcolor())-1)
local hColor  := takeout(setcolor(),",",5)

tb:colorspec := cColor+","+cColor+","+hColor
tb:addcolumn(tbcolumnnew(nil,{||padr(aDesc[nElement],15)  }))
tb:addcolumn(tbcolumnnew(nil,;
            {||iif(aFieldTypes[nElement]=="M","(memo)",;
             padr(trans(aValues[nElement],aPict[nElement]),30)) }))
//tb:getcolumn(2):defcolor := {3,3}
tb:getcolumn(2):colorblock := {||{3,3}}
tb:skipblock := {|n|aaskip(n,@nElement,len(aDesc))}
tb:gotopblock := {||agotop(nElement,tb)}
tb:gobottomblock := {||agobot(nElement,LEN(aDesc),tb)}
return tb

//-----------------------------------------------
static proc agoTop(nElement,oBrz)
local nTemp := nElement
while nTemp > 1
  oBrz:up()
  nTemp--
end
return
//-----------------------------------------------
static proc agoBot(nElement,nLen,oBrz)
local nTemp := nElement
dispbegin()
while nTemp < nLen
  oBrz:down()
  nTemp++
end
while !oBrz:stabilize()
end
dispend()
return

//-----------------------------------------------
static function fillfields
local aFieldNames := array(fcount())
afields(aFieldNames)
return aFieldNames

//------------------------------------------------
static function makevalid(aValids)
local aValBlocks := array(len(aValids))
local i,cValid,cMsg
local cPreMac
for i = 1 to len(aValids)
  if !empty(aValids[i])
    cValid        := takeout(aValids[i],";",1)
    cMsg          := takeout(aValids[i],";",2)
    cPreMac       := ("{|__1|"+strtran(cValid,"@@","__1")+"}")
    aValBlocks[i] := {&(cPreMac),cMsg}
  else
    aValBlocks[i] := nil
  endif
next
return aValBlocks
//-----------------------------------------------
static function figmemos(aFieldNames,aTypes)
local aMemos := {}
local i
for i = 1 to len(aFieldNames)
  if aTypes[i]=="M"
    aadd(aMemos,aFieldNames[i])
  endif
next
return aMemos
//------------------------------------------------
static function fillkeys
local aKeys := {}
local i := 1
while !empty(indexkey(i))
  aadd(aKeys,indexkey(i))
  i++
end
return aKeys

//------------------------------------------------
static function getseek(aKeys)
local nKey := 0
local expRead
local nOldOrder := indexord()
local nRecord   := recno()
if len(aKeys) > 1
   nKey := mchoice(aKeys,5,15,5+len(aKeys)+2,65,"Seleccione un ¡ndice Clave")
elseif len(aKeys)==1
   nKey := 1
else
   msg("No hay índices abiertos")
endif
if nKey > 0
  expRead := eval( &("{||"+aKeys[nKey]+"}") )
  popread(.t.,"Buscar:",@expRead,"@K")
  if lastkey()<>K_ESC .and. !empty(expRead)
     IF VALTYPE(expRead)=="C"
       expRead := trim(expRead)
     endif
     set order to (nKey)
     seek expRead
     if !found()
       msg("No encontrado.")
       go nRecord
     endif
  endif
endif
set order to (nOldOrder)
return nil

//------------------------------------------------
STATIC FUNCTION orderfields(aFieldNames,aFieldDesc,aFieldPicts,;
      aFieldValids,aFieldLookups,aEditable,aFieldTypes,aFieldLens,;
      aFieldDeci,aValues,aGetSet)

local cSortBox := makebox(2,9,21,65)
local nNewPosition,nOldPosition
local getlist := {}

@ 2,28 SAY "Â"
@ 18,9 SAY 'Ã'
@ 21,28 SAY "Á"
@ 3,28 SAY "³  Orden  de los Campos:"
@ 4,28 SAY "³"
@ 5,28 SAY "³ Los campos de esta base de datos"
@ 6,28 SAY "³ pueden ser vistos en cualquier"
@ 7,28 SAY "³ orden."
@ 8,28 SAY "³ "
@ 9,28 SAY "³ "
@ 10,28 SAY "³"
@ 11,28 SAY "³ Pulse ENTER para elegir un campo"
@ 12,28 SAY "³ a mover. Luego se le pedir  la po-"
@ 13,28 SAY "³ sici¢n a donde moverlo."
@ 14,28 SAY "³"
@ 15,28 SAY "³"
@ 16,28 SAY "³"
@ 17,28 SAY "³"
@ 18,10 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´"
@ 19,28 SAY "³ Pulse ESCAPE para terminar."
@ 20,10 SAY "Campos Totales:   ³"
@ 20,23 SAY LTRIM(STR(len(aFieldNames) ))

nNewPosition := 1
nOldPosition := 1
WHILE nOldPosition > 0
  nOldPosition := nNewPosition
  nOldPosition := SACHOICE(4,12,17,27,aFieldDesc)
  IF nOldPosition = 0
    EXIT
  ENDIF
  SETCURSOR(1)
  @ 19,10 SAY "Posici¢n Nueva:" GET nNewPosition PICT "99"
  READ
  @ 19,10 SAY "                   "
  SETCURSOR(0)
  IF nNewPosition <= 0
    nNewPosition = 1
  ELSEIF nNewPosition > len(aFieldNames)
    nNewPosition = len(aFieldNames)
  ENDIF

  fieldshift(aFieldNames,nOldPosition,nNewPosition)
  fieldshift(aFieldDesc,nOldPosition,nNewPosition)
  fieldshift(aFieldTypes,nOldPosition,nNewPosition)
  fieldshift(aFieldLens,nOldPosition,nNewPosition)
  fieldshift(aFieldPicts,nOldPosition,nNewPosition)
  fieldshift(aFieldValids,nOldPosition,nNewPosition)
  fieldshift(aFieldLookups,nOldPosition,nNewPosition)
  fieldshift(aEditable,nOldPosition,nNewPosition)
  fieldshift(aValues ,nOldPosition,nNewPosition)
  fieldshift(aGetSet,nOldPosition,nNewPosition)

  nNewPosition++

END
unbox(cSortBox)
RETURN nil
//----------------------------------------------------
STATIC FUNCTION fieldshift(aTarget,nOldPosition,nNewPosition)
local expHoldThis := aTarget[nOldPosition]
adel(aTarget,nOldPosition)
ains(aTarget,nNewPosition)
aTarget[nNewPosition] := expHoldThis
RETURN nil

//--------------------------------------------------------------------
static function vpedit(aValues,oTb,aValBlocks,aLookups,aPicts,aFieldTypes,aEditable)
local aOldValues := aclone(aValues)
local oGet,cPict
local nGetEx := GE_DOWN
local expThis
local lSave := .t.
oTb:colpos := 2
//oTb:getcolumn(2):defcolor := {2,2}
oTb:getcolumn(2):colorblock := {||{2,2}}
oTb:refreshall()
@24,18 SAY "¶ F10 para grabar   ESC para cancelar                Ç"
while .t.
  while !oTb:stabilize()
  end
  if aEditable[nElement] .and. !aFieldtypes[nElement]=="M"
     cPict := iif(empty(aPicts[nElement]),"@S30",aPicts[nElement])
     expThis := aValues[nElement]
     oGet := getnew(row(),col(),{|n|expThis:=iif(n#nil,n,expThis)},,cPict)
     if !empty(aLookups[nElement])
       @24,58 say "F2 for Lookup"
     endif
     nGetEx := vpread(oGet,aLookups[nElement],aValBlocks[nElement])
     aValues[nElement] := expThis
     oTb:refreshcurrent()
     if !empty(aLookups[nElement])
       @24,58 say "             "
     endif
  endif
  do case
  case nGetEx = GE_UP .and. nElement == 1
    oTb:gobottom()
  case nGetEx = GE_UP
    oTb:up()
  case nGetEx = GE_DOWN .and. nElement == len(aValues)
    exit
  case nGetEx = GE_DOWN
    oTb:down()
  case nGetEx = GE_ESCAPE
    aValues := aOldValues
    lSave   := .f.
    EXIT
  case nGetEx = GE_WRITE
    EXIT
  endcase
end
//oTb:getcolumn(2):defcolor := {3,3}
oTb:getcolumn(2):colorblock := {||{3,3}}
oTb:gotop()
oTb:refreshall()
@24,18 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
RETURN lSave




//-------------------------------------------------------
static function vpread(get,cLookup,aValidBlock)
local nLastKey,nExitState
get:SetFocus()
get:exitstate := GE_NOEXIT
while ( get:exitState == GE_NOEXIT )
        if ( get:typeOut )
           get:exitState := GE_ENTER
        end
        while ( get:exitState == GE_NOEXIT )
                nLastKey := inkey(0)
                vgetakey(nLastKey,get,cLookup)
        end
        // disallow exit if the VALID condition is not satisfied
        if ( !vpvalid(get,aValidBlock) )
            get:exitState := GE_NOEXIT
        endif
end
nExitState := get:exitstate
get:KillFocus()
return nExitState

#define K_UNDO 21
//-------------------------------------------------------
static proc vgetakey(key,get,cLookup)
local cKey
local bKeyBlock
	do case
    case ( (bKeyBlock := SetKey(key)) <> NIL )
        Eval(bKeyBlock, "VIEWPORT", 0, ReadVar())
    case ispart(key, K_F2 )
        if !empty(cLookup)
          vplookup(cLookup)
        endif
    case ispart(key, K_UP,K_SH_TAB )
        get:exitState := GE_UP
    case ispart(key,K_DOWN,K_TAB,K_ENTER )
        get:exitState := GE_DOWN
	case ( key == K_ESC )
		if ( Set(_SET_ESCAPE) )
          get:undo()
          get:exitState := GE_ESCAPE
		end
    case ISPART(key,K_PGUP,K_PGDN,K_CTRL_W,K_F10,K_CTRL_HOME)
        get:exitState := GE_WRITE
	case (key == K_INS)
		Set( _SET_INSERT, !Set(_SET_INSERT) )
	case (key == K_UNDO)
        get:Undo()
	case (key == K_HOME)
        get:Home()
	case (key == K_END)
        get:End()
	case (key == K_RIGHT)
        get:Right()
	case (key == K_LEFT)
        get:Left()
	case (key == K_CTRL_RIGHT)
        get:WordRight()
	case (key == K_CTRL_LEFT)
        get:WordLeft()
	case (key == K_BS)
        get:BackSpace()
	case (key == K_DEL)
        get:Delete()
	case (key == K_CTRL_T)
        get:DelWordRight()
	case (key == K_CTRL_Y)
        get:DelEnd()
	case (key == K_CTRL_BS)
        get:DelWordLeft()
	otherwise
        if (key >= 32 .and. key <= 255)
           cKey := Chr(key)
           if (get:type == "N" .and. (cKey == "." .or. cKey == ","))
                   get:ToDecPos()
           else
              if ( Set(_SET_INSERT) )
                      get:Insert(cKey)
              else
                      get:Overstrike(cKey)
              endif
              if (get:typeOut .and. !Set(_SET_CONFIRM) )
                 get:exitState := GE_DOWN
              endif
           endif
		end
	endcase
return

*==============================================================
static function vpvalid(get,aValidblock)
local lValid := .t.

if ( get:exitState == GE_ESCAPE )
    return (.t.)                    // NOTE
end
if ( get:BadDate() )
  get:Home()
  return (.f.)                    // NOTE
end
if ( get:changed )
  get:Assign()
end
get:Reset()
if ( aValidBlock <> NIL )
        lValid := Eval(aValidBlock[1], eval(get:block) )
        SetPos( get:row, get:col )
        get:UpdateBuffer()
        if !lValid
          msg(aValidBlock[2])
        endif
end
return (lValid)

static function saverecord(aValues,aGetSet,aEditable,aFieldtypes)
local nOldOrder := INDEXORD()
local i
SET ORDER TO 0
if SREC_LOCK(5,.T.,"Error de red bloqueando registro. ¨Reintenta?")
  for i = 1 TO len(aValues)
    IF aEditable[i] .AND. (!aFieldTypes[i]=="M")
      eval(aGetSet[i],aValues[i])
    ENDIF
  NEXT
  UNLOCK
ELSE
  msg("No se grabaron los cambios - No se pudo bloquear el registro")
ENDIF
SET ORDER TO (nOldOrder)
return nil

//-----------------------------------------------------------------
static function addrecord(aValues,aGetSet,aEditable,aFieldTypes)
IF SADD_REC(5,.T.,"Error de red agregando registro. ¨Reintenta?")
  saverecord(aValues,aGetset,aEditable,aFieldTypes)
ENDIF
return nil

//-----------------------------------------------------------------
static FUNCTION vplookup(cLookup)
local i
local aLook   := array(4)
local nParams := 0
local cChunk

IF !empty(cLookup)
  for i = 1 TO 4
    cChunk  := takeout(cLookup,';',i)
    IF !EMPTY(cChunk)
       aLook[i] := cChunk
   ENDIF
  NEXT
  smalls(aLook[1] ,aLook[2],aLook[3],aLook[4])
ELSE
  msg("No hay b£squedas definidas para este campo..")
ENDIF
RETURN ''




#include "inkey.ch"

FUNCTION editdb(lAddEdit,aInFields,aInFdescr,lBypassAsk)

local nDbSize, nIter
local aFields := {}
local aFdescr := {}
local aSelect, cMemBox,cMemo
local nIndexOrder,cInScreen,nOldCursor
local nCounter,nChoice,cOldColor
local oBrowse, nLkey,cLkey,bOldF10
local cFieldName,cFieldDes, cDeleted
local nrecnoNew,nRecnoOld, cIndexExpr
local bIndexExpr, aView, nLenDesc, nPadding
local nNewCol, aTypes, aLens, cThisType, expGet
local nRow,nCol, cEditScreen,cEditColor
local nFreeze := 0
local getlist := {}
local cEdScreen

local expSeekVar, nLastSeek, lIndexes

* is there a DBF ?
IF !Used()
  RETURN ''
ENDIF

*- save environment ----------------------------------------------
cInscreen  := savescreen(0,0,24,79)
nOldCursor := setcursor(0)

*----- determine index key current----------------------------
cIndexExpr := INDEXKEY(0)
if !empty(cIndexExpr)
  bIndexExpr := &("{||"+cIndexExpr+"}")
endif
lIndexes := !empty(indexkey(1))


*- initialize missing paramaters-------------------------------
lAddEdit   := iif(laddEdit#nil,lAddEdit,.f.)
lByPassAsk := iif(lByPassAsk#nil,lByPassAsk,.f.)
if valtype(aInFields)+valtype(aInFdescr)<>"AA"
  nDbSize   := Fcount()
  aInFields := array(nDbSize)
  aInFdescr := array(nDbSize)
  aFields(aInFields)
  aFields(aInFdescr)
else
  nDbSize := len(aInFdescr)
ENDIF

*--------- determine fields-----------------------------------
selfields(aInFields,aInFdescr,aFields,aFDescr,lByPassAsk)
aTypes := array(len(aFields))
aLens  := array(len(aFields))
fillarr(aFields,aTypes,aLens)


*---------- draw screen----------------------------------------
DISPBEGIN()
cOldColor   := Setcolor(sls_popcol())
@ 0,0 CLEAR TO  24,79
dispbox(0,0,2,79)
dispbox(21,0,24,79)

@ 22,2 SAY "(S)alir    (R)egistro   (U)bicar    (T)rabar  (V)ista Vertical   (C)ampos"
IF lIndexes
  @ 23,2  SAY "(O)rden    (I)ndice     "
  IF lAddEdit
   ??"(E)ditar    (A)gregar  (B)orrar      (D)esborrar "
  ENDIF
ELSEif lAddEdit
   @ 23,2 say "(E)ditar   (A)gregar    (B)orrar    (D)esborrar"
ENDIF
@1,47 SAY  " (F1 para teclas de navegaciขn)"
@0,5  SAY '[Pantalla Mostrar]'
SETCOLOR(sls_normcol())
dispbox(3,0,20,79,"ฺฤฟณูฤภณ ")
DISPEND()

//-----------create tbrowse --------------------------------
oBrowse := maketb(aFields,aFdescr,aTypes)

while .t.
   dispbegin()
   while !oBrowse:stabilize()
   end
   nRow     := ROW()
   nCol     := COL()
   nRecnoOld := recno()

   cfieldName  :=  aFields[oBrowse:colpos]
   cFieldDes   :=  aFdescr[oBrowse:colpos]
   cDeleted    := IIF(DELETED(),"  [Borrado]","           ")
   @1,5 say '[Registro # '+TRANS(RECNO(),'9,999,999,999')+']'+cDeleted ;
                color sls_popcol()
   dispend()

   nLkey := inkey(0)
   cLkey := upper(chr(nLkey))
   do case
   case nLkey == K_DOWN
      oBrowse:down()
   case nLkey == K_PGDN
      oBrowse:pagedown()
   case nLkey == K_UP
      oBrowse:up()
   case nLkey == K_PGUP
      oBrowse:pageup()
   case nLkey == K_CTRL_PGUP
      oBrowse:gotop()
   case nLkey == K_CTRL_PGDN
      oBrowse:gobottom()

   case nLkey == K_LEFT
      oBrowse:left()
   case nLkey == K_RIGHT
      oBrowse:right()
   case nLkey == K_CTRL_RIGHT
      oBrowse:panright()
   case nLkey == K_CTRL_LEFT
      oBrowse:panleft()
   case nLkey == K_HOME
      oBrowse:home()
   case nLkey == K_END
      oBrowse:end()
   case nLkey == K_CTRL_END
      oBrowse:colpos := obrowse:colcount
      oBrowse:refreshall()
   case nLkey == K_CTRL_HOME
      oBrowse:colpos := 1
      oBrowse:refreshall()

   CASE cLkey == "T"
     PopRead(.F.,'Nฃmero de Columnas a Trabar: ',@nFreeze,'9')
     oBrowse:freeze := nFreeze
     oBrowse:refreshall()
   CASE cLkey=="I" .AND. lIndexes
     SPOPSEEK()
     oBrowse:refreshall()
   CASE cLkey=="O" .AND. lIndexes
     SPOPORDER()
     oBrowse:refreshall()
   CASE cLkey=="S" .or. nLkey = K_ESC
     IF messyn(" Salir ")
       EXIT
     ENDIF
   CASE nLkey = K_F1
     db_navig()
   CASE cLkey=="R"
     nRecnoNew = recno()
     popread(.f.,"Ir a Registro Nบ   :",@nRecnoNew,"999999")
     IF nRecnoNew > 0 .AND. nRecnoNew <= RECCOUNT()
       GO nRecnoNew
     ENDIF
     oBrowse:refreshall()
   CASE cLkey=="C"
      selfields(aInFields,aInFdescr,aFields,aFDescr,.f.)
      aTypes := array(len(aFields))
      aLens  := array(len(aFields))
      fillarr(aFields,aTypes,aLens)
      oBrowse := maketb(aFields,aFdescr,aTypes)
      oBrowse:configure()
      oBrowse:refreshall()
   CASE cLkey=="U"
     searchme(aFields,aTypes,aLens)
     oBrowse:refreshall()
   CASE (cLkey=="B" .OR. cLkey=="D") .AND. lAddEdit
     delrec()
     SKIP -1
     SKIP 1
     oBrowse:refreshall()
   CASE cLkey=="E"  .AND. lAddEdit
     cEdScreen := SAVESCREEN(0,0,24,79)
     DISPBOX(0,0,24,79,"         ")
     IF gened(.F.,2,22,aFields,aFdescr)
       oBrowse:refreshall()
     ENDIF
     RESTSCREEN(0,0,24,79,cEdScreen)
   CASE cLkey=="V"
     aView := aclone(aFdescr)
     FOR nCounter = 1 TO len(aFields)
       cFieldname := aFields[nCounter]
       cThisType  := aTypes[nCounter]
       nLenDesc   := LEN(aFdescr[nCounter])
       nPadding   := 15-nLenDesc

       *- complete the array element with the current value
       DO CASE
       CASE !isfield(cFieldName)
         aView[nCounter] += SPACE(nPadding)+TRANS(eval(getexpb(cFieldName)),"")
       CASE cThisType == "C"
         aView[nCounter] +=SPACE(nPadding)+LTRIM( eval(getwb(cfieldname)) )
       CASE cThisType == "D"
         aView[nCounter] +=SPACE(nPadding)+DTOC( eval(getwb(cfieldname)) )
       CASE cThisType == "N"
         aView[nCounter] +=SPACE(nPadding)+LTRIM(STR( eval(getwb(cfieldname)) ))
       CASE cThisType == "L"
         aView[nCounter] +=SPACE(nPadding)+IIF(eval(getwb(cfieldname)),'True','False')
       ENDCASE

     NEXT
     *- achoice it - view only
     nNewCol = mchoice(aView,5,10,20,75)
     IF nNewCol > 0
       oBrowse:colpos := nNewCol
       oBrowse:refreshall()
     ENDIF
   CASE nLkey = 13 .AND.;
       aTypes[oBrowse:colpos] = "M" .AND. lAddEdit
     if SREC_LOCK(5,.T.,"Error de red - No se puede bloquear registro จReintenta?")
        SET CURSOR ON
        cMemo := Editmemov(fieldget(fieldpos(cfieldname)),4,1,19,78,.T.)
        fieldput(fieldpos(cfieldname),cMemo)
        UNLOCK
        goto recno()
     ENDIF
     UNLOCK
     SET CURSOR OFF
     oBrowse:refreshall()

   CASE nLkey = 13 .AND.;
       aTypes[oBrowse:colpos] == "M" .AND. !lAddEdit

       Editmemov(fieldget(fieldpos(cfieldname)),4,1,19,78,.f.)


   CASE cLkey=="A" .AND. lAddEdit      // add
     SET CURSOR ON
     cEdScreen := SAVESCREEN(0,0,24,79)
     DISPBOX(0,0,24,79,"ฑฑฑฑฑฑฑฑฑ")
     IF gened(.T.,2,22,aFields,aFdescr)
       oBrowse:refreshall()
     else
       go (nRecnoOld)
     ENDIF
     RESTSCREEN(0,0,24,79,cEdScreen)


   CASE nLkey = 13  .AND. lAddEdit .AND. isfield(cFieldName) .AND. ;
                          isthisarea(cFieldName)     // edit field
     if SREC_LOCK(5,.T.,"Network error - Unable to lock record. Keep trying?")
        SET CURSOR ON

        expGet   := fieldget(fieldpos(cfieldname))
        cEditColor := Setcolor(sls_popcol())
        cEditScreen := savescreen(0,0,24,79)

        v_editd(nRow)

        *- get the temp var
        @ nRow,nCol GET expGet PICTURE ed_g_pic(cfieldName)
        READ

        *- restore things
        Setcolor(cEditColor)
        RESTSCREEN(0,0,24,79,cEditScreen)

        IF lastkey() <> 27 .AND. updated()
            *- changes made, not ESCAPE, replace field with new value
            fieldput(fieldpos(cfieldname),expGet)
            UNLOCK
            goto recno()
        ENDIF
        SET CURSOR OFF
        oBrowse:refreshall()
     endif
     UNLOCK
   CASE nLkey = 13  .AND. lAddEdit
     msg("Este campo no es EDITAble")
   endcase

End
* restore environment
setcursor(nOldCursor)
RESTSCREEN(0,0,24,79,cInScreen)
Setcolor(cOldColor)
return ''

//=================================================================
static FUNCTION v_editd(nRow)
IF nRow >=10
  dispbox(5,28,7,62,sls_frame())
  @6,29 SAY "Enter para Grabar - Escape para Cancelar"
ELSE
  dispbox(12,28,14,62,sls_frame())
  @13,29 SAY "Enter para Grabar - Escape para Cancelar"
ENDIF
RETURN ''

//=================================================================
STATIC FUNCTION db_navig
LOCAL cNavBox
cNavBox = makebox(4,4,23,70,sls_popcol())

@5,5 SAY " ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ"
@6,5 SAY " Tecla                        Efecto"
@7,5 SAY " ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ"
@8,5 SAY  " Flecha Arriba                Mueve un renglขn hacia arriba."
@9,5 SAY  " Flecha Abajo                 Mueve un renglขn hacia abajo."
@10,5 SAY " Flecha Izquierda             Mueve una columna a la izq."
@11,5 SAY " Flecha Derecha               Mueve una columna a la der."
@12,5 SAY " Ctrl Flecha Izquierda        Una pantalla a la izquierda."
@13,5 SAY " Ctrl Flecha Derecha          Una pantalla a la derecha."
@14,5 SAY " Home                         Columna izquierda de la pant."
@15,5 SAY " End                          Columna derecha de la pant."
@16,5 SAY " Ctrl-Home                    Columna extrema izquierda."
@17,5 SAY " Ctrl-End                     Columna extrema derecha."
@18,5 SAY " PgUp                         Pantalla siguiente de arriba."
@19,5 SAY " PgDn                         Pantalla siguiente de abajo."
@20,5 SAY " Ctrl-PgUp                    Primer renglขn de la columna."
@21,5 SAY " Ctrl-PgDn                    Ultimo renglขn de la columna."
@22,5 SAY " ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ"
INKEY(5)
unbox(cNavBox)
RETURN ''

//=================================================================
static function dskip(n)
  local skipcount := 0
  do case
  case n > 0
    do while !eof().and. skipcount < n
      dbskip(1)
      if !eof()
        skipcount++
      endif
    enddo
  case n < 0
    do while !bof() .and. skipcount > n
      dbskip(-1)
      if !bof()
        skipcount--
      endif
    enddo
  endcase
  if eof()
    dbgobottom()
  elseif bof()
    dbgotop()
  endif
return skipcount

static function getexpb(combo)
local bBlock
bBlock := &("{||"+combo+"}")
return bBlock

static function getwb(combo)
local workarea
if "->"$combo
  workarea := select( getalias(combo) )
else
  workarea := select()
endif
return fieldwblock(getfield(combo),workarea)

//-------------------------------------------------------------------------
static function getalias(combo)
if "->"$combo
  return left(combo,at("-",combo)-1)
else
  return alias()
endif
return ''

//-------------------------------------------------------------------------
static function getfield(combo)
if "->"$combo
  return subst(combo,at(">",combo)+1)
else
  return combo
endif
return ''

//-------------------------------------------------------------------------
static function selfields(aInFields,aInFdescr,aFields,aFDescr,lBypassAsk)
local aSelect
local i
IF !lByPassAsk .and. ;
     !messyn("Selecciขn de Campos:","Mostrar todos los campos","Elegir campos") .and. lastkey()#27
  aSelect := tagarray(aInFdescr,"Marcar Campos para mostrar")
  if len(aSelect) > 0
    asize(aFields,len(aSelect))
    asize(aFdescr,len(aSelect))
    for i = 1 to len(aSelect)
      aFields[i] := aInFields[aSelect[i]]
      aFDescr[i] := aInFdescr[aSelect[i]]
    next
  else
   aSize(aFields,len(aInFields))
   aSize(aFDescr,len(aInFdescr))
   acopy(aInFields,aFields)
   acopy(aInFdescr,aFdescr)
  endif
ELSE
   aSize(aFields,len(aInFields))
   aSize(aFDescr,len(aInFdescr))
   acopy(aInFields,aFields)
   acopy(aInFdescr,aFdescr)
ENDIF
return nil

//------------------------------------------------------------
static function maketb(aFields,aFdescr,aTypes)
local nIter, cFieldName
local oBrowse := tbrowseNew(4,1,19,78)
for nIter = 1 to len(aFields)
   if aTypes[nIter]=="M"
    cFieldName := aFields[nIter]
    oBrowse:addColumn(TBColumnNew( aFdescr[nIter],{||"(memo)"}  ) )
   elseif isfield(aFields[nIter])
    oBrowse:addcolumn(TBColumnNew( aFdescr[nIter],getwb(aFields[nIter])))
   else
    oBrowse:addcolumn(TBColumnNew( aFdescr[nIter],getexpb(aFields[nIter])))
   endif
next
oBrowse:gobottomblock := {||dbgobottom()}
oBrowse:gotopblock := {||dbgotop()}
oBrowse:skipblock := {|n|dskip(n)}
oBrowse:headsep := "ฤ"
oBrowse:colsep := "ณ"
//oBrowse:freeze := nFreeze
return oBrowse


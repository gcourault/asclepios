#include "inkey.ch"
#define GOINGDOWN 1
#define GOINGUP   2
#define MAXTAG    1000
FUNCTION tagit(aTagged, aFields, aFieldNames, cTitle)

local cTagScreen, nIterator
local oTagTbrowse, nFoundTagged, nLastkey
local nTaggedRecords     := 0
local nOldCursor  := SETCURSOR(0)
local nIndexOrder := INDEXORD()
local nDirection  := GOINGDOWN
local nOnRecord, cLastkey
local bSearch, nThisRec
local nCount, nScanned, bTag, bDisplay

*- look for the array aTagged[]
IF VALTYPE(aTagged)# "A"
  aTagged := {}
ENDIF
aPack(aTagged)
nTaggedRecords := LEN(aTagged)

*- build the field arrays if needed
IF !VALTYPE(aFields)=="A"
  aFields := array(fcount())
  aFieldNames:= array(fcount())
  Afields(aFields)
  Afields(aFieldNames)
ENDIF


*- draw the box
cTagScreen=makebox(4,5,22,75,sls_popcol())
IF cTitle#nil
  @4,6 SAY '['+cTitle+']'
ENDIF
@6,6 TO 6,74
@5,10 SAY CHR(24)+' '+CHR(25)+' '+CHR(26)+' '+CHR(27)+'  ESPACIO = marca  L = limpia  B = busca  ESC = salir'
*@22,6 say '[F1 Help]'
@20,6 TO 20,74

*- build the tbrowse object
oTagTbrowse := tbrowsedb(7,6,19,74)
oTagTbrowse:colsep := "³"
oTagTbrowse:headsep := chr(196)

*- add the tbcolumns
oTagTbrowse:addcolumn(TBColumnNew('Marca',{||iif(is_it_tag(recno(),aTagged) ,'û',' ')} ))
oTagTbrowse:getcolumn(1):headsep := chr(196)
for nIterator := 1 to len(aFields)
   if isfield(aFields[nIterator])
    oTagTBrowse:addcolumn(TBColumnNew( aFieldNames[nIterator],getwb(aFields[nIterator])))
   else
    oTagTBrowse:addcolumn(TBColumnNew( aFieldNames[nIterator],getexpb(aFields[nIterator])))
   endif
next

oTagTbrowse:freeze  := 1

do while .t.
   while !oTagTbrowse:stabilize()
   end
   @21,6 say padc( alltrim(str(nTaggedRecords))+" registros marcados",68 )

   nLastkey := inkey(0)
   cLastkey := upper(chr(nLastkey))

   DO CASE
   case nLastkey = K_UP          && up one row
     oTagTbrowse:up()
     nDirection := GOINGUP
   case nLastkey = K_PGUP        && up one page
     oTagTbrowse:pageUp()
     nDirection := GOINGUP
   case nLastkey = K_HOME        && home
     oTagTbrowse:gotop()
     nDirection := GOINGDOWN
   case nLastkey = K_DOWN        && down one row
     oTagTbrowse:down()
     nDirection := GOINGDOWN
   case nLastkey = K_PGDN        && down one page
     oTagTbrowse:pageDown()
     nDirection := GOINGDOWN
   case nLastkey = K_END         && end
     oTagTbrowse:gobottom()
     nDirection := GOINGUP
   case nLastkey == K_LEFT       && left
     oTagTbrowse:left()
   case nLastkey == K_RIGHT      && right
     oTagTbrowse:right()
   CASE nLastkey = 32  // space
     *- look for record # in array
     nFoundTagged = Ascan(aTagged,recno())

     *- if there, remove it, else add it
     *- immediately say the results
     IF nFoundTagged > 0
       Adel(aTagged,nFoundTagged)
       nTaggedRecords--
       asize(aTagged,nTaggedRecords)
     ELSE
       nTaggedRecords++
       asize(aTagged,nTaggedRecords)
       AINS(aTagged,1)
       aTagged[1] := recno()
     ENDIF
     oTagTbrowse:refreshcurrent()
     IF nDirection == GOINGUP
        oTagTbrowse:up()
     ELSE
        oTagTbrowse:down()
     ENDIF
   CASE cLastkey == "B"
     SET ORDER TO 0
     SKIP 0
     bSearch := searchme()
     if bSearch#nil .and. found()
       nThisRec := recno()
       if messyn("¨Marca todos los encontrados?")
         amsg({"Se marcar  un m ximo de",MAXTAG})
         dbgotop()
         nCount   := 0
         nScanned := 0
         bTag := {||IIF(nTaggedRecords< MAXTAG .AND. Ascan(aTagged,recno())==0 ,;
                 (nCount++,nTaggedRecords++,asize(aTagged,nTaggedRecords),;
                 AINS(aTagged,1),aTagged[1]:=recno()),nil)}
         bDisplay := {||alltrim(str(nCount))+" tagged of "+;
                        alltrim(str(nScanned++))+" scanned"}
         ProgEval(bTag,bSearch,"Tagging Matches",bDisplay,.t.)
       endif
       dbgoto(nThisRec)
     endif
     SET ORDER TO nIndexOrder
     oTagTbrowse:refreshall()
   CASE nLastkey = 27
     exit
   CASE cLastkey == "L"
     asize(aTagged,0)
     nTaggedRecords  := 0
     oTagTbrowse:refreshall()
   ENDCASE
enddo
SETCURSOR(nOldCursor)
UNBOX(cTagScreen)
RETURN aTagged



static FUNCTION is_it_tag(nRecnum,aTagged)
RETURN (Ascan(aTagged,nRecnum)> 0)


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


static function getalias(combo)
if "->"$combo
  return left(combo,at("-",combo)-1)
else
  return alias()
endif
return ''

static function getfield(combo)
if "->"$combo
  return subst(combo,at(">",combo)+1)
else
  return combo
endif
return ''

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

static function apack(aIn)
local nStartlen := len(aIn)
local i
for i = 1 to len(aIn)
  if empty(aIn[i])
    asize(aIn,i-1)
    exit
  endif
next
return nil




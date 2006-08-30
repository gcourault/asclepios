#include "inkey.ch"
FUNCTION Fileread( nBoxTop,nBoxLeft,nBoxBot,nBoxRight,cFileName,cTitle,lSearch,lMark )

local nLastKey,nCursor
local cReadBox
local nTopLine,nBottLine,nLeftEdge,nRightEdge,nLineLen
local nLineOffset,nFileOffset
local nHandle,oTb
local cSeek := ""
local lMarking   := .f.
local nMarkStart := 0, nMarkEnd := 0
local lMarked    := .f.
local lMarkOrSeach
local nTbottom

lSearch := iif(lSearch#nil,lSearch,.t.)
lMark := iif(lMark#nil,lMark,.t.)
lMarkOrSearch := (lSearch .or. lMark)

*- if FileName not passed, get one
IF cFileName==nil .or. "*"$cFilename
  if cFileName==nil
    cFileName := SPACE(40)
    popread(.t.,"Archivo a Listar (ENTER o *Asterisco para elegir - ESC para salir)",@cFileName,"")
  endif
  IF LASTKEY() = 27
    RETURN .F.
  ENDIF
  IF EMPTY(cFileName) .OR. AT('*',cFileName) > 0
    IF EMPTY(cFileName)
      cFileName := getdfp()+"*.*"
    ELSE
     if !("\"$cFileName .or. ":"$cFileName)
        cFileName := getdfp()+cFileName
     endif
    ENDIF
    if adir(cFileName) > 0
      cFileName := popex(cFileName)
    endif
  ENDIF
  IF LASTKEY() = 27
    RETURN .F.
  ENDIF
else
  if !("\"$cFileName .or. ":"$cFileName)
     cFileName := getdfp()+cFileName
  endif
ENDIF

*- assign box dimensions if need be
IF nBoxTop==nil
  nBoxTop   := 2
  nBoxLeft  := 2
  nBoxBot   := 22
  nBoxRight := 78
ENDIF

*- check for file's existence
IF empty(cFileName) .or. !FILE(cFileName)
  RETURN .F.
ENDIF
cTitle := iif(cTitle#nil,cTitle,cFileName)
*- open the file, check for errors
nHandle := FOPEN(cFileName,64)
IF Ferror() <> 0
  msg("Error abriendo archivo : "+cFileName)
  RETURN ''
ENDIF

*- set cursor off
nCursor  := setcursor(0)


*- draw screen
cReadBox :=makebox(nBoxTop,nBoxLeft,nBoxBot,nBoxRight,sls_popcol(),0,0)
nTbottom := iif(lMarkOrSearch,3,2)
@nBoxBot-nTbottom,nBoxLeft TO nBoxBot-nTBottom,nBoxRight
@nBoxBot-nTBottom,nBoxLeft SAY CHR(195)
@nBoxBot-nTBottom,nBoxRight SAY CHR(180)

@nBoxTop,nBoxLeft+2 SAY '['+cTitle+']'
@nBoxBot-(nTBottom)+1,nBoxLeft+1 SAY PADC(CHR(24)+CHR(25)+CHR(26)+CHR(27)+" PGUP PGDN HOME END    ESC=Quit ",;
             SBCOLS(nBoxLeft,nboxRight,.f.))
if lMarkOrSearch
  @nBoxbot-1,nBoxLeft+1 say ;
        PADC(iif(lSearch," B=Busca   ","")+iif(lMark,"M=Marca/Desmarca",""),;
        SBCOLS(nBoxLeft,nboxRight,.f.) )
endif
*-

*- initialize dimensions for screen output of file
nTopLine   := nBoxTop+1
nBottLine  := nBoxBot-(nTBottom)-1
nLeftEdge  := nBoxLeft+1
nRightEdge := nBoxRight-1

*- get line length, number of lines in box, and starting line offset
nLineLen    := nBoxRight-nBoxLeft-1
nLineOffset := 1

oTb := tbrowsenew(ntopLine,nLeftEdge,nBottLine,nRightEdge)
oTb:addcolumn(tbcolumnnew("",{||padr(subst(sfreadline(nHandle),nLineOffset),nLineLen)} ))
oTb:skipblock     := {|n|tskip(n,nHandle)}
oTb:gotopblock    := {||ftop(nHandle)}
oTb:gobottomblock := {||fbot(nHandle)}
oTb:getcolumn(1):colorblock := {||iif(Marked(nMarkStart,nMarkEnd,lMarking,nHandle),{2,2},{1,2})}

while .t.
  DISPBEGIN()
  if lMarking
     @nBoxBot-1,nBoxLeft+1 SAY "Marking..." color "*"+setcolor()
  else
     @nBoxBot-1,nBoxLeft+1 SAY space(10)
  endif
  while !oTb:stabilize()
  end
  DISPEND()
  nFileOffset := fseek(nHandle,0,1)
  if lMarking
     if nFileOffset#nMarkEnd
       nMarkEnd   := nFileOffset
       if nMarkEnd < nMarkStart
         lMarking := .f.
       endif
       oTb:refreshall()
       DISPBEGIN()
       while !oTb:stabilize()
       end
       DISPEND()
     endif
  endif
  nLastKey := inkey(0)
  do case
  case nLastKey == K_UP
    oTb:UP()
  case nLastKey == K_DOWN
    oTb:down()
  case nLastKey == K_PGUP
    oTb:PAGEUP()
  case nLastKey == K_PGDN
    oTb:PAGEdown()
  case nLastKey == K_HOME
    oTb:gotop()
  case nLastKey == K_END
    oTb:gobottom()
  case nLastKey == K_LEFT .and. nLineOffset > 5
    nLineOffset-=5
    oTb:refreshall()
  case nLastKey == K_LEFT .and. nLineOffset > 1
    nLineOffset:=1
    oTb:refreshall()
  case nLastKey == K_RIGHT
    nLineOffset+=5
    oTb:refreshall()
  case nLastkey == K_ESC
    if lMarking
      lMarking := .f.
      oTb:refreshall()
      DISPBEGIN()
      while !oTb:stabilize()
      end
      DISPEND()
    else
      exit
    endif
  case upper(chr(nLastKey))=="M" .AND. lMark
   if !lMarking
     lMarking := .t.
     nMarkStart := nFileOffset
     nMarkEnd   := nFileOffset
   else
     lMarking := .f.
     docopy(nMarkStart,nMarkEnd,cFileName,nHandle)
     fseek(nHandle,0,nFileOffset)
     nMarkStart := 0
     nMarkEnd   := 0
     oTb:refreshall()
   endif

  case upper(chr(nLastKey))=="B" .and. lSearch
    cSeek := padr(cSeek,30)
    popread(.t.,"Texto a Buscar:",@cSeek,"@K")
    if !empty(cSeek)
      cSeek := trim(cSeek)
      if frseek(nHandle,cSeek)
        oTb:refreshall()
      else
        msg("No encontrado")
        fseek(nHandle,nFileOffset,0)
      endif
    endif
  endcase
end
*- set cursor on
fclose(nHandle)
setcursor(nCursor)
unbox(cReadBox)
RETURN ''

*=======================================================
static FUNCTION fbot(nHandle)
FSEEK(nHandle,0,2)
RETURN ''

*=======================================================
static FUNCTION ftop(nHandle)
FSEEK(nHandle,0)
RETURN ''

//--------------------------------------------------------------
static function tskip(n,nHandle)
local nMoved   := 0
if n > 0
  while nMoved < n
    if fmove2next(nHandle)
      nMoved++
    else
      exit
    endif
  end
elseif n < 0
  while nMoved > n
    if fmove2prev(nHandle)
      nMoved--
    else
      exit
    endif
  end
endif
return nMoved

//-------------------------------------------------------------
static function frseek(nHandle,cSeek)
local lFound := .f.
local cuSeek := upper(cSeek)
while fmove2next(nHandle)
  if cuSeek$upper(sfreadline(nHandle))
   lFound := .t.
   exit
  endif
end
return lFound

//-------------------------------------------------------------
static function Marked(nMarkStart,nMarkEnd,lMarking,nHandle)
local lMarked := .f.
local nOffset
if lMarking
  nOffset := fseek(nHandle,0,1)
  if nOffset >= nMarkStart .and. nOffset <= nMarkEnd
     lMarked := .t.
  endif
endif
return lMarked

//-------------------------------------------------------------
static function docopy(nMarkStart,nMarkEnd,cInFile,nHandle)
local nDevice
local cFileName := space(30)
local cPrinter
local cMessage  := ""
local nAppend
if nMarkStart <= nMarkEnd
  while .t.
    cFileName := space(30)
    nDevice := menu_v("Salida de lo marcado a","Impresora","Archivo","Cancelar")
    do case
    case nDevice == 1 // printer
      cPrinter  := PRNPORT()
      toprint(cPrinter,nMarkStart,nMarkEnd,nHandle)
    case nDevice == 2 // file
      popread(.t.,"File Name",@cFileName,"@K")
      cFileName := upper(trim(cFileName))
      cInfile   := upper(cInFile)
      if !ISVALFILE(cFileName,.f.,@cMessage)
           msg("Nombre de archivo no v lido",cMessage)
      elseif cFileName==cInFile
           msg("No se puede escribir a este archivo")
      elseif file(cFileName)
           nAppend := menu_v("El archivo existe","Sobreescribe","Agregar","Cancelar")
           do case
           case nAppend==1
             tofile(cFileName,.f.,nMarkStart,nMarkEnd,nHandle)
           case nAppend==2
             tofile(cFileName,.t.,nMarkStart,nMarkEnd,nHandle)
           endcase
      else
           tofile(cFileName,.f.,nMarkStart,nMarkEnd,nHandle)
      endif
    otherwise
      exit
    endcase
  end
endif
return nil

//-------------------------------------------------------------
static function toprint(cPrinter,nMarkStart,nMarkEnd,nHandle)
local nLpp   := 60
local nLines := 0
popread(.t.,"L¡neas por p gina:",@nLpp,"99")
SET PRINTER TO (cPrinter)
fseek(nHandle,nMarkStart,0)
SET PRINTER ON
while fseek(nHandle,0,1) < nMarkEnd
   SET CONSOLE OFF
   if p_ready(cPrinter)
     ?sfreadline(nHandle)
     nLines++
   else
     exit
   endif
   if nLines >= nLpp
     EJECT
     nLines := 0
   endif
   fmove2next(nHandle)
   SET CONSOLE ON
end
EJECT
set printer to
SET PRINTER OFF
SET CONSOLE ON
MSG("L¡neas Marcadas Escritas")
RETURN NIL

//-------------------------------------------------------------
static function tofile(cFileName,lAppend,nMarkStart,nMarkEnd,nHandle)
if lAppend
  SET PRINTER TO  (cFileName) ADDITIVE
else
  SET PRINTER TO (cFileName)
ENDIF
fseek(nHandle,nMarkStart,0)

SET PRINTER ON
while fseek(nHandle,0,1) < nMarkEnd
   SET CONSOLE OFF
   ?sfreadline(nHandle)
   fmove2next(nHandle)
   SET CONSOLE ON
end
set printer to
SET PRINTER OFF
MSG("L¡neas Marcadas Escritas")
RETURN NIL


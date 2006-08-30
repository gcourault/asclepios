

#include "directry.ch"
#include "inkey.ch"

memvar getlist

FUNCTION fulldir(lChange,cDirName)
local cToDir,nOldArea
local cDirBox,nOldCursor

nOldArea = SELECT()
SELECT 0

*****
nOldCursor = setcursor(1)

IF VALTYPE(lChange)<>"L"
  lChange = .t.
ENDIF


*- draw the box
*- get the directory to change to
cDirBox=makebox(10,10,15,70,SLS_POPCOL())
cToDir = SPACE(50)
@11,12 SAY "Directorio al cual cambiar :"
@12,12 GET cToDir
@14,12 SAY "(Enter para caja de selecci¢n  -   Escape para cancelar)"
READ
unbox(cDirBox)

*- if escape - get outa here
IF LASTKEY() = 27
  *- set cursor on
  SET CURSOR ON
  SELECT (nOldArea)
  RETURN .F.
ENDIF

*- if left blank, user wants a choice
IF EMPTY(cToDir)
  cToDir = TRIM(floater())
  IF !cToDir == "\"
    cToDir = LEFT(cToDir,LEN(cToDir)-1)
  ENDIF
ENDIF

*- so where are we going
cToDir = Alltrim(cToDir)

*- if its not empty
IF !EMPTY(cToDir) .AND. lChange
  *- double check if that's what the user wants
  IF messyn("Change directory to: "+cToDir)
    *- attempt to change
    IF !cdir(cToDir)
      *- if unsuccesful - notify user
      msg("No se puede cambiar a "+cToDir)
      cToDir := ""
    ENDIF
  ELSE
    cToDir := ""
  ENDIF
ENDIF
cDirName := cToDir          // PASSED BY REFERENCE
SETCURSOR(nOldCursor)
SELECT (nOldArea)
RETURN !empty(cToDir)




STATIC FUNCTION floater

local aDirectory
// this is to handle Funcky's funky curdir()
local cCurrdir  := iif(":\"$curdir(),subst(curdir(),at(":\",curdir())+2),curdir())
local cFullPath := iif(empty(cCurrDir),"\","\"+cCurrDir+"\")
local nElement := 1
local nLastkey,cLastkey,nFound
local cBox     := makebox(2,2,23,78,SLS_NORMCOL())
local oDir     := tbrowseNew(3,3,19,77)
@20,3 to 20,77

oDir:addcolumn(tbColumnNew("Archivo",{||padr(aDirectory[nElement,1],13)}  ))
oDir:addcolumn(tbColumnNew("",{||iif("D"$aDirectory[nElement,5],"<DIR>","     ")}  ))
oDir:addcolumn(tbColumnNew("Tama¤o",{||iif("D"$aDirectory[nElement,5],space(10),padl(aDirectory[nElement,2],10))}  ))
oDir:addcolumn(tbColumnNew("Fecha",{||aDirectory[nElement,3]}  ))
oDir:addcolumn(tbColumnNew("Hora",{||aDirectory[nElement,4]}  ))
oDir:SKIPBLOCK := {|n|AASKIP(n,@nElement,LEN(aDirectory))}
oDir:gobottomblock := {||nElement := len(aDirectory)}
oDir:gotopblock    := {||nElement := 1}
oDir:headsep       := chr(196)
oDir:colorspec := sls_popmenu()

aDirectory := directory(cFullPath+"*.*","D")


@22,3 SAY padc("[ENTER para seleccionar | F10 para aceptar | Escape para salir | Alt-V para ver archivo]",75)
while .t.
  @21,3 say padc("DIRECTORIO:"+cFullPath,75) color sls_normcol()
  while !oDir:stabilize()
  end
  nLastKey := INKEY(0)
  cLastKey := upper(chr(nLastkey))
  do case
  CASE nLastKey = K_UP          && UP ONE ROW
    oDir:UP()
  CASE nLastKey = K_PGUP        && UP ONE PAGE
    oDir:PAGEUP()
  CASE nLastKey = K_LEFT        && UP ONE ROW
    oDir:left()
  CASE nLastKey = K_RIGHT       && UP ONE PAGE
    oDir:right()
  CASE nLastKey = K_HOME        && HOME
    oDir:GOTOP()
  CASE nLastKey = K_DOWN        && DOWN ONE ROW
    oDir:DOWN()
  CASE nLastKey = K_PGDN        && DOWN ONE PAGE
    oDir:PAGEdOWN()
  CASE nLastKey = K_END         && END
    oDir:GOBOTTOM()
  case cLastKey$"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    nFound := ASCAN(aDirectory,{|e|LEFT(e[1],1)==cLastKey},nElement+1)
    if nFound==0 .and. nElement > 1
      nFound := ASCAN(aDirectory,{|e|LEFT(e[1],1)==cLastKey})
    endif
    if nFound > 0
      bgoto(nFound,nElement,oDir)
    endif
  case nLastkey == K_ENTER
    if "D"$aDirectory[nElement,5]
      do case
      case aDirectory[nElement,1]=="."   // this - do nothing
         if multimsgyn({"Change to ",cFullPath})
           exit
         endif
      case aDirectory[nElement,1]==".."  // prior
         cFullPath := priordir(cFullPath)
         aDirectory := directory(cFullPath+"*.*","D")
         oDir:rowpos := 1
         nElement    := 1
         oDir:refreshall()
      otherwise
         cFullPath += aDirectory[nElement,1]+"\"
         aDirectory := directory(cFullPath+"*.*","D")
         oDir:rowpos := 1
         nElement    := 1
         oDir:refreshall()
      endcase
    else
    endif
  case nLastkey == K_ESC
    cFullPath := ""
    EXIT
  case nLastkey == K_F10
    EXIT
  case nLastkey == K_ALT_V    // view
*    viewit(cFullpath+"\"+aDirectory[nElement,1] )
    viewit(cFullpath+aDirectory[nElement,1] )
  endcase
end
unbox(cBox)
return cFullPath



static function priordir(cCurrent)
cCurrent := left(cCurrent,len(cCurrent)-1)
return left(cCurrent,rat("\",cCurrent))

//===============================================================
static function bgoto(nNew,nCurrent,oStruc)
local nIter
local nDiff := ABS(nNew-nCurrent)
if nNew > nCurrent
  for nIter := 1 to nDiff
    oStruc:down()
    while !oStruc:stabilize()
    end
  next
else
  for nIter := 1 to nDiff
    oStruc:up()
    while !oStruc:stabilize()
    end
  next
endif
return nil

static function viewit(cFileName)
local cBox
IF ('.DBF' $ cFileName)
  *- check for arbitrary amount of available memory
  *- change this higher or lower, based on your own best guess <g>
  IF MEMORY(0) > 20
    IF SELECT( strip_path(cFilename,.t.) ) > 0  // check for already open
        msg("Este archivo ya est  en uso, no puede ser reabierto")
    ELSEIF SNET_USE(cFileName,"ADBF",.f.,5,.t.,"No se puede abrir el archivo. ¨Reintenta?")
        cBox = makebox(2,2,23,78)
        dbedit(3,3,22,77)
        USE
        unbox(cBox)
    endif
  ELSE
    MSG("Memoria insuficiente para abrir el archivo")
  ENDIF
ELSEIF ('.NTX' $ cFileName) .OR. ('.NDX' $ cFileName)
  msg("La clave del ¡ndice de "+cFileName+" es :",nkey(cFileName))
ELSEIF !(('.EXE' $ cFileName) .OR. ('.COM' $ cFileName).OR.('.SYS' $ cFileName)  )
  Fileread(2,2,23,78,cFileName)
ENDIF
RETURN nil



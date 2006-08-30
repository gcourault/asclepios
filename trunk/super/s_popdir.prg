
#include "inkey.ch"
FUNCTION POPUPDIR(cSpec,cAttributes,cTitle,cColor,lAllowView)
local aDirectory := DIRECTORY((cSpec:=IIF(cSpec#nil,cSpec,"*.*")),cAttributes)
local nElement := 1
local nLastkey
local cBox
local oDir
local cFile := ""
local cPath := iif("\"$cSpec,SUBST(cSpec,1,RAT("\",cSpec)),"")

if len(aDirectory) > 0
   dispbegin()
   cTitle := iif(cTitle#nil,cTitle,"Directory Viewer")
   cColor := iif(cColor#nil,cColor,SLS_NORMCOL())
   lAllowView := iif(lAllowView#nil,lAllowView,.f.)
   cBox := makebox(2,2,23,78,cColor)
   oDir := tbrowseNew(3,3,19,77)
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
//   oDir:colorspec := sls_popmenu()

   @2,3 say cTitle
   @22,3 SAY padc("[Enter para seleccionar | Escape para cancelar "+;
                  iif(lAllowView,"| Alt-V para ver archivo]","]"),75)
   dispend()
   while .t.
     @21,3 say padc("DIRECTORIO:"+cSpec,75) color cColor
     while !oDir:stabilize()
     end
     nLastKey := INKEY(0)
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
     case nLastkey == K_ENTER
       cFile := aDirectory[nElement,1]
       exit
     case nLastkey == K_ESC
       EXIT
     case nLastkey == K_ALT_V  .and. lAllowView  // view
       viewit(cPath+aDirectory[nElement,1] )
     endcase
   end
   unbox(cBox)
endif
return cFile
//--------------------------------------------------------------
static function viewit(cFileName)
local cBox
local nSelect := SELECT()
select 0
IF ('.DBF' $ cFileName)
  *- check for arbitrary amount of available memory
  *- change this higher or lower, based on your own best guess <g>
  IF MEMORY(0) > 20
    IF SELECT( strip_path(cFilename,.t.) ) > 0  // check for already open
        msg("Este archivo ya est  en uso, no se puede reabrir")
    elseIF SNET_USE(cFileName,"ADBF",.f.,5,.t.,"No se puede abrir el archivo. ¨Reintenta?")
        cBox := makebox(2,2,23,78)
        dbedit(3,3,22,77)
        USE
        unbox(cBox)
    endif
  ELSE
    MSG("No hay memoria para leer el archivo")
  ENDIF
ELSEIF ('.NTX' $ cFileName) .OR. ('.NDX' $ cFileName)
  msg("La clave del ¡ndice para "+cFileName+" es :",nkey(cFileName))
ELSEIF !(('.EXE' $ cFileName) .OR. ('.COM' $ cFileName).OR.('.SYS' $ cFileName)  )
  Fileread(2,2,23,78,cFileName)
ENDIF
SELECT (nSelect)
RETURN nil


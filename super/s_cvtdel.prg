#include "inkey.ch"

//-----------------------------------------------------------------------
function sconvdelim()
local cCharDelim  := ["]  // double quot
local cFieldDelim := [,]  // comma
local i
LOCAL nOldCursor     := setcursor(0)
LOCAL cInScreen      := Savescreen(0,0,24,79)
LOCAL cOldColor      := Setcolor(sls_normcol())
local nMenuChoice
local cInFile        := ""
local aNames       := {}
local aTypes       := {}
local aLens        := {}
local aDeci        := {}

*- draw boxes
@0,0,24,79 BOX sls_frame()
Setcolor(sls_popcol())
@1,1,12,40 BOX sls_frame()
@1,5 SAY '[Converir a DBF desde DELIMITADA]'
@20,1,23,78 BOX sls_frame()

DO WHILE .T.
  Setcolor(sls_popmenu())
  @03,3 PROMPT "Seleccionar archivo DELIMITADO "+padr(cInFile,12)
  @04,3 PROMPT "Definir campos del archivo DELIMITADO "
  @05,3 PROMPT "Escribir archivo DBF desde archivo DELIMITADO"
  @08,3 PROMPT "Salir"

  MENU TO nMenuChoice
  Setcolor(sls_popcol())

  DO CASE
  CASE nMenuChoice = 0 .or. nMenuChoice = 4
      exit
  CASE nMenuChoice = 1
      cInfile := pickfile()
      aNames       := {}
      aTypes       := {}
      aLens        := {}
      aDeci        := {}
  CASE nMenuChoice = 2  .and. !empty(cInFile) // define ascii file
      popread(.t.,"CARACTER delimitador de campo",@cCharDelim,"",;
                  "delimitador Campo/Campo",@cFieldDelim,"")
      ddelim(cInfile,cCharDelim,cFieldDelim,aNames,aTypes,aLens,aDeci)
  CASE nMenuChoice = 3 .and. len(aNames) =0
      msg("Primiero debe definir la base de datos")
  CASE nMenuChoice = 3 .and. len(aNames) > 0
      if OK2EXPORT(aNames,aTypes,aLens,aDeci)
        export(cInfile,aNames,aTypes,aLens,aDeci,cCharDelim,cFieldDelim)
      endif
  ENDCASE
END
Restscreen(0,0,24,79,cInScreen)
Setcolor(cOldColor)
setcursor(nOldCursor)
return nil

//-----------------------------------------------------------------
static func pickfile
local cFile := popex("*.*")
return cFile
//-----------------------------------------------------------------
static funct ddelim(cInfile,cCharDelim,cFieldDelim,aNames,aTypes,aLens,aDeci)
local nLastkey,cLastkey
local cThisLine
local i,oTb
local nHandle := fopen(cInFile,64)
local nTop    := 1
local nLeft   := 1
local nBottom := 23
local nRight  := 78
local cInscreen := makebox(nTop,nLeft,nBottom,nRight,sls_popcol())
local nFields   := countfields(nHandle,cFieldDelim)
local nWidth,cType,nPosit,cName,nDeci
asize(aNames,nFields)
asize(aTypes,nFields)
asize(aLens,nFields)
asize(aDeci,nFields)
for i = 1 to nFields
  aNames[i] := iif(aNames[i]==nil,"CAMPOS"+alltrim(str(i)),aNames[i])
  aTypes[i] := iif(aTypes[i]==nil,"C",aTypes[i])
  aLens[i] := iif(aLens[i]==nil,0,aLens[i])
  aDeci[i] := iif(aDeci[i]==nil,0,aDeci[i])
next


@ 21,2 SAY "컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴"
@ 22,2 SAY PADC("[ENTER] Edita Definiciones de Campos [R] Rastrea Ancho    [S] Sale",nRight-nLeft-1)

IF Ferror() <> 0
  msg("Error abriendo archivo : "+cInFile)
  unbox(cInScreen)
  RETURN ''
ENDIF

oTb := tbrowsenew(nTop+1,nLeft+1,nBottom-3,nRight-1)
for i = 1 to len(aTypes)
  oTb:addcolumn(tbcolumnnew("Nombre:"+aNames[i]+";Tipo:"+atypes[i]+";Long:"+alltrim(str(aLens[i]))+";Deci:"+alltrim(str(aDeci[i])),;
                makedblock(i,aTypes,aLens,cFieldDelim,cCharDelim,nHandle) ))
next

oTb:skipblock     := {|n|tskip(n,nHandle)}
oTb:gotopblock    := {||ftop(nHandle)}
oTb:gobottomblock := {||fbot(nHandle)}
oTb:headsep := "�"
oTb:colsep := "�"
oTb:colorspec := sls_normcol()

while .T.
  DISPBEGIN()
  while !oTb:stabilize()
  end
  DISPEND()
  nLastKey := inkey(0)
  cLastkey := upper(chr(nLastkey))
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
  case nLastKey == K_LEFT
    oTb:left()
  case nLastKey == K_RIGHT
    oTb:right()
  case nLastkey == K_ENTER
    nPosit := oTb:colpos
    cName  := padr(aNames[nPosit],10)
    ctype  := padr(aTypes[nPosit],1)
    nWidth := aLens[nPosit]
    nDeci  := aDeci[nPosit]
    getfdef(@cName,@cType,@nWidth,@nDeci,aNames,nPosit)
    aNames[nPosit]          :=       cName
    aTypes[nPosit]          :=       ctype
    aLens[nPosit]           :=       nWidth
    aDeci[nPosit]           :=       nDeci
    oTb:setcolumn(nPosit,tbcolumnnew("Nombre:"+aNames[nPosit]+";Tipo:"+atypes[nPosit]+";Len:"+alltrim(str(aLens[nPosit]))+";Deci:"+alltrim(str(aDecI[nPosit])),;
                  makedblock(nPosit,aTypes,aLens,cFieldDelim,cCharDelim,nHandle) ))
    oTb:configure()
    oTb:refreshall()

  case cLastkey=="R"
    @ 22,2 SAY PADR("Rastreando...ESC para cancelar...",nRight-nLeft-1)
    scanit(nHandle,aLens,cFieldDelim,aTypes)
    for i = 1 to len(aLens)
      oTb:setcolumn(i,tbcolumnnew("Nombre:"+aNames[i]+";Tipo:"+atypes[i]+";Long:"+alltrim(str(aLens[i]))+";Deci:"+alltrim(str(aDeci[i])),;
                  makedblock(i,aTypes,aLens,cFieldDelim,cCharDelim,nHandle) ))
    next
	 @ 22,2 SAY PADC("[ENTER] Edita Definiciones de Campos [R] Rastrea Ancho    [S] Sale",nRight-nLeft-1)
  case cLastkey=="S"
    exit
  endcase
end
fclose(nHandle)
unbox(cInscreen)
return nil


//--------------------------------------------------------------------------
static FUNCTION fbot(nHandle)
FSEEK(nHandle,0,2)
RETURN ''


//--------------------------------------------------------------------------
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

//--------------------------------------------------------------------------
static function makedblock(i,aTypes,aLens,cFieldDel,cCharDel,nHandle)
local bBlock
do case
case aTypes[i]=="C"
  bBlock := {||cRemove(padr(takeout(sfreadline(nHandle),cFieldDel,i),iif(aLens[i]#0,aLens[i],10)),cCharDel)  }
case aTypes[i]=="N"
  bBlock := {||padl(takeout(sfreadline(nHandle),cFieldDel,i),iif(aLens[i]#0,aLens[i],10)) }
case aTypes[i]=="D"
  bBlock := {||stod(takeout(sfreadline(nHandle),cFieldDel,i)) }
case aTypes[i]=="L"
  bBlock := {||iif(takeout(sfreadline(nHandle),cFieldDel,i)=="T",.t.,.f.) }
case aTypes[i]=="?"
  bBlock := {||padr(takeout(sfreadline(nHandle),cFieldDel,i),iif(aLens[i]#0,aLens[i],10)) }
endcase
return bBlock

//--------------------------------------------------------------------------
static function cremove(cStr,cKill)
return strtran(cStr,cKill,'')
//-------------------------------------------------
static function countfields(nHandle,cDelim)
local cLine := sfreadline(nHandle)
local i
local nDelim := 0
for i = 1 to len(cLine)
  if subst(cLine,i,1)==cDelim
    nDelim++
  endif
next
return (nDelim+1)

//-----------------------------------------------------------
static function scanit(nHandle,aLens,cFieldDelim,aTypes)
local nPosit,i,nCount
local cThisLine
nPosit := FSEEK(nHandle,0,1)
fTop(nHandle)
nCount := 0
while inkey()#27
  if !empty((cThisLine:= sfreadline(nHandle)))
    for i = 1 to len(aLens)
      if aTypes[i]=="C"
        aLens[i] := max(aLens[i],len(takeout(cThisLine,cFieldDelim,i)))
      endif
    next
  else
    exit
  endif
  if !fmove2next(nHandle)
    exit
  endif
  nCount++
  @22,28 say alltrim(str(nCount))
  ??" records checked.."
  ??"("+alltrim(str(fseek(nHandle,0,1)))+")"
end
fseek(nHandle,nPosit)
return nil

//-------------------------------------------------------
static funct getfdef(cName,cType,nLen,nDec,aNames,nPosit)
local inbox := makebox(7,17,16,58)
memvar getlist
@ 8,19  SAY "Nombre Campo"
@ 10,19 SAY "Tipo de Campo          (CDNL)"
@ 12,19 SAY "Long de Campo"
@ 14,19 SAY "Decimales"
@8,35  get cName valid nameval(cName,aNames,nPosit) picture "@K !!!!!!!!!!"
@10,35 get cType valid TypeVal(cType,@nLen,@nDec)  PICTURE "!"
@12,35 get nLen  when cType$"CN" valid LenVal(cType,nLen,@nDec)  // dec passed by ref
@14,35 get nDec  when cTYPE=="N" valid DecVal(cType,nLen,@nDec)  // dec passed
SETCURSOR(1)
read
SETCURSOR(0)
unbox(inbox)
return nil

//-----------------------------------------------------------
static function nameval(cName,aNames,nPosit)
local lReturn := .t.
local nScanFound
memvar getlist
IF EMPTY(cName)
   msg("Se requiere un nombre de campo")
   lReturn := .f.
ELSEIF !(LEFT(cName,1) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
   msg("El nombre de campo debe comenzar con un caracter A-Z")
   lReturn := .f.
ELSEIF !allowedc(cName)
   lReturn := .f.
ELSE
  nScanFound := ASCAN(aNames,{|e|e==cName})
  IF nScanFound<>nPosit .and. nScanFound> 0
    msg("Nombre de campo duplicado")
    lReturn := .f.
  ENDIF
endif
return lReturn

//-----------------------------------------------------------------
static function TypeVal(cType,nLen,nDec)  // len,dec passed by ref
local lReturn := .t.
memvar getlist
IF !cType $ "CNDLM"
  msg("Tipo de campo no v쟫ido - usar CNDL")
  lReturn := .F.
ENDIF
*- determine len/dec based on type
DO CASE
CASE cType = "C"
  nDec := 0
  aeval(getlist,{|g|g:display()} )
CASE cType = "L"
  nDec := 0
  nLen := 1
  aeval(getlist,{|g|g:display()} )
CASE cType = "D"
  nLen := 8
  nDec := 0
  aeval(getlist,{|g|g:display()} )
ENDCASE
return lReturn

//--------------------------------------------------------
static function LenVal(cType,nLen,nDec)  // dec passed by ref
local lReturn := .t.
memvar getlist
IF cType == "N"
  IF !nLen > 0
    msg("La longitud del campo debe ser > 0")
    lReturn := .F.
  ELSEIF !nLen < 20
    msg("La longitud del campo debe ser < 20")
    lReturn := .F.
  ENDIF
ELSE
   nDec := 0
   if !nLen > 0
    msg("La longitud del campo debe ser > 0")
    lReturn := .F.
  ENDIF
ENDIF
aeval(getlist,{|g|g:display()} )
return lReturn

//--------------------------------------------------------
static function DecVal(cType,nLen,nDec)
local lReturn := .t.
local cMaxDec
memvar getlist
IF cType == "N"
  IF nDec > MAX(nLen-2,0)
    cMaxDec = STR(MAX(nLen-2,0),2)
    msg("Demasiados decimales para la long del campo","El m쟸imo es "+cMaxDec)
    lReturn := .F.
  ELSEIF nDec > 18
    msg("Los decimales deben ser menores que 19")
    lReturn := .F.
  ENDIF
ELSE
   nDec := 0
ENDIF
aeval(getlist,{|g|g:display()} )
RETURN lReturn


//===============================================================
static function allowedc(cName)
local lReturn  := .t.
local cAllowed := "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"
local nCount   := 1
cName := trim(cName)
FOR nCount = 1 TO LEN(cName)
  IF !SUBSTR(RTRIM(cName),nCount,1) $ cAllowed
    msg("Caracteres ilegales en el nombre del campo :"+rtrim(cName),"Caracter :"+SUBSTR(RTRIM(cName),nCount,1),"Debe ser "+cAllowed )
    lReturn := .f.
    EXIT
  ENDIF
NEXT
return lReturn

//===============================================================
static function OK2EXPORT(aNames,aTypes,aLens,aDeci)
local lReturn := len(aNames)>0
local cName,cType,nLen,nDec
local i
for i = 1 to len(aNames)
  cName := aNames[i]
  cType := aTypes[i]
  nLen  := aLens[i]
  nDec  := aDeci[i]
  do case
  CASE  !nameval(cName,aNames,i)
    lReturn := .t.
    exit
  CASE  !TypeVal(cType,@nLen,@nDec)
    lReturn := .t.
    exit
  CASE  !LenVal(cType,nLen,@nDec)
    lReturn := .t.
    exit
  CASE  !DecVal(cType,nLen,@nDec)
    lReturn := .t.
    exit
  endcase
next
return lReturn

//-----------------------------------------------------------
static function export(cInfile,aNames,aTypes,aLens,aDeci,cCharDel,cFieldDel)
local cDbfName := getdbfname()
local aStruct   := {}
local nOldarea := select()
local nHandle := fopen(cInFile,64)
local nPosit,i,nCount
local cThisLine
local abBlocks := array(len(aNames))
nPosit := FSEEK(nHandle,0,1)
select 0
if !empty(cDbfName)

  for i = 1 to len(aNames)
    aadd(aStruct,{aNames[i],aTypes[i],aLens[i],aDeci[i]})
    do case
    case aTypes[i]=="C"
      abBlocks[i] := {|l,i|cRemove(padr(takeout(l,cFieldDel,i),aLens[i]),cCharDel)  }
    case aTypes[i]=="N"
      abBlocks[i] := {|l,i|makenumb(takeout(l,cFieldDel,i),aLens[i],aDeci[i] ) }
    case aTypes[i]=="D"
      abBlocks[i] := {|l,i|stod(takeout(l,cFieldDel,i)) }
    case aTypes[i]=="L"
      abBlocks[i] := {|l,i|iif(takeout(l,cFieldDel,i)=="T",.t.,.f.) }
    endcase
  next

  DBCREATE(cDbfName,aStruct)
  USE (cDbfName)
  if used()
    fTop(nHandle)
    nCount := 0
    while inkey()#27
      if !empty((cThisLine:= sfreadline(nHandle))) .and. !chr(26)$cThisLine
        APPEND BLANK
        for i = 1 to len(aLens)
          fieldput(i,eval(aBBlocks[i],cthisLine,i))
        next
      else
        exit
      endif
      if !fmove2next(nHandle)
        exit
      endif
     nCount++
     @22,4 say alltrim(str(nCount))
     ??" registros exportados.."
    end
    fseek(nHandle,nPosit)
  endif
endif
if messyn("쮄e la DBF ahora?")
  editdb(.t.)
endif
USE
select (nOldArea)
fclose(nHandle)
@20,1,23,78 BOX sls_frame()
return nil

//-----------------------------------------------------------
static func getdbfname
local cDbfName  := SPACE(8)
While empty(cDbfName)
  cDbfName  := SPACE(8)
  popread(.F.,"Name of datafile to create (Escape aborts): ",@cDbfName,"@!")
  cDbfName  := Alltrim(cDbfName)
  IF LASTKEY() = K_ESC .OR. EMPTY(cDbfName)
    EXIT
  ENDIF
  cDbfname += ".DBF"
  IF FILE(cDbfName)
    msg("La base de datos "+cDbfName+" ya existe - ",;
             "Usar otro nombre","O borrar la que existe")
    cDbfName := ""
    LOOP
  ENDIF
  exit
end
return cDbfName
//------------------------------------------------------------
static func makenumb(cField,nLen,nDeci )
local nVal  := val(cField)
local cPict := iif(nDeci>0,stuff(repl("9",nLen),nLen-nDeci,1,"."),repl("9",nLen))
return val( trans(nVal,cPict) )


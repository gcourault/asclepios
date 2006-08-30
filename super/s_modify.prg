memvar getlist

#include "inkey.ch"
#define K_SPACE 32
FUNCTION MODIFY
local cDbfname := ""
local aStruct  := determine(@cDbfName)
local nOldArea := select()
local nOldCursor := setcursor()
local lOldExact  := setexact()

select 0

if aStruct#nil .and. !empty(cDbfName)
  aStruct := makestruct(aStruct)
  if len(aStruct) > 0 .and. !empty(aStruct[1,1]) .and. messyn("Save Changes?")
    putstru(cDbfName,aStruct)
  endif
endif

SELECT (nOldarea)
setexact(lOldexact)
setcursor(nOldcursor)
IF !empty(cDbfName) .and. FILE(cDbfName)
  RETURN cDbfName
ELSE
  RETURN ''
ENDIF
return ''
*-------------------------------------------

static FUNCTION determine(cDbfName)      // cDbfName passed by ref @
local cFromDbf,aStruct
local lUseExist
local nDbfs     := adir("*.dbf")
local aDbfs     := array(nDbfs+1)
local nChoice
Adir("*.dbf",aDbfs)
Ains(aDbfs,1)
aDbfs[1] = "<Crear nueva base de datos>"
nChoice   := mchoice(aDbfs,3,17,15,42,"[DBF a Modificar]")
lUseExist := (nChoice > 1)
cDbfName  := iif(nChoice>0,aDbfs[nChoice],"")
IF nChoice > 0
  while aStruct==nil
     IF nChoice == 1         // create new structure
       cDbfName  := SPACE(8)
       popread(.F.,"Nombre de la Base de datos a Crear (Escape cancela): ",@cDbfName,"@!")
       cDbfName  := Alltrim(cDbfName)
       IF LASTKEY() = K_ESC .OR. EMPTY(cDbfName)
         EXIT
       ENDIF
       cDbfname += ".DBF"
       IF FILE(cDbfName)
         msg("La base de datos "+cDbfName+" ya existe - ",;
                  "Use otro nombre","O b¢rrela primero")
         cDbfName := ""
         LOOP
       ENDIF
       IF messyn("¨Copia la estructura de una DBF existente?")
          cFromDbf = popex("*.DBF",'[Bases de Datos]',.T.)
       ENDIF
     endif

     IF cFromDbf#nil
       aStruct := getstru(cFromDbf)
     ELSEIF lUseExist
       aStruct := getstru(cDbfName)
     ELSE
       aStruct := {{space(10),"C",10,0}}
     ENDIF
  end
endif
return aStruct

//========================================================
static function getstru(cDbfName)
local aStruct
local cDbtName
USE (cDbfName)
IF !used()
  msg("No se puede abrir "+cDbfName)
  RETURN nil
else
  aStruct := dbstruct()
ENDIF
USE
return aStruct

//========================================================
static function putstru(cDbfName,aStruct)
local cDbtName
plswait(.T.,"Grabando la nueva estructura...")
if !file(cDbfName)                      // must be a new dbf
  DBCREATE(cDbfName,aStruct)
else                                    // must be an existing dbf
  *- saving an existing structure
  *- erase these two if they exist
  ERASE t_e_m_p2.dbf
  ERASE t_e_m_p2.dbt

  *- make a DBT filespec, in case there's a DBT
  cDbtName := SUBSTR(cDbfName,1,LEN(cDbfName)-4)+".dbt"

  *- rename dbf, (and .dbt if one exists)
  RENAME (cDbfName) TO t_e_m_p2.dbf
  RENAME (cDbtName) TO t_e_m_p2.dbt

  DBCREATE(cDbfName,aStruct)

  *- open the new structure
  USE (cDbfName)
  *- append from the renamed dbf
  APPEND FROM t_e_m_p2.dbf

  USE
  *- erase temps
  ERASE t_e_m_p2.dbf
  ERASE t_e_m_p2.dbt
endif
plswait(.f.)
return nil

//----------------------------------------------------------
static proc sayinst
@ 1,1,23,35 BOX "ÚÄ¿³ÙÄÀ³ "
@ 1,37,23,78 BOX "ÚÄ¿³ÙÄÀ³ "
@ 1,2 SAY "[Modificaci¢ de Estructura]"
@ 1,38 SAY "[Instrucciones]"

@ 2,40 SAY "Tecla            Acci¢n"
@ 3,40 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 4,40 SAY "F10              Sale"
@ 5,40 SAY "Flechas "+chr(24)+chr(25)+"       Mover 1 arr y ab"
@ 6,40 SAY "PGUP, PGDN       Mover 10 arr o ab "
@ 7,40 SAY "HOME,END         Primer o Ult campo "
@ 8,40 SAY "A-Z              Busca el que empieza"
@ 9,56 SAY "con la letra   "
@ 10,40 SAY "ENTER            Edita el campo activo"
@ 11,40 SAY "INSERT           Agrega Campo"
@ 12,40 SAY "DELETE           Borra campo(s) "
@ 13,40 SAY "ALT-U            Desborra campo "
@ 14,40 SAY "SPACE BAR        Mueve Campo"
@ 15,40 SAY "ALT-A            Alfabetiza campos "
@ 16,40 SAY "ALT-R            Retorna al Original"
@ 18,40 SAY "Tipos de Campos"
@ 19,40 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ 20,40 SAY "C   Caracter      D  Fecha"
@ 21,40 SAY "N   N£merico      L  L¢gico"
@ 22,40 SAY "M   Memo"

return
//======================================================================

static function makestruct(aStruct)
local nElement  := 1
local oStruc    := tbrowseNew(2,2,22,33)
local nLastkey,cLastkey
local cInscreen := savescreen(0,0,24,79)
local aMoveSeg,nMoveTo,cMoveBox
local aOldStruc := aclone(aStruct)
local nFound
local aDeleted := {}
local lDoneMods := .f.

dispbox(0,0,24,79,"±±±±±±±±±",sls_normcol())

oStruc:addcolumn(tbColumnNew("#",{||trans(nElement,"999")}  ))
oStruc:addcolumn(tbColumnNew("Name",{||padr(aStruct[nElement,1],10)}  ))
oStruc:addcolumn(tbColumnNew("Type",{||padc(aStruct[nElement,2],4)}  ))
oStruc:addcolumn(tbColumnNew("Length",{||trans(aStruct[nElement,3],"999999")}  ))
oStruc:addcolumn(tbColumnNew("Dec",{||trans(aStruct[nElement,4],"99999")}  ))
oStruc:SKIPBLOCK := {|n|AASKIP(n,@nElement,LEN(aStruct))}
oStruc:gobottomblock := {||nElement := len(aStruct)}
oStruc:gotopblock    := {||nElement := 1}
oStruc:headsep       := chr(196)

sayinst()

checkempty(@aStruct)
while !lDoneMods
   nElement := max(1,nElement)
   checkempty(@aStruct)

   while !oStruc:stabilize()
   end

   if !empty(aStruct[1,1])
     nLastKey := INKEY(0)
   else
     nLastKey := K_ENTER
   endif
   cLastKey := upper(chr(nLastkey))
   do case
   CASE nLastKey = K_UP          && UP ONE ROW
     oStruc:UP()
   CASE nLastKey = K_PGUP        && UP ONE PAGE
     oStruc:PAGEUP()
   CASE nLastKey = K_LEFT        && UP ONE ROW
     oStruc:left()
   CASE nLastKey = K_RIGHT       && UP ONE PAGE
     oStruc:right()
   CASE nLastKey = K_HOME        && HOME
     oStruc:GOTOP()
   CASE nLastKey = K_DOWN        && DOWN ONE ROW
     oStruc:DOWN()
   CASE nLastKey = K_PGDN        && DOWN ONE PAGE
     oStruc:PAGEdOWN()
   CASE nLastKey = K_END         && END
     oStruc:GOBOTTOM()
   case nLastKey = K_F10
     lDoneMods := .t.
   case nLastKey = K_ESC .and. messyn("Abandona modificaciones?")
     lDoneMods := .t.
     asize(aStruct,0)
   case cLastKey$"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        nFound := ASCAN(aStruct,{|e|LEFT(e[1],1)==cLastKey},nElement+1)
        if nFound==0 .and. nElement > 1
          nFound := ASCAN(aStruct,{|e|LEFT(e[1],1)==cLastKey})
        endif
        if nFound > 0
          bgoto(nFound,nElement,oStruc)
        endif
   case nLastkey == K_ENTER   // edit this field
        edit(aStruct,nElement,aOldStruc)
        if len(aStruct)==0 .or. empty(aStruct[1,1])
          if lastkey()=27 .and. messyn("Abandona modificaciones?")
            lDoneMods := .t.
          elseif messyn("Se agregar  un campo. ¨Desea Salir?")
            lDoneMods := .t.
          endif
        endif
        oStruc:refreshcurrent()
   case nLastkey == K_INS     // add field
        ASIZE(aStruct,len(aStruct)+1)
        AINS(aStruct,nElement+1)
        aStruct[nElement+1] := {space(10),"C",10,0}
        oStruc:down()
        oStruc:refreshall()
        while !oStruc:stabilize()
        end
        edit(aStruct,nElement,aOldStruc)
        if empty(aStruct[nElement,1])
          adel(aStruct,nElement)
          ASIZE(aStruct,len(aStruct)-1)
          oStruc:up()
        endif
        oStruc:refreshall()
   case nLastkey == K_DEL     // delete
        aadd(aDeleted,aStruct[nElement])
        adel(aStruct,nElement)
        ASIZE(aStruct,len(aStruct)-1)
        if nElement > len(aStruct)
          oStruc:gotop()
        endif
        oStruc:refreshall()
   case nLastkey == K_ALT_R   // reset ro original
       aStruct  := aclone(aOldStruc)
       nElement := 1
       oStruc:refreshall()
   case nLastkey == K_ALT_U   // undelete
        if len(aDeleted) > 0
          ASIZE(aStruct,len(aStruct)+1)
          AINS(aStruct,nElement)
          aStruct[nElement] := atail(aDeleted)
          ASIZE(aDeleted,len(aDeleted)-1)
        endif
        oStruc:refreshall()
   case nLastkey == K_ALT_A   // alphabetize fields
       aStruct  := ASORT(aStruct,,, { |x, y| x[1] < y[1] })
       nElement := 1
       oStruc:configure()
       oStruc:refreshall()
   case nLastkey == K_SPACE   // move single field
    nMoveTo  := nElement
    while .t.
      POPREAD(.T.,"Ingrese la nueva posici¢n del Campo: "+aStruct[nElement,1],;
                @nMoveto,"999")
      IF lastkey()==K_ESC
        exit
      ELSEIF !(nMoveTo > 0 .AND. nMoveTo <=len(aStruct) )
        msg("Must be greater than 0, less than "+TRANS(len(aStruct),'999') )
      else
        EXIT
      endif
    ENDDO
    if lastkey()<>K_ESC .AND. nMoveto<> nElement
      aMoveSeg := aStruct[nElement]
      Adel(aStruct,nElement)
      AINS(aStruct,nMoveTo)
      aStruct[nMoveTo] := aMoveSeg
      bgoto(nMoveTo,nElement,oStruc)
      nElement := nMoveTo
      oStruc:refreshall()
    ENDIF
   endcase
end
restscreen(0,0,24,79,cInscreen)
return aStruct


//----------------------------------------------------------



//------------------------------------------------------------
static function edit(aStruct,nElement,aOldStruc)
local cName,cType,nLen,nDec,lSaved
local nRow := row()

lSaved := .F.
cName  := aStruct[nElement,1]
cType  := aStruct[nElement,2]
nLen   := aStruct[nElement,3]
nDec   := aStruct[nElement,4]

SET CURSOR ON
IF EMPTY(cName)   && new field
  @nRow,6  get cName PICTURE "@!"
  atail(getlist):postblock := {||fvalid(1,@cName,@cType,@nLen,;
                              @nDec,aStruct,aOldStruc,nElement)}
  @nRow,18 get cType PICTURE "@!"
  atail(getlist):postblock := {||fvalid(2,@cName,@cType,@nLen,;
                              @nDec,aStruct,aOldStruc,nElement)}
  @nRow,25 get nLen picture "999"
  atail(getlist):postblock := {||fvalid(3,@cName,@cType,@nLen,;
                              @nDec,aStruct,aOldStruc,nElement)}
  atail(getlist):preblock := {||!cType$"DLM"}

  @nRow,31 get nDec picture "999"
  atail(getlist):postblock := {||fvalid(4,@cName,@cType,@nLen,;
                              @nDec,aStruct,aOldStruc,nElement)}
  atail(getlist):preblock := {||!cType$"DLMC".and.nLen>2}
  READ
ELSEIF cType $ "LMD"
    msg("This field definition may not be changed")
ELSEIF cType == "C"
    msg("You may change the LENGTH of this field only")
    @nRow,25 get nLen picture "999"
    atail(getlist):postblock := {||fvalid(3,@cName,@cType,@nLen,;
                               @nDec,aStruct,aOldStruc,nElement)}
    READ
ELSE
    msg("Quiere aumentar la LONGITUD","o disminuir los DECIMALES","de este CAMPO")
    @nRow,25 get nLen picture "999"
    atail(getlist):postblock := {||fvalid(3,@cName,@cType,@nLen,;
                               @nDec,aStruct,aOldStruc,nElement)}
    @nRow,31 get nDec picture "999"
    atail(getlist):postblock := {||fvalid(4,@cName,@cType,@nLen,;
                               @nDec,aStruct,aOldStruc,nElement)}
    atail(getlist):preblock := {||!cType$"DLMC".and.nLen>2}
    READ
ENDIF

IF !LASTKEY() = K_ESC
  aStruct[nElement,1]:=cName
  aStruct[nElement,2]:=cType
  aStruct[nElement,3]:=nLen
  aStruct[nElement,4]:=nDec
  lSaved = .T.
ENDIF

SET CURSOR OFF
RETURN lSaved


//===============================================================
static FUNCTION fvalid(nPosit,cName,cType,nLen,nDec,aStruct,aOldStruc,nElement)
local lReturn := .t.
local nScanFound,nMaxDec
memvar getlist
DO CASE
CASE nPosit = 1
    IF EMPTY(cName)
       msg("Se necesita un nombre de campo")
       lReturn := .f.
    ELSEIF !(LEFT(cName,1) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
       msg("El nombre del campo debe comenzar con una letra de A-Z")
       lReturn := .f.
    ELSEIF !allowedc(cName)
       lReturn := .f.
    ELSE
       nScanFound := ASCAN(aStruct,{|e|e[1]==cName})
       IF nScanFound<>nElement .and. nScanFound> 0
         msg("Nombre duplicado de un campo existente")
         lReturn := .f.
       ELSEIF nScanFound == 0
         nScanFound := ASCAN(aOldStruc,{|e|e[1]==cName})
         IF nScanFound > 0
           msg("Nombre duplicado de un campo existente [borrado]")
           lReturn := .f.
         ENDIF
       ENDIF
    endif

CASE nPosit = 2
    IF !cType $ "CNDLM"
      msg("Tipo de campo inv lido - usar CNDLM")
      lReturn := .F.
    ENDIF

    *- determine len/dec based on type
    DO CASE
    CASE cType = "C"
      nDec := 0
      aeval(getlist,{|g|g:display()} )
    CASE cType = "L"
      nLen := 1
      nDec := 0
      aeval(getlist,{|g|g:display()} )
    CASE cType = "D"
      nLen := 8
      nDec := 0
      aeval(getlist,{|g|g:display()} )
    CASE cType = "M"
      nLen := 10
      nDec := 0
      aeval(getlist,{|g|g:display()} )
    ENDCASE

CASE nPosit = 3
    IF cType == "N"
      IF nLen < aStruct[nElement,3] .and. !empty(aStruct[nElement,1]) // not new
        msg("No se puede disminuir la longitud de un campo num‚rico")
        lReturn := .F.
      ELSEIF !nLen > 0
        msg("La longitud del campo debe ser mayor que 0")
        lReturn := .F.
      ELSEIF !nLen < 20
        msg("La longitud del campo debe ser menor que 20")
        lReturn := .F.
      ENDIF
    ELSEIF cType = "C"
      IF !nLen > 0
        msg("La longitud del campo debe ser mayor que 0")
        lReturn := .F.
      ENDIF
    ENDIF
CASE nPosit = 4
    IF cType == "N"
      IF !empty(aStruct[nElement,1]) .and. ;  // this tests if it is a new one
         nDec > aStruct[nelement,4] .and. ASCAN(aOldStruc,{|e|e[1]==cName})>0
           msg("No se puede incrementar los decimales de un campo existente")
           lReturn := .F.
      ELSEIF nDec > MAX(nLen-2,0)
        nMaxDec = STR(MAX(nLen-2,0),2)
        msg("Demasiados decimales para esta longitus de campo","El m ximo es "+nMaxDec)
        lReturn := .F.
      ELSEIF nDec > 18
        msg("Los decimales deben ser menor que 19")
        lReturn := .F.
      ENDIF
    ENDIF
ENDCASE
RETURN lReturn


//===============================================================
static function allowedc(cName)
local lReturn  := .t.
local cAllowed := "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"
local nCount   := 1
cName := trim(cName)
FOR nCount = 1 TO LEN(cName)
  IF !SUBSTR(RTRIM(cName),nCount,1) $ cAllowed
    msg("Illegal character in field name :"+SUBSTR(RTRIM(cName),nCount,1),"Must be "+cAllowed )
    lReturn := .f.
    EXIT
  ENDIF
NEXT
return lReturn

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

//===============================================================
static function checkempty(aStruct)
if len(aStruct)==0
   aStruct := { {space(10),space(1),0,0} }
endif
return aStruct









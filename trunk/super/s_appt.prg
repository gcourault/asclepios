#include "inkey.ch"
function sappoint
local cInBox
local dTarget := date()
local nOldArea:= select()
local nNewArea:= dbselectarea(0)
local oTb
local lProceed := .t.
local cNormcolor,cEnhcolor
local nGridSel     := 1
local nOldSel      := 1
local nLastKey
local aValues      := array(3)
local aOptions := { ;
                   {23,2 ,  'Agregar'},;
                   {23,11 , 'Editar'},;
                   {23,20 , 'Borrar'},;
                   {23,29 , 'Cambiar Fecha'},;
                   {23,45 , 'Sacar Lista'},;
                   {23,58 , 'Purgar '},;
                   {23,74 , 'Fin'}}


if lProceed := checkfile(slsf_appt())
   cInBox  := makebox(0,0,24,79,sls_popcol())
   cNormcolor   := takeout(Setcolor(),",",1)
   cEnhcolor    := takeout(Setcolor(),",",2)
   @ 2,0 SAY 'Ã'
   @ 2,79 SAY '´'
   @ 22,0 SAY 'Ã'
   @ 22,79 SAY '´'
   @ 1,2 SAY "AGENDA DIARIA - Agenda para el d¡a: "+dtow(dTarget)
   @ 2,1 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   @ 22,1 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   aeval(aOptions,{|e|devpos(e[1],e[2]),devout(e[3],cNormColor)})
   seek(dtos(dTarget))
   oTb := tbrowsenew(3,1,21,78)
   oTb:addcolumn(tbcolumnNew(nil,{||iif(eof(),padr("NONE    ",75),mil2std(__APPT->time)+' '+padr(__APPT->desc,65))} ))
//   oTb:addcolumn(tbcolumnNew(nil,{||iif(eof(),space(65),padr(__APPT->desc,65))} ))
   oTb:skipblock     := {|n|apSkip(n,dTarget)}
   oTb:gobottomblock := {|n|apgoBot(dTarget)}
   oTb:gotopblock    := {|n|apgoTop(dTarget)}
   oTb:colorspec := sls_normcol()
   do while .t.
     dispbegin()
     @aOptions[nOldSel,1],aOptions[nOldSel,2] say aOptions[nOldSel,3] color cNormColor
     nOldSel      := nGridSel
     While !oTb:stabilize()
     end
     @aOptions[nGridSel,1],aOptions[nGridSel,2] say aOptions[nGridSel,3] color cEnhColor
     dispend()
     nLastKey := inkey(0)
     do case
     case nLastKey = K_UP
         oTb:up()
     case nLastKey = K_DOWN
         oTb:down()
     case nLastKey = K_LEFT
        nGridSel := IIF(nGridSel=1,7,nGridSel-1)
     case nLastKey = K_RIGHT
        nGridSel := IIF(nGridSel=7,1,nGridSel+1)
     case UPPER(CHR(nLastKey))$"AEBCSPF"
        nGridSel := AT(upper(chr(nLastKey)),"AEBCSPF")
        keyboard chr(13)
     case nLastKey = K_ENTER
        do case
        case nGridSel = 1   // add
          aValues[1] := dTarget
          aValues[2] := "12:00pm"
          aValues[3] := space(65)
          if edit(aValues)
            if add()
              save(aValues)
            endif
          endif
          oTb:refreshall()
        case nGridSel = 2 .and. !eof()  // edit
          aValues[1] := stod(__appt->date)
          aValues[2] := mil2std(__appt->time)
          aValues[3] := __appt->desc
          if edit(aValues)
            save(aValues)
          endif
          oTb:refreshall()
        case nGridSel = 3   // delete
          if messyn(" ¨Lo borra?")
            blank()
          endif
          oTb:gotop()
          oTb:refreshall()
        case nGridSel = 4   // change date
          dTarget := getdate(dTarget)
			  @ 1,2 SAY "AGENDA DIARIA - Agenda para el d¡a: "+dtow(dTarget)
          seek(dtos(dTarget))
          oTb:refreshall()
        case nGridSel = 5   // output list
          print(dTarget)
        case nGridSel = 6   // purge
          clean()
          seek(dtos(dTarget))
          oTb:refreshall()
        case nGridSel = 7   // quit
          exit
        endcase
     endcase
   enddo
   unbox(cInBox)
endif
USE
dbselectarea(nOldArea)
return nil

//---------------------------------------------------------------------
static function mil2std(cMilTime)
local cHrs  := left(cMilTime,2)
local cMins := right(cMilTime,2)
local cAmPm := "am"
if val(cHrs)>11
  cAmPm := "pm"
elseif val(chrs)=0
  cHrs  := "12"
  cAmPm := "am"
endif
if val(cHrs)>12
  cHrs  := trans(val(cHrs)-12,"99")
endif
return cHrs+":"+cMins+cAmPm
//---------------------------------------------------------------------
static function std2mil(cStdTime)
local cHrs  := left(cStdTime,2)
local cMins := subst(cStdTime,4,2)
local cAmPm := right(cStdTime,2)
if cAmPm == "pm" .and. val(cHrs) < 12
  cHrs  := trans(val(cHrs)+12,"99")
elseif cAmPm == "am" .and.  cHrs=="12"
  cHrs  := "00"
endif
return cHrs+":"+cMins
//---------------------------------------------------------------------
STATIC FUNCTION checkfile(cApptFile)
local lOk := .t.
field date,time,desc
if !file(cApptFile+".DBF")
   lOk := .f.
   DBCREATE(cApptFile,{ {"DATE","C",8,0},;
                        {"TIME","C",5,0},;
                        {"DESC","C",65,0}})
   if file(cApptFile+".DBF")
      lOk := .t.
   else
      msg("Problemas al encontrar/crear archivo de Agenda")
   endif
endif
IF lOk
  lOk := SNET_USE(slsf_appt(),"__APPT",.F.,5,.T.;
                  ,"No se puede abrir archivo de Agenda. ¨Reintenta?")
endif
if lOk .and. !file(cApptFile+indexext())
   lOk := .f.
   plswait(.T.,"Contruyendo ¡ndice...")
   index on DATE+TIME TO (cApptFile)
   plswait(.F.)
   if file(cApptFile+indexext())
      lOk := .t.
   else
       msg("Problemas al crear/encontrar archivo ¡ndice")
   endif
endif
if lOk
  SET INDEX TO (cApptFile)
  if !indexkey(0)="DATE+TIME"
    lOk := .f.
  endif
ENDIF
return lOk

//---------------------------------------------------------------------
static function apSkip(n,dTarget)
local nMoved     := 0
local nLastGood  := recno()
if n > 0
  while nMoved < n
    dbskip(1)
    if eof() .or. DTOS(dTarget)<>__APPT->date
      dbgoto(nLastGood)
      exit
    else
      nMoved++
      nLastGood := recno()
    endif
  end
elseif n < 0
  while nMoved > n
    dbskip(-1)
    if bof() .or. DTOS(dTarget)<>__APPT->date
      dbgoto(nLastGood)
      exit
    else
      nMoved--
      nLastGood := recno()
    endif
  end
endif
return nMoved

//---------------------------------------------------------------------
static function apgoBot(dTarget)
local nEndRec := recno()
seek DTOS(dTarget)
while DTOS(dTarget)==__APPT->date
  nEndRec := recno()
  dbskip(1)
end
go nEndRec
return nil
//---------------------------------------------------------------------
static function apgoTop(dTarget)
seek DTOS(dTarget)
return nil
//----------------------------------------------------------------
static function edit(aValues)
local lSaved := .f.
local cBox   := makebox(7,1,14,79)
local cAmPm  := right(aValues[2],2)
local cTime  := left(aValues[2],5)
local nHours := val(left(cTime,2))
local nMins  := val(right(cTime,2))
local getlist := {}

@ 7,4 SAY "[Apunte]"
@ 9,9 SAY "Fecha"
@ 10,9 SAY "Hora    :                AmPm"
@ 12,2 SAY "Descripci¢n"

@9,15  say aValues[1]
//@9,15  get aValues[1]
@10,15 get nHours pict "99" valid iif(nHours<13,.t.,(msg("Must be < 13 "),.f.))
@10,18 get nMins  pict "99" valid iif(nMins<60,.t.,(msg("Must be < 60 "),.f.))
@10,40 get cAmpm valid iif(lower(cAmPm)=="am" .or. lower(cAmPm)=="pm",.t.,(msg("Must be [am] or [pm]"),.f.))
@12,15 get aValues[3] PICT "@S62"
read

if lastkey()<>27
  if messyn("¨Graba?")
    lSaved := .t.
    cAmPm := lower(cAmPm)
    aValues[1] := dtos(aValues[1])
    aValues[2] := std2mil(padz(trans(nHours,"99")+":"+trans(nMins,"99"))+lower(cAmPm))
  endif
endif
unbox(cBox)
return lSaved
//----------------------------------------------------------------
static function save(aValues)
IF SREC_LOCK(5,.T.,"No se puede bloquear el registro ¨Reintenta?")
   __APPT->date := aValues[1]
   __APPT->time := aValues[2]
   __APPT->desc := aValues[3]
ENDIF
unlock
return nil
//----------------------------------------------------------------
static function blank()
IF SREC_LOCK(5,.T.,"No se puede bloquear el registro. ¨Reintenta?")
   __APPT->date := ""
   __APPT->time := ""
   __APPT->desc := ""
ENDIF
unlock
return nil
//----------------------------------------------------------------
static function add
local lAdded := .f.
seek space(8)
if found()
  lAdded := .t.
elseif SADD_REC(5,.T.,"No se puede agregar registro ¨Reintenta?")
  lAdded := .t.
endif
return lAdded

//----------------------------------------------------------------
static function padz(cStr)
return strtran(cStr," ","0")

//----------------------------------------------------------------
static function clean
local dClean := date()
local i
local cClean
popread(.t.,"Limpiar apuntes viejos antes de:",@dClean,"")
if messyn("¨Est  seguro?")
  plswait(.t.,"Limpiando...")
  cClean := dtos(dClean)
  for i = 1 to recc()
    go i
    if __APPT->date < cClean
        blank()
    endif
  next
  plswait(.f.)
endif
return nil

//----------------------------------------------------------------
static function print(dTarget)
local nDevice   := 1
local cDevice   := "LPT1"
local cFileName := "APPOINTS.PRN"
local nLPP      := 60
local nCount    := 0
seek dtos(dTarget)
if found()
   count while dtos(dTarget)==__APPT->date to nCount
   seek dtos(dTarget)
   if messyn(" ¨Imprime los apuntes de " + dtoc(dTarget) + "?" )
     if (nDevice := ;
        menu_v("Destino","Impresora LPT1",;
        "Impresora LPT2","Impresora COM1","Archivo")) > 0
        if nDevice = 4
          popread(.t.,"Archivo a escribir:",@cFilename,"")
          if !empty(cFileName)
            set printer to (cFileName)
            output(dTarget,nCount+10,.f.)
          endif
        else
          cDevice := {"LPT1","LPT2","COM1"}[nDevice]
          if p_ready(cDevice,.f.,.f.)
            SET PRINTER TO (cDevice)
            popread(.t.,"L¡neas por p gina",@nLpp,"99")
            output(dTarget,nLpp,.t.)
          endif
        endif
     endif
   endif
endif
return nil

static func output(dTarget,nLpp,lIsPrinter)
local nLineCount := 0
set console off
set print on
while dtos(dTarget)==__APPT->date
 if nLineCount == 0
    ?"Apuntes para "+dtow(dTarget)
    ?
    ?"Hora      Apunte     "
    ?repl("-",75)
    ?
    nLineCount := 5
 endif
 ?mil2std(__APPT->time)+space(3)+__APPT->desc
 nLineCount++
 if nLineCount == nLpp .and. lIsPrinter
   eject
   nLineCount := 0
 endif
 dbskip(1)
end
if nLineCount > 0 .and. lIsPrinter
  eject
endif
set print off
set printer to
set console on
msg(3,"Terminado")
return nil



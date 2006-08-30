
static cProgressBox



//---------------------------------------------------------------------------
function ProgEval(bBlock,expCondit,cMessage,bMessage,lPause)
local bCondit := iif(valtype(expCondit)=="B",expCondit,&("{||"+iif(empty(expCondit),".t.",expCondit)+"}" ) )
local nOldOrder := indexord()
set order to 0
ProgOn(cMessage)
dbgotop()
DBEVAL(bBlock,bCondit,{||ProgDisp(recno(),recc(),bMessage)} )
ProgDisp(recc(),recc(),bMessage)
if lPause#nil .and. lPause
  @ 17,9 SAY "Terminado - pulse una tecla"
  inkey(0)
endif
ProgOff()
set order to (nOldOrder)
return nil


//---------------------------------------------------------------------------
function ProgCount(expCondit,cMessage,lPause)
local nMatches := 0
local nScanned := 0
local bCondit := iif(valtype(expCondit)=="B",expCondit,&("{||"+iif(empty(expCondit),".t.",expCondit)+"}" ) )
local bMsg := {||alltrim(str(nMatches))+" matches of "+alltrim(str(nScanned++))+" scanned"}
local nOldOrder := indexord()
set order to 0
ProgOn(cMessage)
dbgotop()
DBEVAL({||++nMatches},bCondit,{||ProgDisp(nScanned,recc(),bMsg)} )
ProgDisp(recc(),recc(),bMsg)
if lPause#nil .and. lPause
  @ 17,9 SAY "Terminado - pulse una tecla"
  inkey(0)
endif
ProgOff()
set order to (nOldOrder)
return nMatches

//---------------------------------------------------------------------------

function ProgIndex(cName,cKey,lUnique,lShowCount,lPause)
local bKey := &("{||"+cKey+"}" )
local bMsg := {||alltrim(str(recno()))+" de "+alltrim(str(recc()))}
lUnique    := iif(lUnique#nil,lUnique,.f.)
cKey := iif(!isfield(cKey),cKey,"("+cKey+")")
ProgOn("Creando ¡ndice - "+cName)
if lShowCount
  dbcreateindex(cName,cKey,{||ProgDisp(recno(),recc(),bMsg),eval(bKey)},lUnique)
else
  dbcreateindex(cName,cKey,{||ProgDisp(recno(),recc()),eval(bKey)},lUnique)
endif
if lPause#nil .and. lPause
  @ 17,9 SAY "Terminado - pulse una tecla"
  inkey(0)
endif
ProgOff()
set index to
set index to (cName)
return nil


//-------------------------------------------------------------------
FUNCTION ProgOn(cMessage)
cProgressBox := makebox(9,7,17,70,sls_popcol())
cMessage := iif(cMessage#nil,cMessage,"")
@ 9,9 SAY cMessage
@ 11,12 SAY "0%   10%  20%  30%  40%  50%  60%  70%  80%  90% 100%"
@ 12,12 SAY "ÃÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÄ´"
@ 14,13 SAY "±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±"
return nil

//-------------------------------------------------------------------
FUNCTION ProgOff()
if cProgressBox#nil
  unbox(cProgressBox)
endif
cProgressBox := nil
return nil

//-------------------------------------------------------------------
Function ProgDisp(nCurrent,nTotal,bMessage,bReturn)
local nPercent
if nCurrent#nil .and. nTotal#nil
  nPercent := (nCurrent/nTotal)*100
  @14,13 say padr(repl(chr(219), INT(nPercent/2)  ),50,"±")
endif
if bMessage#nil
  @16,8 say padc(eval(bMessage),62)
endif
if bReturn#nil
  return eval(bReturn)
endif
return .t.


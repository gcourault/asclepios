#include "inkey.ch"
#include "getexit.ch"

//------------------------------------------------------------------------
FUNCTION CALCWHEN(lShowOnUp,lReturn)
local NValue := GETACTIVE():varget()
lReturn   := iif(lReturn#nil,lReturn,.f.)
lShowOnUp := iif(lShowOnUp#nil,lShowOnUp,.f.)
//if !(lastkey()==K_UP .and. !lShowOnUp)
if !(getactive():exitstate==GE_UP .and. !lShowOnUp)
   nValue := getcalc(nValue,.f.)
   if lastkey()#K_ESC .and. nValue # 0
     keyboard alltrim(str(nValue))
     feedkeys()
   ENDIF
endif
return lReturn

//-------------------------------------------------------------------------
FUNCTION CALCVALID(bValid)
local lReturn := .f.
local nValue := GETACTIVE():varget()
if bValid==nil .or. !eval(bValid)
   nValue := GETCALC(nValue,.F.)
   if lastkey()#K_ESC .and. nValue # 0
     keyboard alltrim(str(nValue))
     feedkeys()
     lReturn := iif(bValid#nil,eval(bValid),.t.)
   endif
else
  lReturn := .t.
endif
return lReturn


//---------------------------------------------------------------
static FUNCTION FEEDKEYS
local get := getactive()
local nKey,cKey
get:setfocus()
while (nKey := inkey()) > 0
  cKey := Chr(nKey)
  if (get:type == "N" .and. (cKey == "." .or. cKey == ","))
     get:ToDecPos()
  else
     get:Insert(cKey)
     if (get:typeOut)
        while inkey()<>0
        end
     endif
  endif
end
get:assign()
get:killfocus()
return nil


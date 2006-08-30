#include "getexit.ch"
FUNCTION POPUPWHEN(bPopup,lShowOnUp,lReturn)
local expValue := GETACTIVE():varget()
lReturn   := iif(lReturn#nil,lReturn,.f.)
lShowOnUp := iif(lShowOnUp#nil,lShowOnUp,.f.)
if !(getactive():exitstate==GE_UP .and. !lShowOnUp)
   expValue := eval(bPopup,expValue)
   if expValue#nil
    if valtype(expValue)=="N"
     keyboard alltrim(str(expValue))
     feedkeys()
    else
     GETACTIVE():varput(expValue)
     GETACTIVE():updatebuffer()
    endif
   ENDIF
endif
return lReturn


//-------------------------------------------------------------------------
FUNCTION POPUPVALID(bPopup,bValid)
local lReturn := .f.
local expValue := GETACTIVE():varget()
if bValid==nil .or. !eval(bValid)
   expValue := eval(bPopup,expValue)
   if expValue#nil
     if valtype(expValue)=="N"
      keyboard alltrim(str(expValue))
      feedkeys()
     else
      GETACTIVE():varput(expValue)
      GETACTIVE():updatebuffer()
     endif
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


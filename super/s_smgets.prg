#include "inkey.ch"
#include "getexit.ch"

//------------------------------------------------------------------------
FUNCTION SMALLWHEN(lShowOnUp,lReturn,expDisplayString,cTitle,;
                   expAlias,expReturn,expStartRange,expEndRange,bException)
lReturn   := iif(lReturn#nil,lReturn,.f.)
lShowOnUp := iif(lShowOnUp#nil,lShowOnUp,.f.)
if !(lastkey()==K_UP .and. !lShowOnUp)
   smalls(expDisplayString,cTitle,expAlias,expReturn,;
                   expStartRange,expEndRange,bException)
   if valtype(expReturn)=="C" // must be a KEYBOARD, need to stuff the get
     feedkeys()
   endif
   GETACTIVE():updatebuffer()
   GETACTIVE():display()
endif
return lReturn

//-------------------------------------------------------------------------
FUNCTION SMALLVALID(bValid,expDisplayString,cTitle,;
                   expAlias,expReturn,expStartRange,expEndRange,bException)
local lReturn := .f.
if bValid==nil .or. !eval(bValid)
   smalls(expDisplayString,cTitle,expAlias,expReturn,;
                   expStartRange,expEndRange,bException)
   if lastkey()==K_ENTER
     if valtype(expReturn)=="C" // must be a KEYBOARD, need to stuff the get
       feedkeys()
     endif
     GETACTIVE():updatebuffer()
     GETACTIVE():display()
     lReturn := .t.
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


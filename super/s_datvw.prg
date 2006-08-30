#include "inkey.ch"
#include "getexit.ch"

//------------------------------------------------------------------------
FUNCTION CALENDWHEN(lShowOnUp,lReturn)
local dValue := GETACTIVE():varget()
lReturn   := iif(lReturn#nil,lReturn,.f.)
lShowOnUp := iif(lShowOnUp#nil,lShowOnUp,.f.)
if !(getactive():exitstate==GE_UP .and. !lShowOnUp)
   dValue := getdate(dValue)
   if lastkey()==K_ENTER
     GETACTIVE():varput(dValue)
     GETACTIVE():updatebuffer()
   ENDIF
endif
return lReturn

//-------------------------------------------------------------------------
FUNCTION CALENDVALID(bValid)
local lReturn := .f.
local dValue := GETACTIVE():varget()
if bValid==nil .or. !eval(bValid)
   dValue := GETDATE(dValue)
   if lastkey()==K_ENTER
     GETACTIVE():varput(dValue)
     GETACTIVE():updatebuffer()
     lReturn := iif(bValid#nil,eval(bValid),.t.)
   endif
else
  lReturn := .t.
endif
return lReturn


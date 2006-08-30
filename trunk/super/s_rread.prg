//----------------------------------------------------------------------
#include "inkey.ch"
#include "getexit.ch"
FUNCTION RAT_READ(aGetlist,nStart,lWrap,nRmKey)
local aGetDims := array(len(aGetList))
local i, nOldElement
local nElement := min(iif(nStart#nil,nStart,1),len(aGetList))
local oThisGet
local nLastKey := K_ENTER
local lJumped := .f.
local lReadEx := readexit(.t.)

lWrap := iif(lWrap#nil,lWrap,.f.)
for i = 1 to len(aGetList)
  aGetDims[i] := { aGetlist[i]:row, aGetList[i]:col,aGetList[i]:row,;
                   aGetlist[i]:col+;
                   len(trans(aGetlist[i]:varget(),aGetlist[i]:picture))-1 }
  aGetList[i]:reader := {|g|mreader(g,aGetDims,@nElement,@lJumped,nRmKey,@nLastKey)}
next
DO WHILE .T.
   nOldElement := nElement
   oThisGet := aGetList[nElement]
   lJumped := .f.

   if oThisGet:preblock==nil .or. eval(oThisGet:preblock,oThisGet)
     readmodal({oThisGet})
   endif

   if lJumped .and. aGetList[nElement]:preblock#nil
        if !eval(aGetList[nElement]:preblock,aGetList[nElement])
          nElement := nOldElement
        endif
   endif
   do case
   CASE lJumped
   CASE nLastKey == K_UP       && UP ONE PAGE
     if nElement == 1 .and. !lWrap
       exit
     else
       nElement := iif(nElement==1,len(aGetlist),nElement-1)
     endif
   CASE nLastKey = K_DOWN  .or. nLastKey = K_ENTER
     if nElement == len(aGetlist) .and. !lWrap
       exit
     else
       nElement := iif(nElement==len(aGetlist),1,nElement+1)
     endif
   case nLastkey = K_CTRL_W
     EXIT
   case nLastKey = K_ESC
     EXIT
   endcase
ENDDO
asize(aGetList,0)
readexit(lReadEx)
return nil

//----------------------------------------------------------------------
STATIC function MREADER(oGet,aGetDims,nPosition,lJumped,nRmKey,nKey)
local nMrow,nMcol,nGetFound

oGet:ExitState := GE_NOEXIT
oGet:SetFocus()
while ( oGet:exitState == GE_NOEXIT )
    // check for initial typeout (no editable positions)
    if ( oGet:typeOut )
        oGet:exitState := GE_ENTER
    endif
    // apply keystrokes until exit
    while ( oGet:exitState == GE_NOEXIT )
        nKey := rat_event(0)
        if nKey == 400  // left mouse
           nMrow := rat_eqmrow()
           nMcol := rat_eqmcol()
           if (nGetFound := ascan(aGetDims,{|gd|gd[1]==nMrow .and.;
                (gd[2] <=nMcol .and. gd[4] >=nMcol ) })) > 0
                 if nGetFound<>nPosition
                   nPosition := nGetFound
                   lJumped   := .t.
                   oGet:exitstate := GE_ENTER
                 else
                   while (oGet:col-1+oGet:pos) < nMcol
                     oGet:right()
                     oGet:display()
                   end
                   while (oGet:col-1+oGet:pos) > nMcol
                     oGet:left()
                     oGet:display()
                   end
                 endif
           endif
        elseif nKey == 500 .and. nRmKey#nil  // right mouse
          nKey := nRmKey
          GetApplyKey(oGet,nRmKey)
        else
          GetApplyKey( oGet, nKey )
        endif
    end
    // disallow exit if the VALID condition is not satisfied
   if ( !GetPostValidate(oGet) )
     oGet:exitState := GE_NOEXIT
   end
end
// de-activate the oGet
oGet:KillFocus()
return nKey




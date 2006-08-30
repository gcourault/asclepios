static ismouse
static mouserow         := 0
static mousecol         := 0
*====================================================
function rat_event(timeout,clearkb)
  local key,endsec
  local returnval := 0

  if ismouse==nil
    ismouse    := rat_exist()
  endif
  clearkb  := iif(clearkb==nil,.t.,clearkb)
  timeout  := iif(timeout==nil,5000000,timeout)
  timeout  := iif(timeout==0,5000000,timeout)
  endsec   := seconds()+timeout
  key      := 0
  mouserow := 0
  mousecol := 0

  if ismouse
    rat_on()
  endif

  do while (returnval==0) .and. (seconds() < endsec)
    if ( key := inkey() ) # 0
       if clearkb
        while inkey()#0
        end
       endif
       returnval := key
    elseif ismouse
      if rat_leftb()
         mouserow := rat_rowl()
         mousecol := rat_coll()
         returnval := 400
      elseif rat_rightb()
         mouserow := rat_rowr()
         mousecol := rat_colr()
         returnval := 500
      endif
    endif
  enddo
  if ismouse
    rat_off()
  endif

return returnval

*====================================================
function rat_elbhd(secs)      && is left button held down
local i
local hd := .f.
local start := seconds()
secs := iif(secs#nil,secs,.1)
while seconds()-start <secs .and. (hd := rat_lbhd())
end
return hd
*====================================================
function rat_erbhd(secs)       && is right button held down
local i
local hd    := .f.
local start := seconds()
secs := iif(secs#nil,secs,.1)
while seconds()-start <secs .and. (hd := rat_rbhd())
end
return hd
*====================================================
function rat_eqmrow()     && return mouse row at last mouse event
return mouserow
*====================================================
function rat_eqmcol()     && return mouse column at last mouse event
return mousecol
*====================================================
function rat_ismouse(imoose)
ismouse := iif(imoose#nil,imoose,ismouse)
return ismouse


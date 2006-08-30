//---------------------------------------------------------

function savesetkeys(lClear)
local akSaved := {}
local bSaved
local i
lClear := iif(lClear#nil,lClear,.f.)
for i = -40 to 310
  if (bSaved := setkey(i))#nil
    aadd(akSaved,{i,bSaved})
    if lClear
      setkey(i,nil)
    endif
  endif
next
return akSaved
//---------------------------------------------------------
function restsetkeys(akSaved)
local i
for i = 1 to len(akSaved)
  setkey(aksaved[i,1],akSaved[i,2])
next
return nil



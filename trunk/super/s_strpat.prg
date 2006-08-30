FUNCTION STRIP_PATH(cInPath, lStripExt)
local cOutSpec

cOutSpec := cInPath
if "\"$cInPath
   cOutSpec := subst(cInPath,RAT("\",cInPath)+1)
elseif ":"$cInPath
   cOutSpec := subst(cInPath,RAT(":",cInPath)+1)
endif

if lStripExt .and. "."$cOutSpec
   cOutSpec := subst(cOutSpec,1,AT(".",cOutSpec)-1)
endif

return cOutSpec




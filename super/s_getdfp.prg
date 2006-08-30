Function getdfp
local cDefaultPath := alltrim(SET(_SET_DEFAULT))
* is it empty?
if !empty(cDefaultPath)
    * is there a "\" on the end?
    if right(cDefaultPath,1)#"\"
      cDefaultPath += "\"
    endif
endif
return cDefaultPath






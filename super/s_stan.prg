FUNCTION standard
local cColorsFore := "N...B...G...BG..R...BR..GR..W...N+..B+..G+..BG+.R+..BR+.GR+.W+.."
local cColorsBack := "N...B...G...BG..R...BR..GR..W...N*..B*..G*..BG*.R*..BR*.GR*.W*.."
local cSetcolor   := takeout(Setcolor(),",",1)
local cForeGround := takeout(cSetcolor,"/",1)
local cBackGround := takeout(cSetcolor,"/",2)
local nForeGround := int((AT(cForeGround,cColorsFore)-1)/4)
local nBackGround := int(((AT(cBackGround,cColorsBack)-1)/4)*16)
RETURN INT((nBackGround+nForeGround))


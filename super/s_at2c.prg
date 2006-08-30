Function At2char(nColor)
local aFore   := {"N","B","G","BG","R","RB","GR","W",;
                  "N+","B+","G+","BG+","R+","RB+","GR+","W+"}
local aBack   := {"N","B","G","BG","R","RB","GR","W",;
                  "N*","B*","G*","BG*","R*","RB*","GR*","W*"}
local nFore         := nColor%16
local nBack         := INT(nColor/16)
local cForeground   := aFore[nFore+1]
local cBackGround   := aBack[nBack+1]
return ( cForeground+'/'+cBackGround )


FUNCTION cls(ncColorAtt,cFillCharacter)
local cColorString
cColorString   := iif(valtype(ncColorAtt)=="N",at2char(ncColorAtt),ncColorAtt)
cFillCharacter := repl( iif(cFillCharacter#nil,cFillCharacter," "),9 )
dispbox(0,0,maxrow(),maxcol(),cFillCharacter,cColorString)
RETURN ''


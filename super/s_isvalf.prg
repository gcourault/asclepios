FUNCTION ISVALFILE(cName,lCheckDup,cMessage)
local lValid := .t.
lCheckDup := iif(lCheckDup#nil,lCheckDup,.f.)
cMessage  := ""
do case
case  empty(cName)
  lValid := .f.
  cMessage := "El nombre del archivo est  vac¡o"
case !allowed(cName,@cMessage)
  lValid := .f.
case lCheckDup .and. file(cName)
  lValid := .f.
  cMessage := "Existe archivo duplicado"
endcase
return lValid



static function allowed(cName,cMessage)
local lAllowed := .t.
local cAllowed := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_^$~!#%&-{}()@'`."
local nChar

cName := upper(alltrim(cName))
while .t.
  if len(trim(cName)) > 12
    lAllowed := .f.
    cMessage := "El nombre del archivo es muy largo"
    exit
  elseif "."$cName
    if at(".", strtran(cName,".","",1,1) )> 0
      // double dots
      lAllowed := .f.
      cMessage := "Demasiados puntos"
      exit
    elseif len( subst(cName,at(".",cName)) ) > 4
      // too many characters after the period
      lAllowed := .f.
      cMessage := "Demasiados caracteres despu‚s del punto"
      exit
    elseif len(subst(cName,1,at(".",cName)-1)) > 8
      lAllowed := .f.
      cMessage := "Demasiados caracteres antes del punto"
      exit
    endif
  elseif !"."$cName .and. len(cName) > 8
      lAllowed := .f.
      cMessage := "Demasiados caracteres sin punto"
      exit
  endif
  for nChar = 1 to len(cName)
   if !subst(cName,nChar,1)$cAllowed
     lAllowed := .f.
     cMessage := "Caracter inv lido: "+subst(cName,nChar,1)
     exit
   endif
  next
  if cName=="CLOCK$" .or. cName=="CON" .or. cName=="AUX" .or. cName=="COM1" ;
    .or. cName=="COM2" .or. cName=="COM3" .or. cName == "COM4" ;
    .or. cName=="LPT1" .or. cName=="LPT2" .or. cName == "LPT3" ;
    .or. cName=="NUL" .or. cName=="PRN2"
    lAllowed := .f.
    cMessage := "Nombre de archivo ilegal"
  ENDIF
  exit
end
return lAllowed


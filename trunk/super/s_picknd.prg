FUNCTION pickndx(aIndexes)
local I
local bOldF10 := setkey(-9,{||kbdesc()})
local cPopbox,nThisPick,cIndexName,cThisKey
local cIndexExt := '*'+INDEXEXT()
local nFoundIndexes := adir(cIndexExt)
local aFoundIndexes := array(nFoundIndexes)

IF !VALTYPE(aIndexes)=="A" .OR. !used()
  if !used()
    msg("Database required")
  endif
  RETURN ''
ELSE
  asize(aIndexes,0)
ENDIF

Adir(cIndexExt,aFoundIndexes)
Asort(aFoundIndexes)

*- set up temp array for marking selected aIndexes
plswait(.T.,"Buscando Indices...")
for i = 1 TO nFoundIndexes
  aFoundIndexes[i] = padr(aFoundIndexes[i],12)+" key->>"+nkey(aFoundIndexes[i])
NEXT
plswait(.F.)


*- draw the box
cPopbox := makebox(1,10,17,60,sls_popcol())
@1,22 SAY  "*-Selecciona/Deselecciona Indices-*"
@17,22 SAY "*-Pulse F10 para salir           -*"
nThisPick := 1
DO WHILE .T.
  *- get a selection
  nThisPick := SACHOICE(2,11,16,59,aFoundIndexes,NIL,nThisPick)
  IF nThisPick = 0
    EXIT
  ENDI
  *- if its not already marked, mark it
  IF LEFT(aFoundIndexes[nThisPick],2)<>"û "
    cIndexName := TRIM(LEFT(aFoundIndexes[nThisPick],12))
    
    *- get index key to test
    cThisKey := Alltrim(nkey(cIndexName))
    if !empty(cThisKey)
      IF !(TYPE(cThisKey)== "U" .OR. TYPE(cThisKey) == "UE")
        aadd(aIndexes, aFoundIndexes[nThisPick])
        aFoundIndexes[nThisPick] := 'û '+aFoundIndexes[nThisPick]
      ELSE
        msg("Este ¡ndice no coincide con la DBF","o este programa no tiene la funci¢n necesaria","en la expresi¢n del ¡ndice")
      ENDIF
    elseif messyn("No se puede verificar la consistencia dbf/ntx. ¨Lo abre de todas formas?")
        aadd(aIndexes, aFoundIndexes[nThisPick])
        aFoundIndexes[nThisPick] := 'û '+aFoundIndexes[nThisPick]
    endif
  ELSE
    aFoundIndexes[nThisPick] := SUBST(aFoundIndexes[nThisPick],3)
    adel(aIndexes, Ascan(aIndexes,aFoundIndexes[nThisPick]) )
    asize(aIndexes,len(aIndexes)-1)
  ENDIF
ENDDO
for i = 1 TO len(aIndexes)
  aIndexes[i] = TRIM(LEFT(aIndexes[i],12))
NEXT
setkey(-9,bOldF10)
unbox(cPopbox)
openind(aIndexes)
RETURN ''



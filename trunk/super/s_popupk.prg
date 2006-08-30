
static aAssigns := {}
//-----------------------------------------------------
FUNCTION POPUPKCLR()
local i
for i = 1 to len(aAssigns)  // clear the SET KEYs
  setkey(aAssigns[i,1])
next
aAssigns := {}
return nil

//------------------------------------------------------------
FUNCTION POPUPKSET(nKey,cProc,cVar,bPopup)
aadd(aAssigns,{nKey,upper(cProc),upper(cVar),bPopup})
SetKey( nKey, {|p, l, v| POPUPKEY(UPPER(p), l, UPPER(v))} )
return nil


//------------------------------------------------------------
STATIC FUNCTION POPUPKEY(cProc,garbage,cVar)
local nfound
local aThis
local cValue
local expValue
local nKey := lastkey()
if (nFound := ascan(aAssigns,{|e|e[1]==nKey.and.e[2]==cProc.and.e[3]==cVar}) )> 0
   expValue := getactive():varget()
   expValue := eval(aAssigns[nFound,4],expValue)
   if expValue#nil
    if valtype(expValue)=="N"
     keyboard alltrim(str(expValue))
     feedkeys()
    else
     GETACTIVE():varput(expValue)
     GETACTIVE():updatebuffer()
    endif
   endif
endif
return nil


//---------------------------------------------------------------
static FUNCTION FEEDKEYS
local get := getactive()
local nKey,cKey
get:setfocus()
while (nKey := inkey()) > 0
  cKey := Chr(nKey)
  if (get:type == "N" .and. (cKey == "." .or. cKey == ","))
     get:ToDecPos()
  else
     get:Insert(cKey)
     if (get:typeOut)
        while inkey()<>0
        end
     endif
  endif
end
get:assign()
get:killfocus()
return nil



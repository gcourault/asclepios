
static aAssigns := {}
//-----------------------------------------------------
FUNCTION CALCKCLR()
local i
for i = 1 to len(aAssigns)  // clear the SET KEYs
  setkey(aAssigns[i,1])
next
aAssigns := {}
return nil

//------------------------------------------------------------
FUNCTION CALCKSET(nKey,cProc,cVar,lAssign)
lAssign := iif(lAssign#nil,lAssign,.f.)
aadd(aAssigns,{nKey,upper(cProc),upper(cVar),lAssign})
SetKey( nKey, {|p, l, v| CALCKEY(UPPER(p), l, UPPER(v))} )
return nil


//------------------------------------------------------------
STATIC FUNCTION CALCKEY(cProc,garbage,cVar)
local nfound
local aThis
local cValue
local nValue := 0
local nKey := lastkey()
if (nFound := ascan(aAssigns,{|e|e[1]=nKey.and.e[2]==cProc.and.e[3]==cVar}) )> 0
   if aAssigns[nFound,4]
     nValue := getactive():varget()
   endif
   cValue := GETCALC(nValue)
   if aAssigns[nFound,4] .AND. lastkey()#27 .and. val(cValue)#0
     if messyn("Accept value:",cValue)
       keyboard cValue
     endif
   endif
endif
return nil



static aAssigns := {}
//-----------------------------------------------------
FUNCTION CALENDKCLR()
local i
for i = 1 to len(aAssigns)  // clear the SET KEYs
  setkey(aAssigns[i,1])
next
aAssigns := {}
return nil

//------------------------------------------------------------
FUNCTION CALENDKSET(nKey,cProc,cVar,lAssign)
lAssign := iif(lAssign#nil,lAssign,.f.)
aadd(aAssigns,{nKey,upper(cProc),upper(cVar),lAssign})
SetKey( nKey, {|p, l, v| CALENDKEY(UPPER(p), l, UPPER(v))} )
return nil


//------------------------------------------------------------
STATIC FUNCTION CALENDKEY(cProc,garbage,cVar)
local nfound
local aThis
local dValue := date()
local nKey := lastkey()
if (nFound := ascan(aAssigns,{|e|e[1]=nKey.and.e[2]==cProc.and.e[3]==cVar}) )> 0
   if aAssigns[nFound,4]
     dValue := getactive():varget()
   endif
   dValue := GETDATE(dValue)
   if aAssigns[nFound,4] .and. lastkey()#27
     if multimsgyn({"Aceptar valor:",dtoc(dValue)})
       getactive():varput(dValue)
       getactive():updatebuffer()
     endif
   endif
endif
return nil


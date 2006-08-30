static aAssigns := {}

//-----------------------------------------------------
FUNCTION SMALLKCLR()
local i
for i = 1 to len(aAssigns)  // clear the SET KEYs
  setkey(aAssigns[i,1])
next
aAssigns := {}
return nil

//------------------------------------------------------------
FUNCTION SMALLKSET(nKey,cProc,cVar,expDisplayString,cTitle,;
           expAlias,expReturn,expStartRange,expEndRange,bException)
aadd(aAssigns,{nKey,upper(cProc),upper(cVar),expDisplayString,cTitle,;
               expAlias,expReturn,expStartRange,expEndRange,bException})
SetKey( nKey, {|p, l, v| SMALLKEY(UPPER(p), l, UPPER(v))} )
return nil


//------------------------------------------------------------
static FUNCTION SMALLKEY(cProc,garbage,cVar)
local nfound
local aThis
local nKey := lastkey()
if (nFound := ascan(aAssigns,{|e|e[1]=nKey.and.e[2]==cProc.and.e[3]==cVar}) )> 0
   aThis := aAssigns[nFound]
   SMALLS(aThis[4],aThis[5],aThis[6],aThis[7],aThis[8],aThis[9],aThis[10])
endif
return nil


FUNCTION prnport(dev1,dev2,dev3,dev4,dev5,dev6,dev7,dev8,dev9)
local cDevice,cUnder,nTop,nBottom,nIter,nSelection
local aDevSet := {}

if pcount() > 0
  aDevSet := prnpset(dev1,dev2,dev3,dev4,dev5,dev6,dev7,dev8,dev9)
endif
if len(aDevset)=0
  aDevset := {"LPT1","LPT2","LPT3"}
endif

nTop    :=8
nBottom :=nTop+len(aDevset)+1
cUnder  := makebox(nTop,30,nBottom,46,sls_popcol())
cDevice := "LPT1"
@nTop,32 SAY '[Puerto de Impresora]'
for nIter = 1 TO len(aDevset)
  @ROW()+1,34 PROMPT aDevset[nIter]
NEXT
MENU TO nSelection
IF nSelection > 0
  SET PRINTER TO (aDevset[nSelection])
  sls_prn(aDevset[nSelection])
ELSE
  SET PRINTER TO
ENDIF
unbox(cUnder)
RETURN ( sls_prn() )

static FUNCTION PRNPSET(dev1,dev2,dev3,dev4,dev5,dev6,dev7,dev8,dev9)
local aDevset := {dev1,dev2,dev3,dev4,dev5,dev6,dev7,dev8,dev9}
while atail(aDevset)==nil .and. len(aDevset)>0
  asize(aDevset,len(aDevset)-1)
end
return aDevset

*: EOF: S_PRNPOR.PRG


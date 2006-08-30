# include "box.ch"
static dbfstruc := {;
                     { "SETNAME",  "C", 40, 0 },;
                     { "DMAINCOL",  "C", 40, 0 },;
                     { "DMAINMENU", "C", 40, 0 },;
                     { "DPOPCOL", "C", 40, 0 },;
                     { "DPOPMENU", "C", 40, 0 },;
                     { "DFRAME", "C", 40, 0 },;
                     { "DSHADATT", "N", 3, 0 },;
                     { "DSHADPOS", "N", 1, 0 },;
                     { "DEXPLODE", "L", 1, 0 }       }
static cReportDbf               := 'SFREPORT'
static cFormDbf                 := 'FORM'
static cQueryDbf                := 'QUERIES'
static cHelpDbf                 := 'HELP'
static cListDbf                 := 'PLIST'
static cScrollDbf               := 'SCROLLER'
static cColorDbf                := 'COLORS'
static cTodoDbf                 := 'TODO'
static cTodoNtx1                := 'TODO'
static cTodoNtx2                := 'TODOP'
static cTodoNtx3                := 'TODOD'
static cLabelDbf                := 'CLABELS'
static cAppt                    := 'APPOINT'
static lIsColor                 := nil
static cMainColor               :=  'W/N,N/W,,,+W/N'
static cMainMenuColor           :=  'W/N,N/W,,,+W/N'
static cPopupColor              :=  'N/W,+W/N,,,W/N'
static cPopupMenuColor          :=  'N/W,W/N,,,+W/N'
* static cFrameString             := "旼엿耗윰 "
static cFrameString		:= B_SINGLE
static nShadowAtt               := 8
static nShadowPos               := 1
static lExplodeBoxes            := .T.
static cDefPrinter              := 'LPT1'
static lCheckPrnStat            := .T.
static cQueryExp                := ''
static bQueryBlock              := nil
static aStacks                  := {}


//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
FUNCTION SLSF_REPORT(cNew)
return (cReportDbf := iif(cNew#nil,cNew,cReportDbf) )

FUNCTION SLSF_FORM(cNew)
return (cFormDbf := iif(cNew#nil,cNew,cFormDbf) )

FUNCTION SLSF_QUERY(cNew)
return (cQueryDbf := iif(cNew#nil,cNew,cQueryDbf) )

FUNCTION SLSF_HELP(cNew)
return (cHelpDbf := iif(cNew#nil,cNew,cHelpDbf) )

FUNCTION SLSF_LIST(cNew)
return (cListDbf := iif(cNew#nil,cNew,cListDbf) )

FUNCTION SLSF_SCROLL(cNew)
return (cScrollDbf := iif(cNew#nil,cNew,cScrollDbf) )

FUNCTION SLSF_COLOR(cNew)
return (cColorDbf := iif(cNew#nil,cNew,cColorDbf) )

FUNCTION SLSF_TODO(cNew)
return (cTodoDbf := iif(cNew#nil,cNew,cTodoDbf) )

FUNCTION SLSF_TDN1(cNew)
return (cTodoNtx1 := iif(cNew#nil,cNew,cTodoNtx1) )

FUNCTION SLSF_TDN2(cNew)
return (cTodoNtx2 := iif(cNew#nil,cNew,cTodoNtx2) )

FUNCTION SLSF_TDN3(cNew)
return (cTodoNtx3 := iif(cNew#nil,cNew,cTodoNtx3) )

FUNCTION SLSF_APPT(cNew)
return (cAppt := iif(cNew#nil,cNew,cAppt) )

FUNCTION SLSF_LABEL(cNew)
return (cLabelDbf := iif(cNew#nil,cNew,cLabelDbf) )


FUNCTION SLS_ISCOLOR(lNew)
lIsColor := iif(lIsColor==nil,iscolor(),lIsColor)
return (lIsColor := iif(lNew#nil,lNew,lIsColor) )

FUNCTION SLS_NORMCOL(cNew)
return (cMainColor := iif(cNew#nil,cNew,cMainColor) )

FUNCTION SLS_NORMMENU(cNew)
return (cMainMenuColor := iif(cNew#nil,cNew,cMainMenuColor) )

FUNCTION SLS_POPCOL(cNew)
return (cPopupColor := iif(cNew#nil,cNew,cPopupColor) )

FUNCTION SLS_POPMENU(cNew)
return (cPopupMenuColor := iif(cNew#nil,cNew,cPopupMenuColor) )

FUNCTION SLS_FRAME(cNew)
return (cFrameString := iif(cNew#nil,cNew,cFrameString) )

FUNCTION SLS_SHADATT(nNew)
return (nShadowAtt := iif(nNew#nil,nNew,nShadowAtt) )

FUNCTION SLS_SHADPOS(nNew)
return (nShadowPos := iif(nNew#nil,nNew,nShadowPos) )

FUNCTION SLS_XPLODE(lNew)
return (lExplodeBoxes := iif(lNew#nil,lNew,lExplodeBoxes) )

FUNCTION SLS_PRN(cNew)
return (cDefPrinter := iif(cNew#nil,cNew,cDefPrinter) )

FUNCTION SLS_PRNC(lNew)
return (lCheckPrnStat := iif(lNew#nil,lNew,lCheckPrnStat) )

FUNCTION SLS_QUERY(cNew)
return (cQueryExp := iif(cNew#nil,cNew,cQueryExp) )

FUNCTION SLS_BQUERY(bNew)
return (bQueryBlock := iif(bNew#nil,bNew,bQueryBlock) )

FUNCTION SLS_BQZAP()
bQueryBlock := nil
return nil


//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Function SattColor()
     IF FILE(cColorDbf+".DBF")
       SattGet("DEFAULT")
     ELSE
       cMainColor      :=  'W/B,GR+/R,,,W/N'
       cMainMenuColor  :=  'W/B,N/R,,,W/N'
       cPopupColor     :=  'N/BG,N/W,,,BG+/N'
       cPopupMenuColor :=  'N/BG,W+/N,,,BG+/N'
       * cFrameString    := "旼엿耗윰 "
       cFrameString    := B_SINGLE
       nShadowAtt      := 7
       nShadowPos      := 1
       lExplodeBoxes   := .T.
     ENDIF
return nil

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Function SattMono()
     cMainColor         :=  'W/N,N/W,,,+W/N'
     cMainMenuColor     :=  'W/N,N/W,,,+W/N'
     cPopupColor        :=  'N/W,+W/N,,,W/N'
     cPopupMenuColor    :=  'N/W,W/N,,,+W/N'
     * cFrameString       := "旼엿耗윰 "
     cFrameString	:= B_SINGLE
     nShadowAtt         := 8
     nShadowPos         := 1
     lExplodeBoxes      := .T.
return nil

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Function SattDirect(cpMainColor,cpMainMenuColor,cpPopupColor,cpPopupMenuColor,;
                    cpFrameString,npShadowAtt,npShadowPos,lpExplodeBoxes)
     cMainColor        := iif(cpMainColor#nil,cpMainColor,cMainColor)
     cMainMenuColor    := iif(cpMainMenuColor#nil,cpMainMenuColor,cMainMenuColor)
     cPopupColor       := iif(cpPopupColor#nil,cpPopupColor,cPopupColor)
     cPopupMenuColor   := iif(cpPopupMenuColor#nil,cpPopupMenuColor,cPopupMenuColor)
     cFrameString      := iif(cpFrameString#nil,cpFrameString,cFrameString)
     nShadowAtt        := iif(npShadowAtt#nil,npShadowAtt,nShadowAtt)
     nShadowPos        := iif(npShadowPos#nil,npShadowPos,nShadowPos)
     lExplodeBoxes     := iif(lpExplodeBoxes#nil,lpExplodeBoxes,lExplodeBoxes)
return nil

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Function SattGetMem(cFileName)   // get from old COLORS.MEM
memvar c_normcol,c_normmenu,c_popcol,c_popmenu,c_frame
memvar c_shadatt,c_shadpos,c_xplode
if file(cFileName)
  restore from (cFileName) additive
  cMainColor      :=  iif(c_normcol#nil,c_normcol,cMainColor)
  cMainMenuColor  :=  iif(c_normmenu#nil,c_normmenu,cMainMenuColor)
  cPopupColor     :=  iif(c_popcol#nil,c_popcol,cPopupColor)
  cPopupMenuColor :=  iif(c_popmenu#nil,c_popmenu,cPopupMenuColor)
  cFrameString    :=  iif(c_frame#nil,c_frame,cFrameString)
  nShadowAtt      :=  iif(c_shadatt#nil,c_shadatt,nShadowAtt)
  nShadowPos      :=  iif(c_shadpos#nil,c_shadpos,nShadowPos)
  lExplodeBoxes   :=  iif(c_xplode#nil,c_xplode,lExplodeBoxes)
endif
return nil

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Function SattGet(cSetName)   // get from DBF
field SETNAME,DMAINCOL,DMAINMENU,DPOPCOL,DPOPMENU,DFRAME
field DSHADATT,DSHADPOS,DEXPLODE
local lSuccess := .f.
local nOldarea := select()
local cFileName := slsf_color()+".DBF"
cSetName := iif(cSetName==nil,"DEFAULT",cSetName)
select 0
IF file(cFileName) .and. SNET_USE(cFileName,,.F.,5,.F.)
  locate for trim(SETNAME)==cSetName
  if found()
   cMainColor      :=    DMAINCOL
   cMainMenuColor  :=    DMAINMENU
   cPopupColor     :=    DPOPCOL
   cPopupMenuColor :=    DPOPMENU
   cFrameString    :=    DFRAME
   nShadowAtt      :=    DSHADATT
   nShadowPos      :=    DSHADPOS
   lExplodeBoxes   :=    DEXPLODE

   lSuccess    := .t.

  endif
  USE
endif
select (nOldarea)
return (lSuccess)

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Function SattPut(cSetName)   // write to DBF
field SETNAME,DMAINCOL,DMAINMENU,DPOPCOL,DPOPMENU,DFRAME
field DSHADATT,DSHADPOS,DEXPLODE
local lSuccess := .f.
local nOldarea := select()
local cFileName := slsf_color()+".DBF"
cSetName := padr(iif(cSetName==nil,"DEFAULT",cSetName),40)

if !file(cFileName)
   dbcreate(cFileName,dbfstruc)
endif
select 0
IF SNET_USE(cFileName,,.F.,5,.F.)
  locate for SETNAME==cSetName
  IF (!found().and.SADD_REC(5,.F.)) .or. (found() .and. SREC_LOCK(5,.F.) )
     SETNAME     := cSetName
     DMAINCOL    := cMainColor
     DMAINMENU   := cMainMenuColor
     DPOPCOL     := cPopupColor
     DPOPMENU    := cPopupMenuColor
     DFRAME      := cFrameString
     DSHADATT    := nShadowAtt
     DSHADPOS    := nShadowPos
     DEXPLODE    := lExplodeBoxes

     lSuccess    := .t.
  ENDIF
  UNLOCK
  USE
ENDIF
select (nOldarea)
return (lSuccess)

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Function SattPick()   // get from DBF
field SETNAME,DMAINCOL,DMAINMENU,DPOPCOL,DPOPMENU,DFRAME
field DSHADATT,DSHADPOS,DEXPLODE
local nOldarea := select()
local nSelection,aSelections,i
local cFileName := slsf_color()+".DBF"

select 0
IF file(cFileName) .and. SNET_USE(cFileName,,.F.,5,.F.) .and. recc() > 0
  aSelections := array(recc())
  for i = 1 to recc()
    go i
    aSelections[i] := SETNAME
  next
  nSelection := mchoice(aSelections,5,15,19,65,"Select Color Set")
  if nSelection > 0
   go (nSelection)
   cMainColor      :=    DMAINCOL
   cMainMenuColor  :=    DMAINMENU
   cPopupColor     :=    DPOPCOL
   cPopupMenuColor :=    DPOPMENU
   cFrameString    :=    DFRAME
   nShadowAtt      :=    DSHADATT
   nShadowPos      :=    DSHADPOS
   lExplodeBoxes   :=    DEXPLODE
  endif
else
  msg("No Store color sets here")
endif
use
select (nOldarea)
return nil

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Function SattPickPut()   // write to DBF
field SETNAME,DMAINCOL,DMAINMENU,DPOPCOL,DPOPMENU,DFRAME
field DSHADATT,DSHADPOS,DEXPLODE
local nOldarea := select()
local nSelection,aSelections,i
local cFileName := slsf_color()+".DBF"
local cSetName := padr(iif(cSetName==nil,"DEFAULT",cSetName),40)
if !file(cFileName)
   dbcreate(cFileName,dbfstruc)
   sAttPut(cSetNAme)
endif

select 0
IF SNET_USE(cFileName,,.F.,5,.F.) .and. recc() > 0
  aSelections := {"<new>"}
  for i = 1 to recc()
    go i
    aadd(aSelections,SETNAME)
  next
  use
  nSelection := mchoice(aSelections,5,15,19,65,"Select Color Set Name")
  if nSelection > 1
    sAttPut(aSelections[nSelection] )
  elseif nSelection = 1
    popread(.t.,"Enter a description for this color set:",@cSetName,"")
    sAttPut(cSetName)
  endif
else
  msg("No stored color sets here")
endif
select (nOldarea)
return nil

//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Function SattPickDel()   // pick delete color sets
field SETNAME,DMAINCOL,DMAINMENU,DPOPCOL,DPOPMENU,DFRAME
field DSHADATT,DSHADPOS,DEXPLODE
local nOldarea := select()
local nSelection,aSelections,aRecnos,i
local cFileName := slsf_color()+".DBF"
local cSetName := padr(iif(cSetName==nil,"DEFAULT",cSetName),40)
aSelections := {}
aRecnos     := {}
if !file(cFileName)
   msg("No color sets stored")
else
  select 0
  IF SNET_USE(cFileName,,.F.,5,.F.) .and. recc() > 0
    for i = 1 to recc()
      go i
      if !deleted()
        aadd(aSelections,SETNAME)
        aadd(aRecnos,recno())
      endif
    next
    nSelection := mchoice(aSelections,5,15,19,65,"Select color set to delete")
    if nSelection > 0
      go (aRecnos[nSelection])
      if srec_lock(5,.t.,"Unable to lock record, keep trying?")
        DBDELETE()
      endif
    endif
  else
    msg("No Store color sets here")
  endif
  use
endif
select (nOldarea)
return nil


//------------------------------------------------------------
FUNCTION sAttPush
aadd(aStacks, {;
                 sls_normcol(),;
                 sls_normmenu(),;
                 sls_popcol(),;
                 sls_popmenu(),;
                 sls_shadatt(),;
                 sls_shadpos(),;
                 sls_xplode() } )
RETURN nil

//------------------------------------------------------------
FUNCTION sAttPop
local aOldSet
if len(aStacks) > 0
  aOldSet := atail(aStacks)
  sls_normcol(aOldSet[1])
  sls_normmenu(aOldSet[2])
  sls_popcol(aOldSet[3])
  sls_popmenu(aOldSet[4])
  sls_shadatt(aOldSet[5])
  sls_shadpos(aOldSet[6])
  sls_xplode(aOldSet[7])
  asize(aStacks,len(aStacks)-1)
endif
RETURN ''


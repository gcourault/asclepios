//------------------------------------------------------------------------
#include "getexit.ch"
#include "inkey.ch"
#define K_PLUS  43
#define K_MINUS 45
#define K_SPACE 32

MEMVAR getlist
//-----------------------------------------------------------------------
function PMreader()
return {|g|_pmreader(g)}

//-----------------------------------------------------------------------
function SBreader(aValues)
return {|g|_sbreader(g,aValues)}

//-----------------------------------------------------------------------
function YNreader()
return {|g|_ynreader(g)}

//-----------------------------------------------------------------------
function pickreader(aPop,nTop,nLeft,nBottom,nRight)
return {|g|_pickreader(g,aPop,nTop,nLeft,nBottom,nRight)}

//-----------------------------------------------------------------------

function genReader(bBlock, lPass)  // generic reader
return {|g|_genreader(g,bBlock,lPass) }
//-----------------------------------------------------------------------

static function _PMReader( oGet )  // PLUS/MINUS reader
local nLastkey
if ( GetPreValidate(oGet) )
  oGet:SetFocus()
  while ( oGet:exitState == GE_NOEXIT )
    if ( oGet:typeOut )
            oGet:exitState := GE_ENTER
    endif
    while ( oGet:exitState == GE_NOEXIT )
         nLastkey := inkey(0)
         do case
         case nLastkey == K_PLUS .and. oGet:type=="N"
           oGet:varput(val(oGet:buffer)+1)
           oGet:updatebuffer()
           oGet:display()
         case nLastkey == K_MINUS .and. oGet:type=="N"
           oGet:varput(val(oGet:buffer)-1)
           oGet:updatebuffer()
           oGet:display()
         case nLastkey == K_PLUS .and. oGet:type=="D"
           if empty(oGet:varget())
             oGet:varput(date())
           else
             oGet:varput(ctod(oGet:buffer)+1)
           endif
           oGet:updatebuffer()
           oGet:display()
         case nLastkey == K_MINUS .and. oGet:type=="D"
           if empty(oGet:varget())
             oGet:varput(date())
           else
             oGet:varput(ctod(oGet:buffer)-1)
           endif
           oGet:updatebuffer()
           oGet:display()
         otherwise
            GetApplyKey( oGet, nLastKey )
         endcase
    end
    if ( !GetPostValidate(oGet) )
            oGet:exitState := GE_NOEXIT
    endif
  end
  oGet:KillFocus()
endif
return nil

//-------------------------------------------------------------------
static function _sbReader( oGet,aValues )  // space bar reader
local nStart
local nLastKey
if ( GetPreValidate(oGet) )
  oGet:SetFocus()
  nStart := max(1,ascan(aValues,oGet:varget()) )
  while ( oGet:exitState == GE_NOEXIT )
    if ( oGet:typeOut )
            oGet:exitState := GE_ENTER
    endif
    while ( oGet:exitState == GE_NOEXIT )
         nLastkey := inkey(0)
         do case
         case nLastkey == K_SPACE .and. aValues#nil
           if nStart = len(aValues)
             nStart := 1
           else
             nStart++
           endif
           if valtype(aValues[nStart])==oGet:type
             if oGet:type$"LDN"
               oGet:varput(aValues[nStart])
               oGet:updatebuffer()
               oGet:display()
             else
               oGet:buffer := padr(aValues[nStart],len(oGet:buffer))
               oGet:assign()
               oGet:display()
             endif
           endif
         otherwise
            GetApplyKey( oGet, nLastKey )
         endcase
    end
    if ( !GetPostValidate(oGet) )
            oGet:exitState := GE_NOEXIT
    endif
  end
  oGet:KillFocus()
endif
return nil

//-------------------------------------------------------------------
static function _ynReader( oGet)  // yn reader
local nTop:= oGet:row,nLeft:= oGet:col
local cBox
local nYesNo := iif(oGet:varget(),1,2)
local nInExit := oGet:exitstate
local nLastKey
if nInExit == GE_DOWN
  nInExit := GE_ENTER
endif
while nLeft +4 > maxcol()
  nLeft--
end
while nTop + 3 > maxrow()
  nTop--
end
if ( GetPreValidate(oGet) )
  oGet:SetFocus()
  while ( oGet:exitState == GE_NOEXIT )
    if ( oGet:typeOut )
            oGet:exitState := GE_ENTER
    endif
    cBox := makebox(nTop,nLeft,nTop+3,nLeft+4)
    @nTop+1,nLeft+1 prompt "Si"
    @nTop+2,nLeft+1 prompt "No"
    menu to nYesNo
    unbox(cBox)
    if !lastkey()=27
      oGet:varput(iif(nYesNo==1,.t.,.f.))
      oGet:updatebuffer()
      oGet:display()
    endif
    oGet:exitstate := nInExit
    if ( !GetPostValidate(oGet) )
            oGet:exitState := GE_NOEXIT
    endif
  end
  oGet:KillFocus()
endif
return nil

//-------------------------------------------------------------------
static function _genReader( oGet,bBlock, lPass)  // generic reader
local expReturn
local nLastKey
lPass   := iif(lPass#nil,lPass,.t.)
if ( GetPreValidate(oGet) )
  oGet:SetFocus()
  while ( oGet:exitState == GE_NOEXIT )
    if ( oGet:typeOut )
            oGet:exitState := GE_ENTER
    endif
    while ( oGet:exitState == GE_NOEXIT )
         nLastkey := inkey(0)
         do case
         case (oGet:assign(),expReturn := eval(bBlock,nLastkey,procname(3),readvar(),oGet:varget() ) )#nil
              if valtype(expReturn)==oGet:type
                if oGet:type$"LDN"
                  oGet:varput(expReturn)
                  oGet:updatebuffer()
                  oGet:display()
                else
                  oGet:home()
                  oGet:buffer := padr(expReturn,len(oGet:buffer))
                  oGet:display()
                  oGet:assign()
                  oGet:end()
                endif
              endif
         otherwise
           if lPass
              GetApplyKey( oGet, nLastKey )
           elseif nLastkey==K_ESC
             oGet:exitstate := GE_ESCAPE
           endif
         endcase
    end
    if ( !GetPostValidate(oGet) )
            oGet:exitState := GE_NOEXIT
    endif
  end
  oGet:KillFocus()
endif
return nil

//-------------------------------------------------------------------
static function _pickreader( oGet,aPop,nTop,nLeft,nBottom,nRight)  // yn reader
local nInExit := oGet:exitstate
local nLastKey
local expReturn,nReturn
if nInExit == GE_DOWN
  nInExit := GE_ENTER
endif
if ( GetPreValidate(oGet) )
  oGet:SetFocus()
  while ( oGet:exitState == GE_NOEXIT )
    if ( oGet:typeOut )
            oGet:exitState := GE_ENTER
    endif

    if (nReturn := mchoice(aPop,nTop,nLeft,nBottom,nRight) ) > 0
      expReturn := aPop[nReturn]
      if valtype(expReturn)==oGet:type
        if oGet:type$"LDN"
          oGet:varput(expReturn)
          oGet:updatebuffer()
          oGet:display()
        else
          oGet:home()
          oGet:buffer := padr(expReturn,len(oGet:buffer))
          oGet:display()
          oGet:assign()
          oGet:end()
        endif
      endif
    endif

    oGet:exitstate := nInExit
    if ( !GetPostValidate(oGet) )
            oGet:exitState := GE_NOEXIT
    endif
  end
  oGet:KillFocus()
endif
return nil


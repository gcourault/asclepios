
//--------------------------------------------------------------------------
FUNCTION fmove2prev(nHandle)

local nMoveTo,cChunk,cBuffer
local nOldOffset
local lSuccess := .f.

*- save old offset
nOldOffset := FSEEK(nHandle,0,1)
nOldOffset := FSEEK(nHandle,MAX(0,nOldOffset-3))

*- if we're at the beginning of file, return
IF nOldOffset == 0
  RETURN .f.
ENDIF

*- determine where we're going to move to, but not beyond beginning if file
nMoveTo := MAX(nOldOffset-160,0)

*- move backwards that many bytes
nMoveTo := FSEEK(nHandle,nMoveTo)

*- now read in a line from here to the old offset
cChunk := Freadstr(nHandle,nOldOffset-nMoveTo+1)


*- see if there's a CHR(10) in the lot
IF AT(CHR(10),cChunk) = 0
  
  *- if no chr(10)
  DO WHILE .T.
    
    *- move back 1 - but not past beginning of file
    nMoveTo = MAX(nMoveTo-1,0)
    
    *- if the offset to go to is less than 1, we're apparantly at the
    *- beginning of the file, so just move the pointer to the beggining
    *- of the file and exit
    IF nMoveTo < 1
      FSEEK(nHandle,0)
      lSuccess := .t.
      exit
    ENDIF
    
    *- move the pointer to the new nPosition
    FSEEK(nHandle,nMoveTo)
    
    *- set up a Buffer 1 byte long
    cBuffer = ' '
    
    *- read in a byte
    Fread(nHandle,@cBuffer,1)
    IF cBuffer==CHR(10)
      *- if its a chr(10), exit - otherwise loop back around
      lSuccess := .t.
      EXIT
    ENDIF
    
  ENDDO
ELSE
  *- ok, so we've got one - or more
  *- determine where it is
  nMoveTo = nMoveTo+Rat(CHR(10),cChunk)
  lSuccess := .t.
  *- and move to that nPosition
  FSEEK(nHandle,nMoveTo)
ENDIF
if !lSuccess
  fseek(nHandle,nOldOffset)
endif
return lSuccess


//--this is here because I made an error in the documentation and
//- reference fmove2prior() when the actual name is as above
//--------------------------------------------------------------------------
FUNCTION fmove2prior(nHandle)

local nMoveTo,cChunk,cBuffer
local nOldOffset
local lSuccess := .f.

*- save old offset
nOldOffset := FSEEK(nHandle,0,1)
nOldOffset := FSEEK(nHandle,MAX(0,nOldOffset-3))

*- if we're at the beginning of file, return
IF nOldOffset == 0
  RETURN .f.
ENDIF

*- determine where we're going to move to, but not beyond beginning if file
nMoveTo := MAX(nOldOffset-160,0)

*- move backwards that many bytes
nMoveTo := FSEEK(nHandle,nMoveTo)

*- now read in a line from here to the old offset
cChunk := Freadstr(nHandle,nOldOffset-nMoveTo+1)


*- see if there's a CHR(10) in the lot
IF AT(CHR(10),cChunk) = 0
  
  *- if no chr(10)
  DO WHILE .T.
    
    *- move back 1 - but not past beginning of file
    nMoveTo = MAX(nMoveTo-1,0)
    
    *- if the offset to go to is less than 1, we're apparantly at the
    *- beginning of the file, so just move the pointer to the beggining
    *- of the file and exit
    IF nMoveTo < 1
      FSEEK(nHandle,0)
      lSuccess := .t.
      exit
    ENDIF
    
    *- move the pointer to the new nPosition
    FSEEK(nHandle,nMoveTo)
    
    *- set up a Buffer 1 byte long
    cBuffer = ' '
    
    *- read in a byte
    Fread(nHandle,@cBuffer,1)
    IF cBuffer==CHR(10)
      *- if its a chr(10), exit - otherwise loop back around
      lSuccess := .t.
      EXIT
    ENDIF
    
  ENDDO
ELSE
  *- ok, so we've got one - or more
  *- determine where it is
  nMoveTo = nMoveTo+Rat(CHR(10),cChunk)
  lSuccess := .t.
  *- and move to that nPosition
  FSEEK(nHandle,nMoveTo)
ENDIF
if !lSuccess
  fseek(nHandle,nOldOffset)
endif
return lSuccess




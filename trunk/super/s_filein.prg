#define GETSIZE  1
#define GETDATE  2
#define GETTIME  3

FUNCTION fileinfo(cFile,nWhichInfo)
local aFileInfo
if file(cFile)
  aFileInfo := DIRECTORY(cFile)
  DO CASE
  CASE nWhichInfo = GETSIZE
    RETURN aFileInfo[1,2]
  CASE nWhichInfo = GETDATE
    RETURN aFileInfo[1,3]
  CASE nWhichInfo = GETTIME
    RETURN aFileInfo[1,4]
  ENDCASE
elseif valtype(nWhichInfo)=="N"
  do case
  case nWhichInfo == 1
    return 0
  case nWhichInfo == 2
    return ctod("  /  /  ")
  case nWhichInfo == 3
    return ""
  endcase
endif
RETURN ""











*: EOF: S_FILEIN.PRG


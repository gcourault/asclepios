FUNCTION ed_g_pic(_bizzaro__)

local cPicture, cString

*- create an appropriate picture
DO CASE
CASE TYPE(_bizzaro__) = "C"
  *- make sure it fits on the screen
  cPicture := "@KS" + LTRIM(STR(MIN(LEN(&_bizzaro__), 78)))
CASE TYPE(_bizzaro__) = "N"
  *- convert to a cString
  cString := STR(&_bizzaro__)
  *- look for a decimal point
  IF "." $ cString
    *- return a picture reflecting a decimal point
    cPicture := REPLICATE("9", AT(".", cString) - 1) + "."
    cPicture := cPicture + REPLICATE("9", LEN(cString) - LEN(cPicture))
  ELSE
    *- return a cString of 9's a the picture
    cPicture := REPLICATE("9", LEN(cString))
  ENDIF
  
OTHERWISE
  *- well I just don't know.
  cPicture  := ""
ENDCASE
RETURN cPicture



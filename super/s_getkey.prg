#include "inkey.ch"
FUNCTION getakey(nLastKey)
DO CASE
CASE nLastKey = K_DOWN .OR. nLastKey = K_ENTER  .OR. nLastKey = K_PGDN
  RETURN "FWD"
CASE nLastKey = K_UP  .OR. nLastKey = K_PGUP
  RETURN "BWD"
CASE nLastKey = K_ESC
  RETURN "ESC"
CASE nLastKey = K_CTRL_END
  RETURN "CTW"
OTHERWISE
  RETURN "FWD"
ENDCASE
return ""


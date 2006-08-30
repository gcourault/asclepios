#include "common.ch"
#include "inkey.ch"

********************************
function VERAPE(Arg1)

   if (afiliado->(dbSeek(Arg1)))
      @  6, 27 say afiliado->baapel
   else
      @  6, 27 say "NO ENCONTRADO"
   endif
   return .T.

* EOF

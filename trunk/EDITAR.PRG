#include "inkey.ch"
********************************

   if (medi = 1)
      e_campo:= acolumnas[campo]
      get_campo:= &e_campo
      malta:= .F.
      if (campo = 2)
         @ Row(), Col() get get_campo picture "@9" valid ;
            captroquel(get_campo)
         set key K_F2 to scroller
         set key K_ALT_F2 to scmod
         read
         SetKey(K_F2, Nil)
         SetKey(K_ALT_F2, Nil)
      elseif (campo = 1)
         get_campo:= 1
         @ Row(), Col() get get_campo picture "9"
         read
      elseif (campo = 4)
         @ Row(), Col() get get_campo
         read
      endif
      if (EOF() .AND. LastRec() <= 3)
         append blank
         malta:= .T.
      endif
      replace &e_campo with get_campo
      * replace nombre with medicame->nombre
      * replace presentac with medicame->presentac
      replace unitario with medicame->vtapub / 100
      replace total with cantidad * unitario
      replace diba with total * mdescuento / 100
      skip 0
      commit
   elseif (medi == 2)
      e_campo:= acolumnas[campo]
      get_campo1:= &e_campo
      malta:= .F.
      if (campo = 2)
         @ Row(), Col() get get_campo1 picture "@9" valid ;
            capnomen(get_campo1)
         set key K_F2 to scroller
         set key K_ALT_F2 to scmod
         read
         SetKey(K_F2, Nil)
         SetKey(K_ALT_F2, Nil)
      elseif (campo = 1)
         get_campo1:= 1
         @ Row(), Col() get get_campo1 picture "99"
         read
      elseif (campo = 4)
         @ Row(), Col() get get_campo1
         read
      endif
      if (EOF())
         append blank
         malta:= .T.
      endif
      replace &e_campo with get_campo1
      replace nomenclado with nomencla->codi
      replace unitario with calcnomen(nomencla->codi)
      replace totfactu with cantidad * unitario
      replace total with cantidad * unitario
      replace debito with iif(totfactu - total > 0, totfactu - ;
         total, 0.00)
      replace totapag with totfactu - debito
      skip 0
      commit
   endif
   return

********************************
function CAPTROQUEL

   local Local1
   parameters mtroquel
   Local1:= {}
   private marea, mdebito, mmotdeb, mtmp
   initsup()
   marea:= Select()
   select MEDICAME
   seek mtroquel
   if (Found())
      ?? nombre
      select (marea)
      return .T.
   else
      msg("El troquel no ha sido encontrado")
      if (messyn("Tiene dos opciones:", "Debita el Troquel", ;
            "Vuelve a Ingresarlo"))
         mdebito:= 0.00
         mtmp:= makebox(15, 10, 19, 48, c_popcol)
         @ 17, 11 say "Ingrese Monto a Debitar"
         SetPos(Row(), Col() + 1)
         AAdd(Local1, __Get(Nil, "mdebito", "999999.99", Nil, Nil))
         ReadModal(Local1)
         Local1:= {}
         unbox(mtmp)
         mmotdeb:= "042"
         select (marea)
         replace debito with mdebito
         replace motivo with mmotdeb
         return .T.
      else
         select (marea)
         return .F.
      endif
   endif

********************************
function CAPNOMEN

   local Local1
   parameters mnomen
   Local1:= {}
   private marea, mdebito, mmotdeb, mtmp
   initsup()
   marea:= Select()
   select NOMENCLA
   seek mnomen
   if (Found())
      select (marea)
      return .T.
   else
      msg("El c¢digo de nomenclador no ha sido encontrado")
      if (messyn("Tiene dos opciones:", "Debita el c¢digo", ;
            "Vuelve a Ingresarlo"))
         mdebito:= 0.00
         mtmp:= makebox(15, 10, 19, 48, c_popcol)
         @ 17, 11 say "Ingrese Monto a Debitar"
         SetPos(Row(), Col() + 1)
         AAdd(Local1, __Get(Nil, "mdebito", "999999.99", Nil, Nil))
         ReadModal(Local1)
         Local1:= {}
         unbox(mtmp)
         mmotdeb:= "081"
         select (marea)
         replace debito with mdebito
         replace motdeb with mmotdeb
         return .T.
      else
         select (marea)
         return .F.
      endif
   endif

********************************
function CALCNOMEN(Arg1)

   local Local1
   narea:= Select()
   select UARA
   goto bottom
   Local1:= 0
   do case
   case nomencla->letr = "A" .OR. nomencla->letr = "B"
      Local1:= qgale * nomencla->hono * mcategoriz / 100 + sagq * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "C"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + saog * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "D"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + gara * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "E"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + sagc * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "F"
      Local1:= gale * nomencla->hono * mcategoriz / 100
   case nomencla->letr = "G"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + sagp * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "H"
      Local1:= hobi * nomencla->hono * mcategoriz / 100 + gabi * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "I"
      Local1:= sagc * nomencla->gast * marancel / 100
   case nomencla->letr = "J"
      Local1:= hodo * nomencla->hono * mcategoriz / 100
   case nomencla->letr = "K"
      Local1:= hodo * nomencla->hono * mcategoriz / 100 + gaop * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "L"
      Local1:= hodo * nomencla->hono * mcategoriz / 100 + sagc * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "M"
      Local1:= hodo * nomencla->hono * mcategoriz / 100 + gara * ;
         nomencla->gast * marancel / 100
   case nomencla->letr = "N"
      Local1:= gale * nomencla->hono * mcategoriz / 100 + gabi * ;
         nomencla->gast * marancel / 100
   endcase
   select (narea)
   return Local1

********************************

/* --------------------------------
   Banco.prg
	programa que permite acceder a
	las funciones del banco
------------------------------------*/

# include "inkey.ch"
# define MAXRENG 10
# include "regional.ch"
* ------------------------------------------------------------------------
  function ingsaldo
* ------------------------------------------------------------------------

select 3
if !snet_use("BANCO","BANCO",.F.,5,.T.,"No se puede abrir Banco.dbf - ¨Reintenta?")
	msg("Reintente luego")
	return NIL
endif

select BANCO
go top
if eof()
	if !sadd_rec(5,.f.)
		msg("Hay un problema en la red - llamar a Soporte T‚cnico")
		return NIL
	endif
	unlock
endif

private mnumero     := "S.INICIAL"
private mprov       := space(40)
private mmonto      := 0.00
private mfecha      := dtoc(date())

* ----------------------------------------------------

motro := makebox(5,5,16,75)

while .t.
	@ 8,8 say "Fecha Saldo Inicial    :" get mfecha pict "@D"
	@10,8 say "Descripci¢n del Saldo  :" get mprov  pict "@!"
	@12,8 say "Monto del Saldo Inicial:" get mmonto pict "99,999.99" valid genval("mmonto > 0.00","El monto debe ser mayor que cero")
	read

	* -----------------------------------------------------------------

	if lastkey() == K_ESC
		if messyn("¨Cancela el ingreso del Primer Saldo?")
			unbox(motro)
			return NIL
		endif
	endif
	
	* -----------------------------------------------------------------
	
	if messyn("¨Los datos son correctos?",18,5)
		exit
	endif
end                  //FIN DEL LAZO DE INGRESO DE DATOS

* ----------------------------------------------------
if messyn("¨Graba saldo inicial?",18,5)
	if srec_lock(5,.t.,"No se puede bloquear registro para grabar - ¨Reintenta?")
		replace BANCO->numero      with M->mnumero
		replace BANCO->fecha       with ctod(M->mfecha)
		replace BANCO->alaorden    with M->mprov
		replace BANCO->monto       with M->mmonto
		replace BANCO->estado      with "2"          // NO COBRADO
		unlock
	else
		msg("No se pudieron Grabar los Datos - Cancela")
		clear
		cancel
	endif
endif

* ----------------------------------------------------
	
unbox(motro) 
close data
return NIL

* ------------------------------------------------------------------------
  function gastos
* ------------------------------------------------------------------------

select 3
if !snet_use("BANCO","BANCO",.F.,5,.T.,"No se puede abrir Banco.dbf - ¨Reintenta?")
	msg("Reintente luego")
	return NIL
endif

select BANCO

private mnumero     := "OTROS"
private mprov       := space(40)
private mmonto      := 0.00
private mfecha      := dtoc(date())
private mobservacio := space(40)

* ----------------------------------------------------

while .t.
	motro := makebox(5,5,16,75)
	while .t.
		
		@ 8,8 say "Fecha Gasto            :" get mfecha pict "@D"
		@10,8 say "Descripci¢n del Gasto  :" get mprov  pict "@!"
		@12,8 say "Monto del Gasto        :" get mmonto pict "999,999.99" valid genval("mmonto > 0.00","El monto debe ser mayor que cero")
		@14,8 say "Observaciones          :" get mobservacio pict "@S30"
		read
	
		* -----------------------------------------------------------------
	
		if lastkey() == K_ESC
			if messyn("¨Cancela el ingreso?")
				unbox(motro)
				return
			endif
		endif
	
		* -----------------------------------------------------------------
	
		if messyn("¨Los datos son correctos?",18,5)
			exit
		endif
	end                  //FIN DEL LAZO DE INGRESO DE DATOS

	* ----------------------------------------------------
	if messyn("¨Graba el Gasto?",18,5)
		do grabcheq with mnumero,mfecha, mprov, mmonto, mobservacio,"2"
	endif
	* ----------------------------------------------------
	
	unbox(motro) 
	if !messyn("¨Ingresa otro gasto?")
		exit
	endif
end                     // FIN DEL LAZO PRINCIPAL

set key K_F2     to
set key K_ALT_F2 to


close data
return

* ---------------------------------------------------------
  function anexoa
* ---------------------------------------------------------
if !snet_use("banco.dbf","banco",.T.,5,.T.,;                 
            "No se puede abrir banco.DBF - ¨Reintenta?")
	msg("Error en la Red - Revise y reintente")
	return
endif
* ----------------------------------------------------

mmes := 0
manio := year(date())
while .t.
	popread(.t.,"Ingrese Mes a Procesar: ",@mmes,"99",;
	            "Ingrese A¤o a Procesar: ",@manio,"9999")
	mensaje = "El mes a procesar es : " + cmes(mmes) + " de " + str(manio,4,0)
	if messyn(mensaje,"Correcto","Incorrecto")
		exit
	endif
end

set filter to month(banco->FECHA) == mmes .and. ;
              year(banco->FECHA) == manio .and. ;
              banco->NUMERO != "OTROS   " .and.;
				  banco->NUMERO != "DEPOSITO"
go top
aMarcar := {}

aCampos := {"NUMERO","FECHA","MONTO","ALAORDEN"}
aDescr  := {"N§","Fecha","Monto","A la Orden de:"}
tagit(aMarcar,aCampos,aDescr,"SELECCIONE LOS CHEQUES COBRADOS")


* rlSetFilter( rlCheques )
set filter to ascan( aMarcar , recno() ) > 0

replace all banco->ESTADO with "2" 
go top

set filter to month(banco->FECHA) == mmes .and. ;
              year(banco->FECHA) == manio .and. ;
              banco->ESTADO == "1"

do impanexa
close data
return



* ------------------------------------------------------------
  function concilia()
* ------------------------------------------------------------
select 1
if snet_use("resumen.dbf","RESUMEN",.t.,5,.t.,;
            "No se puede abrir RESUMEN.DBF - ¨Reintenta?")
	set order to tag resumen
else
	msg("Error de red - Revise y reintente")
	return
endif

select 2
* ----------------------------------------------------
if !snet_use("banco.dbf","banco",.T.,5,.T.,;                 
            "No se puede abrir banco.DBF - ¨Reintenta?")
	msg("Error en la Red - Revise y reintente")
	return NIL
endif
* ----------------------------------------------------

mmes := 0
manio := year(date())
while .t.
	popread(.t.,"Ingrese Mes a Procesar: ",@mmes,"99",;
	            "Ingrese A¤o a Procesar: ",@manio,"9999")
	mensaje = "El mes a procesar es : " + cmes(mmes) + " de " + str(manio,4,0)
	if messyn(mensaje,"Correcto","Incorrecto")
		exit
	endif
end

mfecha := begend(ctod("15"+"/"+str(mmes,2)+"/"+right(str(manio,4),2)),0,2)

plswait(.t.)
set filter to month(banco->FECHA) == mmes .and. ;
              year(banco->FECHA) == manio .and. ;
              banco->ESTADO == "1"
go top
sum banco->MONTO to m->mChNoCobr
mChNoCobr := -mChNoCobr

if mmes = 1
	mmes = 12
	manio = manio - 1
else
	mmes = mmes - 1
endif


set filter to month(banco->FECHA) == mmes .and. ;
              year(banco->FECHA) == manio .and. ;
              banco->ESTADO == "1"
go top

replace all estado with "3"

set filter to month(banco->FECHA) == mmes .and. ;
              year(banco->FECHA) == manio .and. ;
              banco->ESTADO == "3"
go top
sum banco->MONTO to m->mChPenAnt
mChPenAnt := -mChPenAnt
plswait(.f.)

mSalExBan   := 0.00

/* mChNoCobr   := 0.00 */
/* mChPenAnt   := 0.00 */

mOtrosDebit := 0.00
mDepNoAcred := 0.00
mSaldoConc  := 0.00


mconc := makebox(2,1,23,77)
while .t.
	centro(3,2,77,"* CONCILIACION BANCARIA *")
	@ 5,4 say "1. SALDO EXTRACTO BANCARIO                  :";
	      get mSalExBan pict "999,999.99"
			
	@ 7,4 say "MENOS :"
	
	@ 9,4 say '2. CHEQUES EMITIDOS NO COBRADOS (Anexo "A") :';
	      get mChNoCobr  pict "999,999.99"
	@10,4 say "3. CHEQUES PENDIENTES CONCILIACION ANTERIOR :";
	      get mChPenAnt pict "999,999.99"
			
	@12,4 say "MAS :"

	@14,4 say "4. DEBITOS REGISTRADOS EN EXTRACTO Y NO"
	@15,4 say "   CONTABILIZADOS                          :";
         get mOtrosDebit pict "999,999.99"
	
	@16,4 say "5. DEPOSITOS NO ACREDITADOS                :";
	      get mDepNoAcred pict "999,999.99"
	read
	mSaldoConc := mSalExBan - mChNoCobr - mChPenAnt + mOtrosDebit + mDepNoAcred
	@18,4 say "  SALDO LIBRO DE BANCO CONCILIADO          :";
	      get mSaldoConc pict "999,999.99"
	read
	if messyn("¨Los datos son los correctos?",18,5)
		exit
	endif
end

select 1
if messyn("¨Graba la Conciliaci¢n?",18,5)
	seek dtos(mfecha)
	if found()
		if messyn("Se ha encontrado una conciliaci¢n del per¡odo Indicado",;
		           "Contin£a","No Contin£a")
			replace fecha 			with mfecha
			replace SalExBan		with mSalExBan
			replace ChNoCobr		with mChNoCobr
			replace ChPenAnt 		with mChPenAnt
			replace OtrosDebit	with mOtrosDebit
			replace DepNoAcred	with mDepNoAcred
			replace SaldoConc		with mSaldoConc
		else
			msg("Queda la Conciliaci¢n Anterior")
		endif
	else
		if sadd_rec(5,.t.,"No se puede agregar Registro en Blanco - ¨Reintenta?")
			replace fecha 			with mfecha
			replace SalExBan		with mSalExBan
			replace ChNoCobr		with mChNoCobr
			replace ChPenAnt 		with mChPenAnt
			replace OtrosDebit	with mOtrosDebit
			replace DepNoAcred	with mDepNoAcred
			replace SaldoConc		with mSaldoConc
		else
			msg("No se grabaron los datos - Reintente luego")
		endif
	endif
endif
if messyn("¨Imprime la Conciliaci¢n?")
	if p_ready()
		do impconc
	endif
endif
close data
unbox(mconc)
return NIL  


* --------------------------------------------------------------
  function ingcheque
* --------------------------------------------------------------
private mnumero     := space(10)
private mprov       := space(40)
private mmonto      := 0.00
private mfecha      := dtoc(date())
private mobservacio := space(40)

* ----------------------------------------------------

if !snet_use("BANCO.dbf","BANCO",.F.,5,.T.,;
            "No se puede abrir BANCO.DBF - ¨Reintenta?")
	msg("Error en la Red - Revise y reintente")
	return
endif

* ----------------------------------------------------

set key K_F2     to scroller
set key K_ALT_F2 to scmod

while .t.
	mcheque := makebox(5,5,16,75)
	while .t.
		@ 6,8 say "N§ del Cheque          :" get mnumero pict "@9"
		@ 8,8 say "Fecha del Cheque       :" get mfecha pict "@D"
		@10,8 say "Cheque a la orden de   :" get mprov  pict "@!"
		@12,8 say "Ingrese Monto a Pagar  :" get mmonto pict "999,999.99" valid genval("mmonto > 0.00","El monto debe ser mayor que cero")
		@14,8 say "Observaciones          :" get mobservacio pict "@S30"
		read
	
		* -----------------------------------------------------------------
	
		if lastkey() == K_ESC
			if messyn("¨Cancela el ingreso?")
				unbox(mcheque)
				return
			endif
		endif
	
		* -----------------------------------------------------------------
	
		if messyn("¨Los datos son correctos?",18,5)
			exit
		endif
	end                  //FIN DEL LAZO DE INGRESO DE DATOS

	* ----------------------------------------------------
	if messyn("¨Graba el Cheque?",18,5)
		do grabcheq with mnumero,mfecha, mprov, mmonto, mobservacio,"1"
	endif
	* ----------------------------------------------------
	
	unbox(mcheque) 
	if !messyn("¨Ingresa otro cheque?")
		exit
	endif
end                     // FIN DEL LAZO PRINCIPAL

set key K_F2     to
set key K_ALT_F2 to


close data
return NIL

* --------------------------------------------------------------
  function deposito
* --------------------------------------------------------------
private mnumero     := space(10)
private mprov       := space(40)
private mmonto      := 15000
private mfecha      := dtoc(date())
private mobservacio := space(40)

* ----------------------------------------------------

if !snet_use("BANCO.dbf","BANCO",.F.,5,.f.)
	msg("Error en la Red - Revise y reintente")
	return
endif

* ----------------------------------------------------

set key K_F2     to scroller
set key K_ALT_F2 to scmod

mdeposito := makebox(5,5,16,75)

while .t.
	@ 8,8 say "Fecha del Dep¢sito       :" get mfecha pict "@D"
	@12,8 say "Ingrese Monto a Depositar:" get mmonto pict "999,999.99"
	@14,8 say "Observaciones            :" get mobservacio pict "@S30"
	read
	if lastkey() == K_ESC
		if messyn("¨Cancela el dep¢sito")
			unbox(mdeposito)
			return
		endif
	endif
	if messyn("¨Los datos son correctos?",18,5)
		exit
	endif
end

mnumero := "DEPOSITO"
mprov   := "DEPOSITO DE FECHA: " + mfecha

* ----------------------------------------------------
if messyn("¨Graba el Dep¢sito?",18,5)
	do grabcheq with mnumero,mfecha, mprov, -mmonto, mobservacio, "2"
endif
* ----------------------------------------------------
close data
unbox(mdeposito)
return NIL


* ---------------------------------------------------------------
  function ccte
* ---------------------------------------------------------------
close data
select 1
if !snet_use("BANCO","BANCO",.F.,5,.t.,"No se puede abrir BANCO.DBF - ¨Reintenta?")
	msg("No se puede acceder a esta opci¢n",;
	    "Reintente luego de revisar la red")
	return
endif
mfecha := dtoc(date())

popread(.f.,"Seleccione la fecha desde la cual examinar la c.cte.",@mfecha,"@D")

plswait(.t.,"Sumando ...")
m->msaldo := 0.00
sum monto to m->msaldo for (BANCO->fecha < ctod(m->mfecha))
plswait(.f.)

set filter to (BANCO->fecha >= ctod(m->mfecha))
go top

if eof()
	msg("No hay movimientos","Retorna al men£ anterior")
	close data
	return
endif

aSaldo   := {}
aPuntero := {}
plswait(.t.,"Armando los saldos")
while !eof()
	m->msaldo := m->msaldo + BANCO->monto
	aadd(aSaldo   , m->msaldo )
	aadd(aPuntero , recno()   ) 
	skip
end


go top
plswait(.f.)
aCampos := {"numero","fecha","alaorden","monto","aSaldo[ascan(aPuntero,recno())]","observacio"}
aDescr  := {"N§","Fecha","A la Orden de","Monto","Saldo","Observaciones"}

editdb(.f.,aCampos,aDescr,.t.)
return NIL

* --------------------------------------------------------------
  function librobco
* --------------------------------------------------------------
select 1
if !snet_use("BANCO.dbf","BANCO",.T.,5,.T.,;
            "No se puede abrir BANCO.DBF - ¨Reintenta?")
	msg("Error en la Red - Revise y reintente")
	return
endif

* ----------------------------------------------------

mmes  := month(date())
manio := year(date())
while .t.
	popread(.t.,"Mes a Imprimir:",@mmes,"99",;
	            "A¤o a Imprimir:",@manio,"9999")
	mensaje = "Ha seleccionado el mes: " + cmes(mmes) + " de " + str(manio,4)
	if messyn(mensaje,"Correcto","Incorrecto")
		exit
	endif
end
if messyn("¨Comienza la impresi¢n?")
	do gensaldo
	do implibro
endif

close data
delete file saldo.dbf
return NIL

*-------------------------------------------------------
 FUNCTION BORRACHEQ
*-------------------------------------------------------
if !snet_use("BANCO","BANCO",.f.,5,,.t.,;
            "No se puede abrir BANCO.DBF - ¨Reintenta?")
	msg("Retorna al men£ anterior")
	return
endif

mcheque := space(len(BANCO->NUMERO))

mpantalla := makebox(10,20,15,60)
@ 12,22 say "ANULACION DE CHEQUES"
@ 13,22 say "N§ de Cheque a Anular" get mcheque
@ 14,22 say "Pulsar <F2> para ver los cheques" 
set key K_F2 to SCROLLER
set key K_ALT_F2 to SCMOD
read
set key K_F2 to SCROLLER
set key K_ALT_F2 to SCMOD

locate for NUMERO == mcheque
if found()
	if messyn("¨Es el cheque correcto?",19,2)
		if sfil_lock(5,.t.,"No se puede marcar para borrar cheque - ¨Reintenta?")
			delete
			unlock
		endif
	endif
else
	msg("No encontado")
endif
unbox(mpantalla)
close databases
return nil


* --------------------------------------------------------------
proc grabcheq
* --------------------------------------------------------------

parameters mnumero, mfecha, mprov, mmonto, mobservaci,mmodo

if sadd_rec(5,.t.,"No se puede agregar registro a la base - ¨Reintenta?")
	if srec_lock(5,.t.,"No se puede bloquear registro para grabar - ¨Reintenta?")
		replace BANCO->numero      with M->mnumero
		replace BANCO->fecha       with ctod(M->mfecha)
		replace BANCO->alaorden    with M->mprov
		replace BANCO->observacio  with M->mobservaci
		replace BANCO->monto       with -(M->mmonto)
		replace BANCO->estado      with mmodo           // NO COBRADO
		unlock
		commit
	else
		msg("No se pudieron Grabar los Datos - Cancela")
		clear
		cancel
	endif
else
	msg("Imposible agregar registro - Cancela")
	clear
	cancel
endif

return

* ---------------------------------------------------------------
proc impconc
* ---------------------------------------------------------------

/*----------------------------------------------------------
	Objeto       : Permite imprimir la conciliaci¢n bancaria
	Llamado por  : Concilia
-----------------------------------------------------------*/


set device to printer
@ prow(),  1  say space(1)
@ prow()+1,2   say replicate("Ä",78)
@ prow()+1,2 say  "CONCILIACION BANCARIA"
@ prow()  ,30 say "CTA. CTE. OFICIAL N§ "
@ prow()+1,2  say "DIBA REGIONAL " + NOMBRE_REGIONAL
@ prow()  ,30 say "FECHA DE LA CONCILIACION: "+fechletr(mfecha)
@ prow()+1, 2 say replicate("Ä",78)
@ prow()+1, 2 say "BANCO RIO"
@ prow()  ,40 say "SUCURSAL : CUENTAS CORRIENTES"
@ prow()+2,2  say "DENOMINACION DE LA CUENTA: "
@ prow()+2,2  say "RESPONSABLE : "
@ prow()+1,2  say replicate("Ä",78)
@ prow()+2,4  say "1. SALDO EXTRACTO BANCARIO"
@ prow()  ,60 say RESUMEN->SALEXBAN pict "***,**9.99"
@ prow()+2,2  say "M E N O S: "
@ prow()+2,4  say '2. CHEQUES EMITIDOS NO COBRADOS (Anexo "A"):'
@ prow()  ,48 say RESUMEN->CHNOCOBR pict "***,**9.99"
@ prow()+2,4  say "CHEQUES PENDIENTES CONCILIACION ANTERIOR:"
@ prow()  ,48 say RESUMEN->CHPENANT pict "***,**9.99"
@ prow()+1,2  say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ prow()+1,2  say "Fecha    Cheque N§     A la Orden de    Importe"
@ prow()+1,2  say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"

select banco
go top
m->mcontador := 1
while !eof()
	@ prow() + 1, 2 say BANCO->FECHA
	@ prow()    ,11 say BANCO->NUMERO
	@ prow()    ,22 say left(BANCO->ALAORDEN,16)
	@ prow()    ,39 say ABS(BANCO->MONTO) pict "***,**9.99"
	m->mcontador = m->mcontador + 1
	skip
end
for i = 1 to MAXRENG - m->mcontador
	@ prow() + 1, 1 say space(1)
next i
@ prow()+1,2  say "TOTAL:"
@ prow() , 39 say RESUMEN->CHPENANT pict "***,**9.99"
@ prow()+1,2  say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@ PROW()+2,2 SAY "M A S: "
@ prow()+2,4 say "4. DEBITOS REGISTRADOS EN EXTRACTO Y NO "
@ prow()+1,4 say "   CONTABILIZADOS"
@ prow()  ,48 say RESUMEN->OTROSDEBIT pict "***,**9.99"
@ prow()+2,4  say "5. DEPOSITOS NO ACREDITADOS"
@ prow()  ,48 say RESUMEN->DEPNOACRED pict "***,**9.99"
@ prow()+2,4  say "   SALDO LIBRO DE BANCO CONCILIADO =>"
@ prow()  ,4  say "   SALDO LIBRO DE BANCO CONCILIADO =>"
@ prow()  ,48 say RESUMEN->SALDOCONC pict "***,**9.99"
@ prow()  ,48 say RESUMEN->SALDOCONC pict "***,**9.99"
eject
set device to screen
RETURN

* ----------------------------------------------------------------
proc impanexa
* ----------------------------------------------------------------

save screen 
cls()
quikreport( "ANEXOA" )
restore screen 
return

* ---------------------------------------------------------------
  proc gensaldo
* ---------------------------------------------------------------

/*-----------------------------------------
  GenSaldo.prg
  Programa que genera los saldos
 -----------------------------------------*/


aDbf := {}
aadd( aDbf, { "Fecha     " , "D" , 8 , 0 } )
aadd( aDbf, { "Numero    " , "C" , 8 , 0 } )
aadd( aDbf, { "AlaOrden  " , "C" ,40 , 0 } )
aadd( aDbf, { "Monto     " , "N" , 13 , 2 } )
aadd( aDbf, { "Saldo     " , "N" , 13 , 2 } )
dbcreate( "saldo" , aDbf )

select 2
if !snet_use("saldo","SALDO",.T.,5,.T.,"No se puede abrir archivo auxiliar - ¨Reintenta?")
	msg("Error en la creacion del archivo - Retorna")
	return
endif


select 1
set filter to BANCO->FECHA < ctod( "01/" + str(mmes,2) + "/" + str(manio,4,0) )
go top
plswait( .t. , "Generando Saldos")
sum BANCO->MONTO to msaldo
    

select 2
if sadd_rec(5,.t.,"No se puede agregar registro - ¨Reintenta?")
	replace SALDO->FECHA with ;
	        ctod( "01/" + str(mmes,2) + "/" + str(manio,4,0) )
	replace SALDO->ALAORDEN with "SALDO MES ANTERIOR"
	replace SALDO->NUMERO   with "SALDO"
	replace SALDO->saldo    with M->msaldo
else
	msg("Retorna al men£ anterior")
	return
endif

select 1
set filter to month(BANCO->FECHA) == M->mmes .and. ;
              year(BANCO->FECHA)  == M->manio
				  
go top
count to nMaximo
go top
while !eof()
	select 2
	if sadd_rec(5,.t.,"No se puede agregar registro - ¨Reintenta?")
		replace SALDO->FECHA    with BANCO->FECHA
		replace SALDO->ALAORDEN with BANCO->ALAORDEN
		replace SALDO->NUMERO   with BANCO->NUMERO
		replace SALDO->MONTO    with BANCO->MONTO
		replace SALDO->saldo    with M->msaldo + BANCO->MONTO
		msaldo = msaldo + BANCO->MONTO
	else
		msg("Retorna al men£ anterior")
		return
	endif
	
	select 1	
	skip
end
plswait( .f. )
return


* ------------------------------------------------------------
  proc implibro
* ------------------------------------------------------------

/* ImpLibro.prg 
   Programa que imprime el libro de banco
*/

SELECT 2

save screen
cls()
quikreport( "LIBRO BANCOS" )
restore screen
return

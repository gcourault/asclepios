/* -------------------------------------------------------
   audit.prg
	programa que permite capturar las facturas de las
	farmacias y las audita.
----------------------------------------------------------*/
# include "inkey.ch"
function audit()
initsup()
select 15
if snet_use("IN1PRES","PRESTA", .F. , 5 , .T. , "No se puede abrir archivo de PRESTADORES - ¿Reintenta?" )
	set order to tag PRCOD
else
	msg( "No se puede abrir archivo de Prestadores",;
	     "Debe intentar más tarde: Otro usuario bloquea el archivo" )
	close all
	return
endif

select 14
if snet_use("IN1PRES","IN1PRES", .F. , 5 , .T. , "No se puede abrir archivo de PRESTADORES - ¿Reintenta?" )
	set order to tag PRNOM
else
	msg( "No se puede abrir archivo de Prestadores",;
	     "Debe intentar más tarde: Otro usuario bloquea el archivo" )
	close all
	return
endif

select 1
if snet_use("FACTU01","FACTURA",.F.,5,.T.,"No se puede abrir archivo de FACTURAS - ¿Reintenta?")
	set order to tag faprenum
else
	msg("No se puede abrir archivo de facturas ingresadas",;
		 "debe intentar más tarde: otro usuario está usando el archivo")
	close all
	return
endif
set relation to FACTURA->PRESTADOR into PRESTA

while .t.
        * select FACTURA
        select IN1PRES
	mfactura := space( len(FACTURA->FACTURA) )
	mprestador := space( len(FACTURA->PRESTADOR) )
	
	nTop := 0
	nLeft := 0
	nBottom := 7
	nRight  := 40
	sbcenter( @nTop , @nLeft , @nBottom , @nRight )

	smallkset( K_F2 , "AUDIT" , "mprestador" ,;
	          {|| PRLETR + PRCODI + ' ' + PRNOMB},;
				 "Prestadores",;
				  14 ,;
				 "PRLETR + PRCODI" )
/*
	smallkset( K_F2 , "AUDIT" , "mfactura" ,;
	           {|| FACTURA + ' ' + PRESTA->PRNOMB},;
	           "Factura  Prestador",;
				  nil,;
				  "FACTURA")
	smallkset( K_CTRL_RET , "AUDIT" , "mprestador" ,;
	          {|| PRLETR + PRCODI + ' ' + PRNOMB},;
				 "Prestadores",;
				 "%IN1PRES%PRNOMB",;
				 "PRLETR + PRCODI" )
	smallkset( K_CTRL_RET , "AUDIT" , "mfactura" ,;
	           {|| FACTURA + ' ' + PRESTA->PRNOMB},;
	           "Factura  Prestador",;
				  nil,;
				  "FACTURA")
*/	
	cTmp := makebox( nTop , nLeft , nBottom , nRight , sls_popcol() )
	@ nTop + 5 , nLeft + 2 say "[ F2 Busca ]       [ ESC Cancela ]"
	@ nTop + 1 , nLeft + 2 say "Prestador :"  get mprestador ;
	                       pict "@!" ;
	                       valid isinlook( mprestador , 15 , nil , .f. , "Prestador no v lido" )
        read

        if lastkey() == K_ESC
           unbox( cTmp ) 
           return NIL
        endif
        select FACTURA
        set filter to FACTURA->PRESTADOR = mprestador 
        go top

	@ nTop + 2 , nLeft + 2 say "N§ Factura" get mfactura pict "@9"
	smallkset( K_F2 , "AUDIT" , "mfactura" ,;
	           {|| FACTURA + ' ' + PRESTA->PRNOMB},;
	           "Factura  Prestador",;
				  nil,;
				  "FACTURA")
	
        read	
        if lastkey() == K_ESC
           unbox( cTmp ) 
           return NIL
        endif


        set filter to FACTURA->PRESTADOR = mprestador 

	unbox( cTmp )
        
	
	seek mprestador + mfactura
	if found()
		do case
		case left(FACTURA->CONCEPTO,1) == "2"
			if left(mprestador,1) = "S"
				do audfarm
			else
				do reinfar
			endif
		case left(FACTURA->CONCEPTO,1) == "4"
			if left(mprestador,1) = "S"
				do audprac
			else
				do reinprac
			endif
		case left(FACTURA->CONCEPTO,1) == "3" .or. left(FACTURA->CONCEPTO,1) == "5"
			if left(mprestador,1) = "S"
				do audprac
			else
				do reinprac
			endif
		otherwise
			if left(mprestador,1) = "S"
				do audprac
			else
				do reinprac
			endif
		endcase
	else
		msg("Factura no ingresada")
                exit
	endif
end
close databases
return


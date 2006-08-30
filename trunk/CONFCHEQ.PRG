* ---------------------------------------------------------
* ConfCheq.prg
* Permite configurar los cheques o manuales o autom ticos
* ---------------------------------------------------------
function confcheq()

if snet_use("param" , "param" , .f. , 5 , .t. , "No se puede abrir archivo de par metros - ¨Reintenta?" )
	m->_cheques := param->cheques
endif

if messyn("Los Cheques son:" , "Manuales" , "Formularios Cont¡nuos" )
	if srec_lock( 5 , .f. )
		replace param->cheques with "MANUAL"
		unlock
		m->_cheques := param->cheques
	endif
else
	if srec_lock( 5 , .f. )
		replace param->cheques with "CONTINUO"
		unlock
		m->_cheques := param->cheques
	endif
endif

return

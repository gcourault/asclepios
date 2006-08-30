/* Compro.prg
   programa que genera los ¡ndices
	y los mem's del sistema
	del sistema
*/

* -----------------
  function compro()
* -----------------
set exclusive on
if !file( "nrocheque.mem" )
	mcheque := 1
	save all like mcheque to nrocheque
	release mcheque
endif

use indices
if !file( "indices"+indexext() )
	index on base tag base
endif
set order to tag base
while !eof()
	cBase := alltrim( BASE )
	if !file( cBase + indexext() )
		use &cBase new
		while cBase == alltrim( INDICES->BASE )
			cClave := alltrim( INDICES->CLAVE )
			cTag   := alltrim( INDICES->INDICE )
			* nTop := 0
			* nLeft := 0
			* nBottom := 6
			* nRight := max( max( max( len(cBase) , len(cClave) ), len( cTag ) ) , 30 ) + 12
			* sbcenter( @nTop , @nLeft , @nBottom , @nRight )
			* cPanInd := makebox( nTop , nLeft , nBottom , nRight )
			* xindex on (cClave) tag (cTag) eval VerIndex() every 100
			
			ProgOn("Indexando " + cBase + " indice: " + cTag  )
			index on &cClave tag &cTag eval {||progdisp( recno() , reccount() ) , .t. } every 100
			progoff()
			
			* unbox( cPanInd )
			indices->( dbskip() )
		end
		use
		select indices
	else
		skip
	endif
end
close all
return

* ----------------------
  function VerIndex()
* ----------------------
@ nTop + 1 , nLeft + 2 say "Base:    " + cBase
@ nTop + 2 , nLeft + 2 say "Creando: " + cClave
@ nTop + 3 , nLeft + 2 say alltrim(str(recno()))+" Reg. Procesados"
return .t.

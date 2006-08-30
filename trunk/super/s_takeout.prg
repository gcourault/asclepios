/*
Function:     Takeout()
Purpose :     Extract section of a string between delimiters
Usage   :     Takeout(<expC1>, <expC2>, <expN>)
Params  :     expC1 - string
              expC2 - delimiter  (beginning and end of string are considered
                                  delimiters)
              expN  - occurance
Example :     takeout("Next:Previous:First:Quit",":",3)
              returns "First"
Returns :     Section of string between delimiters, occurance <expN>.
Found in:     s_takeout.prg
*/
function takeout( cCadena , cDelimitador , nOcurrencia )
local cResultado := space(0)
local i
local ocurr
local knt
local fnd
local strstart := 1
local strlen
local strend
local size

ocurr := nOcurrencia - 1  /* Comienzo de la cadena - Primer delimitador */
delim := cDelimitador
string := cCadena

strlen := len( cCadena )
strend := strlen   // strlen - 1
i := 0
knt := 0
fnd := 0
while ( ( i < strlen ) .and. ( knt < ocurr ) )
	knt := iif( delim == substr( string , i , 1 ) , knt + 1 , knt )
	strstart := iif( knt == ocurr , i + 1 , strend )
	i++
enddo
fnd := iif( knt == ocurr , .t. , .f. )
while ( ( i < strlen ) .and. ( strend == strlen  ) .and. fnd )
	strend = iif( delim == substr( string , i , 1) , i - 1 , strend )
	i++
enddo
knt := 0
if ( strend >= strstart ) .and. fnd
	* size := strend - strstart + 2
	size := strend - strstart + 1
	return substr( string , strstart , size )
else
	return space(0)
endif


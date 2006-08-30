
FUNCTION colpik
LOCAL nChoice := 0
IF !SLS_ISCOLOR()
  msg('S¢lo disponible en monitores color')
  SattMono()
ELSE
  nChoice := menu_v('Select color ','A-Azul Pac¡fico',;
                'B-The Big Chill','C-Sombras y Luces','D-Azul Bah¡a',;
                'E-Blanco & Negro','F-Amarillos','G-Canadian Crimson',;
                'H-Cristal hielo','I-Dos Luces','J-Aventura marina profunda',;
                'K-Frescura California','L-Irish Clover')
  DO CASE
  CASE nChoice = 1
    sls_normcol(  'W/B,GR+/R,,,W/N' )
    sls_normmenu(  'W/B,N/R,,,W/N' )
    sls_popcol(  'N/BG,N/W,,,BG+/N' )
    sls_popmenu(  'N/BG,W+/N,,,BG+/N' )
  CASE nChoice = 2
    sls_Normcol("B/BG,GR+/R,,,W/N" )
    sls_Normmenu("B/BG,W+/B,,,W/N" )
    sls_Popcol("N/B,N/W,,,BG+/N" )
    sls_Popmenu("N/B,W+/N,,,BG+/N" )
  CASE nChoice = 3
    sls_Normcol("N+/N,GR+/R,,,W/N" )
    sls_Normmenu("N+/N,W+/B,,,W/N" )
    sls_Popcol("N/B,N/W,,,BG+/N" )
    sls_Popmenu("N/B,W+/N,,,BG+/N" )
  CASE nChoice = 4
    sls_normcol(  'B/W,W+/R,,,W/B' )
    sls_normmenu(  'B/W,GR+/B,,,W/B' )
    sls_popcol(  'GR+/B,W+/R,,,W/R' )
    sls_popmenu(  'GR+/B,B+/W,,,W/R' )
  CASE nChoice = 5
    sls_normcol(  'W/N,N/W,,,+W/N' )
    sls_normmenu(  'W/N,N/W,,,N/W' )
    sls_popcol(  'N/W,+W/N,,,W/N' )
    sls_popmenu(  'N/W,W/N' )
  CASE nChoice = 6
    sls_Normcol("GR+/GR,GR+/N,,,GR/N" )
    sls_Normmenu("GR+/GR,W+/W,,,GR/N" )
    sls_Popcol("GR+/N,GR+/R,,,N/R" )
    sls_Popmenu("GR+/N,GR+/GR,,,N/R" )
  CASE nChoice = 7
    sls_normcol(  'N/W,GR+/R,,,W+/N' )
    sls_normmenu(  'N/W,W/R,,,W+/N' )
    sls_popcol(  'W+/R,GR+/B,,,W/B' )
    sls_popmenu(  'W+/R,N/W,,,W/B' )
  CASE nChoice = 8
    sls_Normcol("N/W,W+/BG,,,N/BG" )
    sls_Normmenu("N/W,W+/B,,,N/BG" )
    sls_Popcol("BG+/N,BG/B,,,N/W" )
    sls_Popmenu("BG+/N,W+/BG,,,N/W" )
  CASE nChoice = 9
    sls_normcol(  'N/W,W+/BG,,,BG/N' )
    sls_normmenu(  'N/W,N/RB,,,BG/N' )
    sls_popcol(  'N/BG,RB+/N,,,W+/RB' )
    sls_popmenu(  'N/BG,W+/W,,,W+/RB' )
  CASE nChoice = 10
    sls_Normcol("N/B,W+/R,,,W+/G" )
    sls_Normmenu("N/B,BG+/N,,,W+/G" )
    sls_Popcol("W+/W,GR+/N,,,G/N" )
    sls_Popmenu("W+/W,G/B,,,G/N" )
  CASE nChoice = 11
    sls_normcol(  'W+/W,N/BG,,,W+/B' )
    sls_normmenu(  'W+/W,W/B,,,W+/B' )
    sls_popcol(  'W+/B,W+/BG,,,B/W' )
    sls_popmenu(  'W+/B,N/W,,,B/W' )
  CASE nChoice = 12
    sls_Normcol("G/N,W+/R,,,N/B" )
    sls_Normmenu("G/N,W+/B,,,N/B" )
    sls_Popcol("GR/N,W+/B,,,N/B" )
    sls_Popmenu("GR/N,W+/GR,,,N/B" )
  ENDCASE
  if nChoice > 0
    SattPut("DEFAULT")
  endif
ENDIF
RETURN nil

*: EOF: S_COLPIK.PRG


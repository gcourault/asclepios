#include "inkey.ch"
function wgt_meas
local i,nLast := 0
LOCAL nOldCursor     := setcursor(0)
LOCAL cInScreen      := Savescreen(0,0,24,79)
LOCAL cOldColor      := Setcolor(sls_normcol())
local nMenuChoice

*- draw boxes
@0,0,24,79 BOX sls_frame()
Setcolor(sls_popcol())
@1,1,12,40 BOX sls_frame()
@1,5 SAY '[Pesos & Medidas]'

DO WHILE .T.
  Setcolor(sls_popmenu())
  @03,3 PROMPT "Conversiones de Longitudes"
  @04,3 PROMPT "Conversiones de Areas     "
  @05,3 PROMPT "Conversiones de Pesos     "
  @06,3 PROMPT "Conversiones de Vol£menes "
  @07,3 PROMPT "Medidas de L¡quidos       "
  @09,3 PROMPT "Salir"

  MENU TO nMenuChoice
  Setcolor(sls_popcol())

  DO CASE
  CASE nMenuChoice = 0 .or. nMenuChoice = 6
    exit
  CASE nMenuChoice = 1 // length
    clength()
  CASE nMenuChoice = 2 // area
    carea()
  CASE nMenuChoice = 3 // weight
    cweight()
  CASE nMenuChoice = 4 // volume
    cvolume()
  CASE nMenuChoice = 5 // liquid measure
    cliquid()
  ENDCASE
END
Restscreen(0,0,24,79,cInScreen)
Setcolor(cOldColor)
setcursor(nOldCursor)
return nil

static func clength()
local aDesc := {;
                {"Salir                 ",nil},;
                {"Mil¡metros a Pulgadas ",{|n|n*.039370079  }},;
                {"Mil¡metros a Pies     ",{|n|n*.0032808399 }},;
                {"Mil¡metros a Yardas   ",{|n|n*.0010936133 }},;
                {"Mil¡metros a Millas   ",{|n|n*.0000006214 }},;
                {"Cent¡metros a Pulgadas",{|n|n*.39370079   }},;
                {"Cent¡metros a Pies    ",{|n|n*.032808399  }},;
                {"Cent¡metros a Yardas  ",{|n|n*.010936133  }},;
                {"Cent¡metros a Millas  ",{|n|n*.0000062137 }},;
                {"Metros a Pulgadas     ",{|n|n* 39.370079  }},;
                {"Metros a Pie          ",{|n|n* 3.2808399  }},;
                {"Metros a Yardas       ",{|n|n* 1.0936133  }},;
                {"Metros a Millas       ",{|n|n*.00062137119}},;
                {"Kil¢metros a Pulgadas ",{|n|n* 39.370079  }},;
                {"Kil¢metros a Pies     ",{|n|n* 3280.8399  }},;
                {"Kil¢metros a Yardas   ",{|n|n* 1093.6133  }},;
                {"Kil¢metros a Millas   ",{|n|n*.62137119   }},;
                {"Pulgadas a Mil¡metros ",{|n|n* 25.40      }},;
                {"Pulgadas a Cent¡metros",{|n|n* 2.54       }},;
                {"Pulgadas a Metros     ",{|n|n*.0254       }},;
                {"Pulgadas a Kil¢metros ",{|n|n*.0000254    }},;
                {"Pies a Mil¡metros     ",{|n|n* 304.8      }},;
                {"Pies a Cent¡metros    ",{|n|n* 30.48      }},;
                {"Pies a Metros         ",{|n|n*.3048       }},;
                {"Pies a Kil¢metros     ",{|n|n*.0003048    }},;
                {"Pies a Millas         ",{|n|n*.000189393  }},;
                {"Yardas a Mil¡metros   ",{|n|n* 914.4      }},;
                {"Yardas a Cent¡metros  ",{|n|n* 91.44      }},;
                {"Yardas a Metros       ",{|n|n*.9144       }},;
                {"Yardas a Kil¢metros   ",{|n|n*.0009144    }},;
                {"Yardas a Millas       ",{|n|n*.0005682    }},;
                {"Millas a Mil¡metros   ",{|n|n* 1609344    }},;
                {"Millas a Cent¡metros  ",{|n|n* 160934.4   }},;
                {"Millas a Metros       ",{|n|n* 1609.344   }},;
                {"Millas a Kil¢metros   ",{|n|n* 1.609344   }},;
                {"Millas a Pies         ",{|n|n* 5280       }},;
                {"Millas a Yardas       ",{|n|n* 1760       }}}
doconvert(aDesc)
return nil



static func carea()
local aDesc := {;
                {"Salir                        ",nil},;
                {"Mil¡metrosý a Pulgadasý      ",{|n|n*.0015500031      }},;
                {"Mil¡metrosý a Piesý          ",{|n|n*.00001076391     }},;
                {"Mil¡metrosý a Yardasý        ",{|n|n*.00000119599     }},;
                {"Cent¡metrosý a Pulgadasý     ",{|n|n*.15500031        }},;
                {"Cent¡metrosý a Piesý         ",{|n|n*.001076391       }},;
                {"Cent¡metrosý a Yardasý       ",{|n|n*.000119599       }},;
                {"Metrosý a Pulgadasý          ",{|n|n*1550.0031        }},;
                {"Metrosý a Piesý              ",{|n|n*10.76391         }},;
                {"Metrosý a Yardasý            ",{|n|n*1.19599          }},;
                {"Metrosý a Millasý            ",{|n|n*00000038610216   }},;
                {"Kil¢metrosý a Piesý          ",{|n|n*1076391          }},;
                {"Kil¢metrosý a Yardasý        ",{|n|n*1195990          }},;
                {"Kil¢metrosý a Millasý        ",{|n|n*.38610216        }},;
                {"Pulgadasý a Mil¡metrosý      ",{|n|n*645.16           }},;
                {"Pulgadasý a Cent¡metrosý     ",{|n|n*6.4516           }},;
                {"Pulgadasý a Metrosý          ",{|n|n*.00064516        }},;
                {"Piesý a Mil¡metrosý          ",{|n|n*92903.04         }},;
                {"Piesý a Cent¡metrosý         ",{|n|n*929.0304         }},;
                {"Piesý a Metrosý              ",{|n|n*.09290304        }},;
                {"Piesý a Kil¢metrosý          ",{|n|n*000000929        }},;
                {"Piesý a Acres                ",{|n|n*.00002296        }},;
                {"Yardasý a Mil¡metrosý        ",{|n|n*836100           }},;
                {"Yardasý a Cent¡metrosý       ",{|n|n*8361.2736        }},;
                {"Yardasý a Metrosý            ",{|n|n*0.83612736       }},;
                {"Yardasý a Acres              ",{|n|n*0.00020661157    }},;
                {"Millasý a Metrosý            ",{|n|n*2589988.1        }},;
                {"Millasý a Kil¢metrosý        ",{|n|n*2.5899881        }},;
                {"Millasý a Acres              ",{|n|n*640              }},;
                {"Acres a Piesý                ",{|n|n*43560            }},;
                {"Acres a Yardasý              ",{|n|n*4840             }},;
                {"Acres a Millasý              ",{|n|n*.0015626         }}}
doconvert(aDesc)
return nil

static func cweight()
local aDesc := {;
                {"Salir                      ",nil},;
                {"Miligramos a Onzas         ",{|n|n*.000035273962  }},;
                {"Miligramos Libras          ",{|n|n*.0000022046226 }},;
                {"Gramos a Onzas             ",{|n|n*.03527396      }},;
                {"Gramos a Libras            ",{|n|n*.002204623     }},;
                {"Gramos a Toneladas Cortas  ",{|n|n*.0000011023    }},;
                {"Kilogramos a Onzas         ",{|n|n*35.273962      }},;
                {"Kilogramos a Libras        ",{|n|n*2.2046226      }},;
                {"Kilogramos a Ton Cortas    ",{|n|n*.0011023       }},;
                {"Toneladas M‚tricas a Onzas ",{|n|n*35273.962      }},;
                {"Tonelads M‚tricas a Libras ",{|n|n*2204.6226      }},;
                {"Ton M‚tricas a Ton Cortas  ",{|n|n*1.1023113      }},;
                {"Onzas a Miligramos         ",{|n|n*28349.523      }},;
                {"Onzas a Gramos             ",{|n|n*28.349523      }},;
                {"Onzas a Kilogramos         ",{|n|n*.028349523     }},;
                {"Onzas a Libras             ",{|n|n*.0625          }},;
                {"Onzas a Toneladas cortas   ",{|n|n*.00003125      }},;
                {"Libras a Miligramos        ",{|n|n*453592.37      }},;
                {"Libras a Gramos            ",{|n|n*453.59237      }},;
                {"Libras a Kilogramos        ",{|n|n*.45359237      }},;
                {"Libras a Onzas             ",{|n|n*16             }},;
                {"Libras a Ton M‚tricas      ",{|n|n*.00045359237   }},;
                {"Libras a Toneladas Cortas  ",{|n|n*.0005          }},;
                {"Ton Cortas a Kilogramos    ",{|n|n*907.18474      }},;
                {"Ton Cortas a Onzas         ",{|n|n*32000.0        }},;
                {"Ton Cortas a Libras        ",{|n|n*2000           }},;
                {"Ton Cortas a Ton M‚tricas  ",{|n|n*0.90718474     }}}

doconvert(aDesc)
return nil

static func cvolume()
local aDesc := {;
                {"Salir                             ",nil},;
                {"Cent¡metros cub. a Pulgadas cub.  ",{|n|n*0.061023744 }},;
                {"Cent¡metros cub. a Pies cub.      ",{|n|n*.00003531467}},;
                {"Cent¡metros cub. a Yardas cub.    ",{|n|n*.00000130795}},;
                {"Cent¡metros cub. a Metros cub.    ",{|n|n*.000001     }},;
                {"Pulgadas cub. a Cent¡metros cub.  ",{|n|n*16.387064   }},;
                {"Pulgadas cub. a Pies cub.         ",{|n|n*.0005787037 }},;
                {"Pulgadas cub. a Yardas cub.       ",{|n|n*.00002143347}},;
                {"Pulgadas cub. a Metros cub.       ",{|n|n*.00001638706}},;
                {"Pies cub. a Cent¡metros cub.      ",{|n|n*28316.847   }},;
                {"Pies cub. a Pulgadas cub.         ",{|n|n*1728        }},;
                {"Pies cub. a Yardas cub.           ",{|n|n*0.03704     }},;
                {"Pies cub. a Metros cub.           ",{|n|n*0.028316847 }},;
                {"Yardas cub. a Cent¡metros cub.    ",{|n|n*764554.86   }},;
                {"Yardas cub. a Pulgadas cub.       ",{|n|n*46656       }},;
                {"Yardas cub. a Pies cub.           ",{|n|n*27          }},;
                {"Yardas cub. a Metros cub.         ",{|n|n*0.76455486  }}}
doconvert(aDesc)
return nil

static func cliquid()
local aDesc := {;
                {"Salir                         ",nil},;
                {"Mililitros a Litros           ",{|n|n*.001        }},;
                {"Mililitros a Onzas L¡quidas   ",{|n|n*.03381497   }},;
                {"Mililitros a Pintas           ",{|n|n*.002113436  }},;
                {"Mililitros a Cuartos          ",{|n|n*.001057     }},;
                {"Mililitros a Galones          ",{|n|n*.0002642    }},;
                {"Litros a Mililitros           ",{|n|n*1000        }},;
                {"Litros a Onzas L¡quidas       ",{|n|n*33.81497    }},;
                {"Litros a Pintas               ",{|n|n*2.113436    }},;
                {"Litros a Cuartos              ",{|n|n*1.056718    }},;
                {"Litros a Galones              ",{|n|n*.2641794    }},;
                {"Onzas L¡quidas a Mililitros   ",{|n|n*29.57352956 }},;
                {"Onzas L¡quidas a Litros       ",{|n|n*.029573529  }},;
                {"Onzas L¡quidas a Pintas       ",{|n|n*.0625       }},;
                {"Onzas L¡quidas a Cuartos      ",{|n|n*.03125      }},;
                {"Onzas L¡quidas a Galones      ",{|n|n*.0078125    }},;
                {"Pintas a Mililitros           ",{|n|n*473.1631    }},;
                {"Pintas a Litros               ",{|n|n*.4731631    }},;
                {"Pintas a Onzas L¡quidas       ",{|n|n*16          }},;
                {"Pintas a Cuartos              ",{|n|n*.5          }},;
                {"Pintas a Galones              ",{|n|n*.125        }},;
                {"Cuartos a Mililitros          ",{|n|n*946.3263    }},;
                {"Cuartos a Litros              ",{|n|n*.9463263    }},;
                {"Cuartos a Onzas L¡quidas      ",{|n|n*32          }},;
                {"Cuartos a Pintas              ",{|n|n*2           }},;
                {"Cuartos a Galones             ",{|n|n*.25         }},;
                {"Galones a Mililitros          ",{|n|n*3785.306    }},;
                {"Galones a Litros              ",{|n|n*3.785306    }},;
                {"Galones a Onzas L¡quidas      ",{|n|n*128         }},;
                {"Galones a Pintas              ",{|n|n*8           }},;
                {"Galones a Cuartos             ",{|n|n*4           }}}
doconvert(aDesc)
return nil

//--------------------------------------------------------------------
static func doconvert(aConvert)
local nLastKey
local nRow := 1
local cBox := makebox(3,14,21,57)
local oTb  := tBrowseNew(4,15,20,56)
local nLastValue := 0
oTb:addcolumn(tbcolumnNew(nil,{||aConvert[nRow,1]}))
oTb:skipblock :={|n|aaskip(n,@nRow,LEN(aConvert))}
oTb:gotopblock :={||nRow := 1}
oTb:gobottomblock :={||nrow := len(aConvert)}
while .t.
  while !oTb:stabilize()
  end
  nLastKey := inkey(0)
  do case
  case nLastKey = K_UP
    oTb:up()
  case nLastKey = K_DOWN
    oTb:down()
  case nLastKey = K_PGUP
    oTb:Pageup()
  case nLastKey = K_PGDN
    oTb:Pagedown()
  case nLastKey = K_HOME
    oTb:gotop()
  case nLastKey = K_END
    oTb:gobottom()
  case nLastKey = K_ENTER .and. nRow = 1
    exit
  case nLastKey = K_ENTER
    nLastValue := doformula(aConvert[nRow,1],aConvert[nRow,2],@nLastValue)
  case nLastKey = K_ESC
     exit
  endcase
end
unbox(cBox)
return nil
//--------------------------------------------------------------------
static function doformulA(cDesc,bFormula,nLastValue)
local nDecimals := SET(_SET_DECIMALS,5)
local cBox      := makebox( 6,7,13,73)
local getlist := {}
@ 7,9 SAY cDesc
@ 10,9 SAY "igual  "
@ 12,9 SAY "ESC para salir"
@9,34 SAY   left(cDesc,at(" a ",cDesc))
@10,34 SAY  subst(cDesc,at(" a ",cDesc)+4)
do while .t.
     @10,16 say eval(bFormula,nLastValue) pict "99999999.99999"
     @ 9,16 get nLastValue pict "99999999.99999"
     set cursor on
     read
     set cursor off
     if lastkey()=27
       exit
     endif
enddo
unbox(cBox)
SET(_SET_DECIMALS,nDecimals)
return eval(bFormula,nLastValue)


//-------------------------------------------------------------


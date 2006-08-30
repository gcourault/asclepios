#include "common.ch"
#include "inkey.ch"

static Static1, Static2, Static3, Static4
static Static5, Static6, Static7, Static8

********************************
function SM_BARPAD(Arg1)

   Static2[44]:= Arg1
   return Nil

********************************
function BOX_MASK

   local Local1
   Local1:= array(14)
   Local1[1]:= 0
   Local1[2]:= 0
   Local1[3]:= 0
   Local1[4]:= 0
   Local1[5]:= {}
   Local1[6]:= "ÚÄ¿³ÙÄÀ³ "
   Local1[7]:= 0
   Local1[8]:= 0
   Local1[9]:= Nil
   Local1[10]:= 0
   Local1[11]:= 0
   Local1[12]:= 0
   Local1[13]:= 0
   Local1[14]:= .F.
   return Local1

********************************
static function GLOBAL_MAS

   local Local1
   Local1:= array(78)
   Local1[4]:= "N/W"
   Local1[5]:= "W/N"
   Local1[6]:= "N+/W"
   Local1[7]:= "W+/W"
   Local1[8]:= "W+/N"
   Local1[9]:= "N/BG"
   Local1[10]:= "W/N"
   Local1[2]:= "N/W"
   Local1[3]:= "N/W"
   Local1[15]:= i_mexist()
   Local1[16]:= 0
   Local1[17]:= 0
   Local1[20]:= box_mask()
   Local1[20][1]:= 0
   Local1[20][2]:= 0
   Local1[20][3]:= 24
   Local1[20][4]:= 79
   Local1[20][6]:= "ÚÄ¿³ÙÄÀ³ "
   Local1[24]:= .F.
   Local1[25]:= box_mask()
   Local1[26]:= .T.
   Local1[27]:= .F.
   Local1[28]:= .F.
   Local1[29]:= .T.
   Local1[30]:= "Menu"
   Local1[32]:= .F.
   Local1[31]:= box_mask()
   Local1[34]:= .F.
   Local1[35]:= "[þ]"
   Local1[36]:= box_mask()
   Local1[37]:= "N/W"
   Local1[40]:= 1
   Local1[41]:= 1
   Local1[42]:= 1
   Local1[43]:= 1
   Local1[44]:= 2
   Local1[45]:= "Ã"
   Local1[46]:= "Ä"
   Local1[47]:= "´"
   Local1[48]:= "ÚÄ¿³ÙÄÀ³ "
   Local1[49]:= {Nil, Nil}
   Local1[50]:= .F.
   Local1[51]:= .F.
   Local1[52]:= .F.
   Local1[53]:= .F.
   Local1[54]:= .F.
   Local1[55]:= .F.
   Local1[56]:= .F.
   Local1[57]:= 0
   Local1[58]:= 0
   Local1[59]:= 0
   Local1[60]:= 0
   Local1[61]:= .F.
   Local1[62]:= .F.
   Local1[63]:= .F.
   Local1[66]:= .F.
   Local1[64]:= .F.
   Local1[67]:= {}
   Local1[68]:= 0
   Local1[69]:= {|_1, _2, _3, _4| (DevPos(_1, _2), DevOut(_3, _4))}
   Local1[70]:= {|_1, _2, _3, _4, _5, _6| DispBox(_1, _2, _3, _4, ;
      _5, _6)}
   Local1[71]:= {|| i_mexist()}
   Local1[72]:= {|| i_mrightb()}
   Local1[73]:= {|| i_mleftb()}
   Local1[74]:= {|_1, _2| i_mposit(_1, _2)}
   Local1[75]:= {|| i_mon()}
   Local1[76]:= {|| i_moff()}
   Local1[77]:= {|| i_mrowl()}
   Local1[78]:= {|| i_mcoll()}
   return Local1

********************************
function OPTION_MAS

   local Local1
   Local1:= array(16)
   Local1[1]:= " "
   Local1[2]:= 0
   Local1[3]:= ""
   Local1[5]:= Nil
   Local1[6]:= .T.
   Local1[7]:= ""
   Local1[8]:= 0
   Local1[9]:= 0
   Local1[10]:= 0
   Local1[11]:= 0
   Local1[12]:= .F.
   Local1[13]:= .F.
   Local1[14]:= .F.
   Local1[15]:= .F.
   Local1[16]:= 0
   return Local1

********************************
function SM_ERRMSG(Arg1)

   @ 24,  0
   @ 24,  0 say Arg1
   quit
   return Nil

********************************
function SM_MENBARO(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

   local Local1, Local2, Local3
   if (Len(Static4) == 0)
      if (ISNIL(Arg6))
         if (Static3[13] > 0)
            Arg6:= ATail(Static3[5])[11] + iif(Arg3 != Nil, Arg3, ;
               Static2[44]) + 1
         else
            Arg6:= Static3[2] + iif(Arg3 != Nil, Arg3, 0)
         endif
      endif
      Arg4:= iif(Arg4 != Nil, Arg4, "")
      Local3:= At("~", Arg1)
      Arg1:= strtran(Arg1, "~")
      Local1:= iif(Local3 > 0, Local3, 1)
      AAdd(Static3[5], option_mas())
      Static3[13]++
      Local2:= ATail(Static3[5])
      Local2[1]:= Arg1
      Local2[3]:= SubStr(Arg1, Local1, 1)
      Local2[7]:= Arg4
      Local2[8]:= iif(Arg2 != Nil, Arg2, "")
      Local2[10]:= Arg6
      Local2[9]:= Static1[1]
      Local2[11]:= Local2[10] + Len(Local2[1]) - 1
      Local2[4]:= Local1
      Local2[2]:= Local1 + Local2[10] - 1
      Local2[14]:= .T.
      Local2[16]:= iif(Arg5 != Nil, Arg5, 0)
   else
      sm_errmsg("Attempt to add a bar option to a box (" + Arg1 + ")")
   endif
   return Nil

********************************
function SM_MENBOX(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8)

   Static2[48]:= iif(Arg1 != Nil, Arg1, Static2[48])
   Static2[43]:= iif(Arg2 != Nil, Arg2, Static2[43])
   Static2[42]:= iif(Arg3 != Nil, Arg3, Static2[42])
   Static2[40]:= iif(Arg4 != Nil, Arg4, Static2[40])
   Static2[41]:= iif(Arg5 != Nil, Arg5, Static2[41])
   Static2[45]:= iif(ISNIL(Arg6), Static2[45], Arg6)
   Static2[46]:= iif(ISNIL(Arg7), Static2[46], Arg7)
   Static2[47]:= iif(ISNIL(Arg8), Static2[47], Arg8)
   return Nil

********************************
function SM_MENBOXO(Arg1, Arg2, Arg3)

   local Local1, Local2, Local3, Local4, Local5, Local6
   if (Len(Static4) > 0)
      Local4:= Static3[13] + 1
      Local3:= At("~", Arg1)
      Arg1:= strtran(Arg1, "~")
      Local1:= iif(Local3 > 0, Local3, 1)
      Local5:= Static3[2] + Static2[40] + 1
      Local6:= Static3[1] + Local4
      Arg3:= iif(Arg3 != Nil, Arg3, "")
      AAdd(Static3[5], option_mas())
      Static3[3]++
      Static3[13]++
      Local2:= Static3[5][Static3[13]]
      Local2[1]:= Arg1
      Local2[3]:= SubStr(Arg1, Local1, 1)
      Local2[6]:= iif(Arg2 != Nil, .T., .F.)
      Local2[7]:= Arg3
      Local2[8]:= Arg2
      Local2[10]:= Local5
      Local2[9]:= Local6
      Local2[4]:= Local1
      Local2[2]:= Local1 + Local2[10] - 1
      Local2[14]:= Arg2 != Nil
      Local2[13]:= ISNIL(Arg2)
   else
      sm_errmsg("Attempt to add a box option to top bar (" + Arg1 + ;
         ")")
   endif
   return Nil

********************************
function SM_MENCOL(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, ;
   Arg9)

   Static2[5]:= iif(Arg1 != Nil, Arg1, Static2[5])
   Static2[8]:= iif(Arg2 != Nil, Arg2, Static2[8])
   Static2[4]:= iif(Arg3 != Nil, Arg3, Static2[4])
   Static2[7]:= iif(Arg4 != Nil, Arg4, Static2[7])
   Static2[6]:= iif(Arg5 != Nil, Arg5, Static2[6])
   Static2[9]:= iif(Arg9 != Nil, Arg9, Static2[9])
   Static2[10]:= iif(Arg6 != Nil, Arg6, Static2[10])
   Static2[2]:= iif(Arg7 != Nil, Arg7, Static2[2])
   Static2[3]:= iif(Arg8 != Nil, Arg8, Static2[3])
   return Nil

********************************
function SM_MENDROP(Arg1, Arg2, Arg3)

   local Local1, Local2, Local3, Local4, Local5, Local6, Local7, ;
      Local8
   Local3:= 0
   if (Arg1)
      Local4:= Static3[5][Static3[13]][9]
      Local5:= Static3[5][Static3[13]][10]
      Arg2:= iif(Arg2 != Nil, Arg2, Static2[42])
      Arg3:= iif(Arg3 != Nil, Arg3, Static2[43])
      AAdd(Static4, Static3)
      ATail(Static3[5])[5]:= box_mask()
      Static3:= ATail(Static3[5])[5]
      Static3[1]:= Local4 + Arg2
      Static3[2]:= Local5 + Arg3
      Static3[3]:= Static3[1] + 1
      Static3[5]:= {}
      Static3[13]:= 0
      Static3[6]:= Static2[48]
      Local6:= Static3
   else
      if (Static3[13] == 0)
         sm_errmsg("No options added to box")
      endif
      aeval(Static3[5], {|_1| Local3:= Max(Local3, Len(_1[1]))})
      Static3[4]:= Static3[2] + Local3 + Static2[40] + Static2[41] + 1
      Static3[10]:= Static3[4] - Static3[2] - 1 - Static2[40] - ;
         Static2[41]
      Local8:= Static3[5]
      for Local7:= 1 to Len(Local8)
         if (!Local8[Local7][15])
            Local8[Local7][1]:= padr(Local8[Local7][1], Static3[10])
            Local8[Local7][11]:= Static3[4] - (Static2[41] + 1)
         endif
      next
      Static3:= ATail(Static4)
      Local1:= ATail(Static3[5])
      Local1[12]:= .T.
      Local1[13]:= .F.
      Local1[14]:= .F.
      asize(Static4, Len(Static4) - 1)
   endif
   return Static3

********************************
function SM_MENFD(Arg1)

   Static2[64]:= Arg1
   Static2[66]:= Arg1
   return Nil

********************************
function SM_MENINIT(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, ;
   Arg9, Arg10, Arg11, Arg12, Arg13)

   Static2:= global_mas()
   Static4:= {}
   Static1:= box_mask()
   Static1[6]:= Space(9)
   Static3:= Static1
   if (Arg1 != Nil .AND. Arg2 != Nil .AND. Arg3 != Nil .AND. Arg4 != ;
         Nil)
      Static2[20][1]:= Arg1
      Static2[20][3]:= Arg3
      Static2[20][2]:= Arg2
      Static2[20][4]:= Arg4
   endif
   if (Arg5 != Nil)
      Static2[20][6]:= Arg5
   elseif (Arg6 != Nil .AND. Arg6)
      Static2[20][6]:= Nil
   endif
   if (Arg7 != Nil .AND. Arg7)
      Static2[24]:= .T.
      if (Arg8)
         Static2[27]:= .T.
      endif
      Static2[25][6]:= Space(9)
      if (Arg9 != Nil)
         Static2[26]:= Arg9
      endif
   endif
   if (Arg10 != Nil .AND. Arg10)
      Static2[28]:= .T.
      if (Arg12)
         Static2[32]:= .T.
      endif
      Static2[31][6]:= Space(9)
      if (Arg13 != Nil)
         Static2[29]:= Arg13
      endif
      if (Arg11 != Nil)
         Static2[30]:= alltrim(Arg11)
      endif
   endif
   sm_winadj()
   return Nil

********************************
function SM_MENWRAP

   return {Static1, Static2}

********************************
function SM_MENX

   local Local1, Local2, Local3, Local4
   if (Len(Static4) > 0)
      Local2:= Static3[13] + 1
      Local3:= Static3[1] + Local2
      AAdd(Static3[5], option_mas())
      Static3[3]++
      Static3[13]++
      Local1:= ATail(Static3[5])
      Local2:= Len(Static3[5])
      Local4:= Static3[2]
      Local3:= Static3[1] + Local2
      Local1[1]:= ""
      Local1[2]:= 0
      Local1[4]:= 0
      Local1[3]:= ""
      Local1[6]:= .F.
      Local1[10]:= Local4
      Local1[9]:= Local3
      Local1[15]:= .T.
      Local1[8]:= ""
   endif
   return Nil

********************************
function SM_MOUSEX(Arg1, Arg2, Arg3, Arg4)

   local Local1
   Local1:= Len(Arg3)
   Static2[34]:= .T.
   Static2[36][1]:= Arg1
   Static2[36][2]:= Arg2
   Static2[36][3]:= Arg1
   Static2[36][4]:= Arg2 + Local1 - 1
   Static2[37]:= iif(Arg4 != Nil, Arg4, Static2[37])
   Static2[35]:= Arg3
   return Nil

********************************
function SM_SETGLOB(Arg1, Arg2)

   if (Arg1 != Nil .AND. Arg2 != Nil)
      Static2[Arg1]:= Arg2
   endif
   return Nil

********************************
function SM_SETMOUS(Arg1)

   Static2[15]:= Arg1
   return Nil

********************************
function SM_WINADJ

   local Local1
   Local1:= Static2[20][6] != Nil
   if (Static2[28])
      Static2[31][2]:= Static2[20][2] + iif(Local1, 1, 0)
      Static2[31][4]:= Static2[20][4] - iif(Local1, 1, 0)
      Static2[31][1]:= Static2[20][1] + 1
      Static2[31][3]:= Static2[20][1] + 1
      if (Static2[32])
         Static2[31][1]--
         Static2[31][3]--
      endif
      Static2[31][10]:= Static2[31][4] - Static2[31][2] + 1
   endif
   if (Static2[24])
      Static2[25][2]:= Static2[20][2] + iif(Local1, 1, 0)
      Static2[25][4]:= Static2[20][4] - iif(Local1, 1, 0)
      Static2[25][1]:= Static2[20][3] - 1
      Static2[25][3]:= Static2[20][3] - 1
      if (Static2[27])
         Static2[25][1]++
         Static2[25][3]++
      endif
      Static2[25][10]:= Static2[25][4] - Static2[25][2] + 1
   endif
   Static1[2]:= Static2[20][2] + iif(Local1, 1, 0)
   Static1[4]:= Static2[20][4] - iif(Local1, 1, 0)
   Static1[1]:= Static2[20][1] + 1
   Static1[3]:= Static2[20][1] + 1
   if (Static2[28] .AND. !Static2[32])
      Static1[1]++
      Static1[3]++
   endif
   return Nil

********************************
static function SM_BOX(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

   eval(Static6[70], Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
   return Nil

********************************
function SM_DO(Arg1)

   local Local1
   sm_menuset(Arg1)
   if (Static6[15])
      eval(Static6[74], Static6[16], Static6[17])
   endif
   do while (.T.)
      do case
      case Static5[1][7] != Static5[1][8]
         sm_topchg()
      case Static6[52] .OR. (Static6[55] .OR. Static6[56]) .AND. ;
            Static6[68] > 2
         sm_popbox(Static7)
         Static7:= sm_popleve()
         Static8:= Static7[5]
         Static6[51]:= .T.
      case Static6[53]
         Static6[64]:= .T.
         Static7:= sm_pushlev(Static8[Static7[7]][5])
         Static8:= Static7[5]
         sm_pushbox(Static7)
      case Static6[55]
         Static5[1][8]:= sm_oprior(Static5[1][5], Static5[1][7])
         sm_topchg()
      case Static6[56]
         Static5[1][8]:= sm_opnext(Static5[1][5], Static5[1][7])
         sm_topchg()
      endcase
      if (!Static7[14])
         sm_saybox(Static7)
         sm_sayop(Static8)
         Static7[8]:= sm_opnext(Static8, 0)
         Static7[7]:= Static7[8]
      elseif (Static7[7] > 0 .AND. !Static8[Static7[7]][6])
         Static7[8]:= sm_opnext(Static8, 0)
         Static7[7]:= Static7[8]
         sm_sayop(Static8)
      elseif (Static6[51])
         sm_sayop(Static8)
      endif
      Static6[49]:= {Nil, Nil}
      Static6[50]:= .F.
      Static6[51]:= .F.
      Static6[52]:= .F.
      Static6[57]:= 0
      Static6[58]:= 0
      Static6[59]:= 0
      Static6[53]:= .F.
      Static6[54]:= .F.
      Static6[55]:= .F.
      Static6[56]:= .F.
      Static6[61]:= .F.
      Static6[62]:= .F.
      Static6[63]:= .F.
      do while (!(Static6[54] .OR. Static6[55] .OR. Static6[56] .OR. ;
            Static6[61] .OR. Static6[62] .OR. Static6[53] .OR. ;
            Static6[52] .OR. Static6[63] .OR. Static6[50]))
         sm_opswitc()
         sm_event(Static8)
         if (Static6[58] == 450)
            do case
            case Static6[57] = 24
               Static7[8]:= sm_opnext(Static8, Static7[7])
            case Static6[57] = 5
               Static7[8]:= sm_oprior(Static8, Static7[7])
            case Static6[57] = 13 .AND. Static7[7] == 0
            case Static6[57] = 13 .AND. Static8[Static7[7]][14]
               Static6[61]:= .T.
            case Static6[57] = 13
               Static6[53]:= .T.
            case Static6[57] = 27
               if (Static6[68] > 2)
                  Static6[52]:= .T.
               elseif (Static6[68] == 2)
                  Static6[52]:= .T.
                  Static6[64]:= .F.
               else
                  Static6[62]:= .T.
               endif
            case Static6[57] == 19
               Static6[55]:= .T.
            case Static6[57] == 4
               Static6[56]:= .T.
            case (Local1:= sm_trigat(Static8, Static6[57])) > 0
               Static7[8]:= Local1
               if (Static8[Local1][12])
                  Static6[53]:= .T.
               else
                  Static6[61]:= .T.
               endif
               sm_opswitc()
            case (Local1:= sm_trigat(Static5[1][5], Static6[57])) > 0
               if (Local1 != Static5[1][7])
                  Static5[1][8]:= Local1
                  Static6[54]:= .T.
                  Static6[64]:= .T.
               endif
            case (Local1:= sm_topat(Static5[1][5], Static6[57])) > 0
               if (Local1 != Static5[1][7])
                  Static5[1][8]:= Local1
                  Static6[54]:= .T.
                  Static6[64]:= .T.
               endif
            otherwise
               Static6[62]:= .T.
            endcase
         elseif (Static6[58] == 451)
            do case
            case Static6[59] == 4000
               Static6[63]:= .T.
            case Static6[59] == 3000
               if (Static6[68] > 2)
                  Static6[52]:= .T.
               elseif (Static6[68] == 2)
                  Static6[52]:= .T.
                  Static6[64]:= .F.
               endif
            case Static6[59] > 2000
               Static5[1][8]:= Static6[59] - 2000
               Static6[54]:= .T.
            case Static6[59] > 1000
               Static7[8]:= Static6[59] - 1000
               if (Static8[Static7[8]][12])
                  Static6[53]:= .T.
               else
                  Static6[61]:= .T.
               endif
               sm_opswitc()
            case Static6[50]
            endcase
         endif
      enddo
      if (Static7[7] > 0)
         Static6[60]:= Static8[Static7[7]][8]
      else
         Static6[60]:= 0
      endif
      if (Static6[61] .OR. Static6[62] .OR. Static6[63] .OR. ;
            Static6[50])
         if (Static6[15])
            Static6[16]:= eval(Static6[77])
            Static6[17]:= eval(Static6[78])
         endif
         exit
      endif
   enddo
   return Nil

********************************
static function SM_EVENT(Arg1)

   local Local1:= 0, Local2:= 0, Local3, Local4, Local5, Local6:= 0, ;
      Local7:= 0
   Static6[58]:= 0
   if (Static6[15])
      eval(Static6[75])
   endif
   do while (Static6[58] == 0)
      Local1:= InKey()
      if (Static6[15] .AND. eval(Static6[73]))
         Local6:= eval(Static6[77])
         Local7:= eval(Static6[78])
         if ((Local3:= sm_minbox(Arg1, Local6, Local7)) > 0)
            Static6[58]:= 451
            Static6[59]:= 1000 + Local3
         elseif ((Local4:= sm_minbox(Static5[1][5], Local6, Local7)) ;
               > 0)
            Static6[58]:= 451
            Static6[59]:= 2000 + Local4
         elseif (sm_minex(Local6, Local7))
            Static6[58]:= 451
            Static6[59]:= 4000
         else
            Static6[58]:= 451
            Static6[49]:= {Local6, Local7}
            Static6[50]:= .T.
         endif
         do while (eval(Static6[73]))
         enddo
      elseif (Static6[15] .AND. eval(Static6[72]))
         Static6[58]:= 451
         Static6[59]:= 3000
         do while (eval(Static6[72]))
         enddo
      elseif (Local1 != 0)
         Static6[57]:= Local1
         Static6[58]:= 450
      endif
   enddo
   if (Static6[15])
      eval(Static6[76])
   endif
   return Nil

********************************
function SM_EXREQ

   return Static6[63]

********************************
static function SM_GETHAND(Arg1, Arg2)

   local Local1, Local2
   for Local1:= 1 to Len(Arg1)
      if (Arg1[Local1][8] == Arg2)
         Local2:= Arg1[Local1]
         exit
      endif
      if (Arg1[Local1][12])
         if ((Local2:= sm_gethand(Arg1[Local1][5][5], Arg2)) != Nil)
            exit
         endif
      endif
   next
   return Local2

********************************
function SM_HANDLE

   return Static6[60]

********************************
function SM_KEX

   return Static6[62]

********************************
function SM_LASTKEY

   return Static6[57]

********************************
function SM_MCOL

   return Static6[49][2]

********************************
function SM_MENUOFF(Arg1, Arg2)

   local Local1, Local2
   Static5:= Arg1
   Arg2:= iif(Arg2 != Nil, Arg2, .T.)
   Local2:= iif(Arg2, 1, 2)
   Static6:= Static5[2]
   do while (Static6[15] .AND. (eval(Static6[72]) .OR. ;
         eval(Static6[73])))
   enddo
   dispbegin()
   for Local1:= Static6[68] to Local2 step -1
      Static7:= Static6[67][Local1]
      Static8:= Static7[5]
      sm_popbox(Static7)
   next
   if (Arg2)
      if (Static6[34])
         sm_popbox(Static6[36])
      endif
      if (Static6[24])
         sm_popbox(Static6[25])
      endif
      if (Static6[28])
         sm_popbox(Static6[31])
      endif
      sm_popbox(Static6[20])
   endif
   dispend()
   return Nil

********************************
function SM_MENUON(Arg1)

   local Local1
   Static5:= Arg1
   dispbegin()
   Static6:= Static5[2]
   if (!Static6[20][14])
      sm_pushbox(Static6[20])
      sm_saybox(Static6[20], Static6[10])
   endif
   if (Static6[28] .AND. !Static6[31][14])
      sm_pushbox(Static6[31])
      sm_saybox(Static6[31], Static6[9])
      if (Static6[29])
         sm_say(Static6[31][1], Static6[31][2], padc(Static6[30], ;
            Static6[31][10]), Static6[9])
      else
         sm_say(Static6[31][1], Static6[31][2], padr(Static6[30], ;
            Static6[31][10]), Static6[9])
      endif
   endif
   if (Static6[24] .AND. !Static6[25][14])
      sm_pushbox(Static6[25])
      sm_saybox(Static6[25], Static6[2])
   endif
   if (Static6[15] .AND. Static6[34] .AND. !Static6[36][14])
      sm_pushbox(Static6[36])
      Static6[36][14]:= .T.
      sm_say(Static6[36][1], Static6[36][2], Static6[35], Static6[37])
   endif
   if (Static6[68] == 0)
      Static7:= sm_pushlev(Static5[1])
      Static8:= Static7[5]
      Static7[7]:= 1
      Static7[8]:= 1
      sm_pushbox(Static7)
      sm_saybox(Static7)
      sm_sayop(Static8)
      sm_opswitc()
      if (Static6[64] .AND. Static8[Static7[7]][12])
         Static7:= sm_pushlev(Static8[Static7[7]][5])
         Static8:= Static7[5]
         sm_pushbox(Static7)
         sm_saybox(Static7)
         sm_sayop(Static8)
         Static7[8]:= sm_opnext(Static8, 0)
         Static7[7]:= Static7[8]
         sm_opswitc()
      endif
   else
      for Local1:= 1 to Static6[68]
         Static7:= Static6[67][Local1]
         Static8:= Static7[5]
         if (!Static7[14])
            sm_pushbox(Static7)
            sm_saybox(Static7)
            sm_sayop(Static8)
            if (Static8[Static7[7]][6])
               sm_opswitc()
            else
               Static7[8]:= sm_opnext(Static8, 0)
               Static7[7]:= Static7[8]
               sm_opswitc()
            endif
         endif
      next
   endif
   dispend()
   Static6[53]:= .F.
   Static6[54]:= .T.
   return Nil

********************************
function SM_MENUSET(Arg1)

   Static5:= Arg1
   Static6:= Static5[2]
   if (Static6[68] > 0)
      Static7:= Static6[67][Static6[68]]
      Static8:= Static7[5]
   endif
   return Nil

********************************
function SM_MEX

   return Static6[50]

********************************
static function SM_MINBOX(Arg1, Arg2, Arg3)

   local Local1, Local2, Local3
   Local1:= 0
   Local2:= Len(Arg1)
   for Local3:= 1 to Local2
      if (Arg2 == Arg1[Local3][9])
         if (Arg3 >= Arg1[Local3][10] .AND. Arg3 <= Arg1[Local3][11])
            if (Arg1[Local3][6])
               Local1:= Local3
            endif
            exit
         endif
      endif
   next
   return Local1

********************************
static function SM_MINEX(Arg1, Arg2)

   local Local1
   Local1:= .F.
   if (Static6[34])
      if (Arg1 == Static6[36][1])
         if (Arg2 >= Static6[36][2] .AND. Arg2 <= Static6[36][4])
            Local1:= .T.
         endif
      endif
   endif
   return Local1

********************************
function SM_MRESET(Arg1)

   Static5:= Arg1
   Static6:= Static5[2]
   Static5[1][8]:= 1
   sm_topchg()
   return Nil

********************************
function SM_MROW

   return Static6[49][1]

********************************
function SM_OPASET(Arg1, Arg2)

   local Local1, Local2
   if ((Local2:= sm_gethand(Static5[1][5], Arg1)) != Nil)
      Local1:= Local2[6]
      if (Arg2 != Nil)
         Local2[6]:= Arg2
         Static6[51]:= .T.
      endif
   endif
   return Local1

********************************
static function SM_OPNEXT(Arg1, Arg2)

   local Local1, Local2
   Local1:= Len(Arg1)
   Arg2:= iif(Arg2 == Local1, 1, Arg2 + 1)
   for Local2:= Arg2 to Local1
      if (Arg1[Local2][6])
         return Local2
      endif
   next
   if (Arg2 != 1)
      for Local2:= 1 to Arg2 - 1
         if (Arg1[Local2][6])
            return Local2
         endif
      next
   endif
   return 0

********************************
static function SM_OPRIOR(Arg1, Arg2)

   local Local1, Local2
   Local1:= Len(Arg1)
   Arg2:= iif(Arg2 == 1, Local1, Arg2 - 1)
   for Local2:= Arg2 to 1 step -1
      if (Arg1[Local2][6])
         return Local2
      endif
   next
   if (Arg2 != Local1)
      for Local2:= Local1 to Arg2 + 1 step -1
         if (Arg1[Local2][6])
            return Local2
         endif
      next
   endif
   return 0

********************************
static function SM_OPSWITC

   local Local1, Local2
   Local1:= Static7[7]
   Local2:= Static7[8]
   if (Local1 > 0)
      sm_say(Static8[Local1][9], Static8[Local1][10], ;
         Static8[Local1][1], Static6[4])
      sm_say(Static8[Local1][9], Static8[Local1][2], ;
         Static8[Local1][3], Static6[7])
   endif
   if (Local2 > 0)
      sm_say(Static8[Local2][9], Static8[Local2][10], ;
         Static8[Local2][1], Static6[5])
      sm_say(Static8[Local2][9], Static8[Local2][2], ;
         Static8[Local2][3], Static6[8])
      if (Static6[24])
         if (Static6[26])
            sm_say(Static6[25][1], Static6[25][2], ;
               padc(Static8[Local2][7], Static6[25][4] - ;
               Static6[25][2] + 1), Static6[2])
         else
            sm_say(Static6[25][1], Static6[25][2], ;
               padr(Static8[Local2][7], Static6[25][4] - ;
               Static6[25][2] + 1), Static6[2])
         endif
      endif
   endif
   Static7[7]:= Static7[8]
   return Nil

********************************
function SM_OPTSET(Arg1, Arg2)

   local Local1, Local2, Local3, Local4, Local5
   if ((Local3:= sm_gethand(Static5[1][5], Arg1)) != Nil)
      Local5:= Local3[1]
      if (Arg2 != Nil)
         Local4:= Len(Local3[1])
         Local1:= At("~", Arg2)
         Arg2:= strtran(Arg2, "~")
         Local2:= iif(Local1 > 0, Local1, 1)
         Local3[1]:= padr(Arg2, Local4)
         Local3[3]:= SubStr(Arg2, Local2, 1)
         Local3[2]:= Local2 + Local3[10] - 1
         Static6[51]:= .T.
      endif
   endif
   return Local5

********************************
static function SM_POPBOX(Arg1)

   if (Arg1[6] != Nil .AND. Arg1[14])
      RestScreen(Arg1[9][2], Arg1[9][3], Arg1[9][4], Arg1[9][5], ;
         Arg1[9][1])
   endif
   Arg1[9]:= Nil
   Arg1[14]:= .F.
   return Nil

********************************
static function SM_POPLEVE

   asize(Static6[67], Len(Static6[67]) - 1)
   Static6[68]--
   return ATail(Static6[67])

********************************
static function SM_PUSHBOX(Arg1)

   if (Arg1[6] != Nil)
      Arg1[9]:= {SaveScreen(Arg1[1], Arg1[2], Arg1[3], Arg1[4]), ;
         Arg1[1], Arg1[2], Arg1[3], Arg1[4]}
   endif
   return Nil

********************************
static function SM_PUSHLEV(Arg1)

   AAdd(Static6[67], Arg1)
   Static6[68]++
   return ATail(Static6[67])

********************************
function SM_REQUEST

   return Static6[61]

********************************
static function SM_SAY(Arg1, Arg2, Arg3, Arg4)

   eval(Static6[69], Arg1, Arg2, Arg3, Arg4)
   return Nil

********************************
static function SM_SAYBOX(Arg1, Arg2)

   local Local1, Local2, Local3
   Local2:= Arg1[5]
   dispbegin()
   if (ISNIL(Arg1[9]))
      sm_pushbox(Arg1)
   endif
   Arg2:= iif(ISNIL(Arg2), Static6[3], Arg2)
   if (Arg1[6] != Nil)
      sm_box(Arg1[1], Arg1[2], Arg1[3], Arg1[4], Arg1[6], Arg2)
   endif
   Arg1[14]:= .T.
   for Local1:= 1 to Arg1[13]
      if (Local2[Local1][13])
         sm_say(Local2[Local1][9], Local2[Local1][10], ;
            Local2[Local1][1], Arg2)
      elseif (Local2[Local1][15])
         Local3:= Static6[45] + Replicate(Static6[46], Arg1[10] + ;
            Static6[40] + Static6[41]) + Static6[47]
         sm_say(Local2[Local1][9], Arg1[2], Local3, Arg2)
      endif
   next
   dispend()
   return Nil

********************************
static function SM_SAYOP(Arg1)

   local Local1, Local2
   Local1:= Len(Arg1)
   for Local2:= 1 to Local1
      if (Arg1[Local2][14] .OR. Arg1[Local2][12])
         if (Arg1[Local2][6])
            sm_say(Arg1[Local2][9], Arg1[Local2][10], ;
               Arg1[Local2][1], Static6[4])
            sm_say(Arg1[Local2][9], Arg1[Local2][2], ;
               Arg1[Local2][3], Static6[7])
         else
            sm_say(Arg1[Local2][9], Arg1[Local2][10], ;
               Arg1[Local2][1], Static6[6])
         endif
      endif
   next
   return Nil

********************************
static function SM_TOPAT(Arg1, Arg2)

   local Local1, Local2
   Local2:= Len(Arg1)
   for Local1:= 1 to Local2
      if (Arg1[Local1][16] == Arg2)
         return Local1
      endif
   next
   return 0

********************************
static function SM_TOPCHG

   dispbegin()
   do while (Static6[68] > 1)
      sm_popbox(Static7)
      Static7:= sm_popleve()
   enddo
   Static8:= Static7[5]
   sm_opswitc()
   if (Static6[64] .AND. Static8[Static7[7]][12])
      Static7:= sm_pushlev(Static8[Static7[7]][5])
      Static8:= Static7[5]
      sm_pushbox(Static7)
   endif
   dispend()
   return Nil

********************************
static function SM_TRIGAT(Arg1, Arg2)

   local Local1, Local2, Local3
   Local2:= Len(Arg1)
   Local3:= Upper(Chr(Arg2))
   if (Arg2 > 31 .AND. Arg2 < 256)
      for Local1:= 1 to Local2
         if (Upper(Arg1[Local1][3]) == Local3)
            return Local1
         endif
      next
   endif
   return 0

* EOF


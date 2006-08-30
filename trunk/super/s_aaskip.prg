// nElement is by reference!
function aaskip(n,nelement,nrows)
  local skipcount := 0
  do case
  case n > 0
    do while nelement+skipcount < nrows  .and. skipcount < n
      skipcount++
    enddo
  case n < 0
    do while nelement+skipcount > 1 .and. skipcount > n
      skipcount--
    enddo
  endcase
  nelement += skipcount
return skipcount



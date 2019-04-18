USAGE: startStone [-h] [-b] [-C] [-N] [-R] [-r] [-w <waitstone-timeout>] <stone-name>

 Start the stone process for the given stone.

OPTIONS
  -b
     Start netldi
  -r 
     Restart stone if running
  -C 
     Startup for conversion.
  -h 
     display help
  -N
     Startup without transaction logs.
  -R
     Startup for restore 
  -w <waitstone-timeout>
     if present wait up to <waitstone-timeout> minutes for the stone to 
     properly start

EXAMPLES
  startStone -h
  startStone gs_326
  startStone -b gs_326
  startStone -w 5 gs_326


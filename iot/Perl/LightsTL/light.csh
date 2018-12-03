#!/bin/csh
# script to relaunch LightsTL GUI if
# it is terminated by a cew exception
# Peter Walsh Nov 30 2017

echo "in light.csh"
@ c = 0
@ s = 20
while ( $s == 20 ) 
   @ c++
   echo "run GUI " $c
   ./main.pl
   @ s = $status
   sleep 5
end
echo "done"

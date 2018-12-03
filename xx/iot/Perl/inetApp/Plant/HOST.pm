package inetApp::Plant::HOST;
#================================================================--
# File Name    : HOST.pm
#
# Purpose      : Plant set-up for HOST 
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;
use constant TRUE => 1;
use constant FALSE => 0;
use constant MAXSEL => 1 ;
use constant DEVPOLLFREQ => 0.1;

sub start {
   system('clear');

   my $inp;
   my $sel = -1;

   while (($sel < 0) || ($sel > MAXSEL))  {

      print ("\nHOST Boot Menu\n\n");
      print ("\tLAN 0\n");
      print ("\tWAN 1\n");
      print ("\nEnter selection (CTRL C to exit) ");
      $inp = <>;
      chop($inp);
      if (($inp =~ m/\d/) && (length($inp) == 1)) {
         $sel = int($inp);
      }

   }

   my $taskName;
   my $nicName;
   my $devName;

   if ($sel == 0) {
      # LAN 
      inetApp::Plant::LAN->start();
   } elsif ($sel == 1) {
      # WAN 
      inetApp::Plant::WAN->start();
   }    

}

1;

package inetApp::Plant::SETUP;
#================================================================--
# File Name    : SETUP.pm
#
# Purpose      : Plant set-up 
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
use constant MAXSEL => 1;

sub start {
   open(VFH, "< ../Documentation/Version") || die "Cant open Version File \n";
   Inet::Collection::NODE->set_version(<VFH>);
   system('clear');
   print("\n", Inet::Collection::NODE->get_version(), "\n");

   my $inp;
   my $sel = -1;

   while (($sel < 0) || ($sel > MAXSEL))  {

      print ("\nBoot Menu\n\n");
      print("\tNodes (devices NOT assigned inet IP addresses)  0\n");
      print("\tHosts (devices assigned inet IP addresses) 1 \n");
      print ("\nEnter selection (CTRL C to exit) ");
      $inp = <>;
      chop($inp);
      if (($inp =~ m/\d/) && (length($inp) == 1)) {
         $sel = int($inp);
      }

   }

   if ($sel == 0) {
      inetApp::Plant::NODE->start();
   } elsif ($sel == 1) {
      inetApp::Plant::HOST->start();
   }    
}

1;

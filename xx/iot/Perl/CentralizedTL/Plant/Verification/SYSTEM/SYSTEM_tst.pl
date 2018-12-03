#!/usr/bin/perl
######################################################
# Peter Walsh
# SYSTEM test driver
######################################################

$|=1;

use strict;
use warnings;
use lib '../../../../';
use Try::Tiny;
use AnyEvent;
use Gtk2 -init;
use Gnome2::Canvas;
use CentralizedTL::Plant::SYSTEM;
use Tosf::Exception::Monitor;
use Tosf::Table::SVAR;
use Tosf::Record::SVar;


use constant FALSE => 0;
use constant TRUE => 1;

my $state = 0;
# Note, the GUI callback is not wrapped in
# a try catch block so will not trap cew exceptions 
Tosf::Table::SVAR->add(name => "sv_car", value => 0);
my $d = AnyEvent->timer(
   after => 3,
   interval => 3,
   cb => sub {
      if ($state == 0) {
         CentralizedTL::Plant::SYSTEM->set_lights("gray", "gray", "green", "red", "gray", "gray");
         $state = 1;
      } elsif ($state == 1) {
	      CentralizedTL::Plant::SYSTEM->set_lights("gray", "yellow", "gray", "red", "gray", "gray");
         $state = 2;
      } elsif ($state == 2) {
	      CentralizedTL::Plant::SYSTEM->set_lights("red", "gray", "gray", "gray", "gray", "green");
         $state = 3;
      } elsif ($state == 3) {
	      CentralizedTL::Plant::SYSTEM->set_lights("red", "gray", "gray", "gray", "yellow", "gray");
         $state = 0;
      }
   }

);

CentralizedTL::Plant::SYSTEM->start();

main Gtk2;

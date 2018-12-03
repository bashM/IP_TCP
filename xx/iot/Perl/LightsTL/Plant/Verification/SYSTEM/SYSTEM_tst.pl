#!/usr/bin/perl
######################################################
# Peter Walsh
# SYSTEM test driver
######################################################

$|=1;

use strict;
use warnings;
use lib '../../../../';
use LightsTL::Plant::SYSTEM;
use AnyEvent;
use Gtk2 -init;
use constant FALSE => 0;
use constant TRUE => 1;
use Tosf::Widgit::Light;
use Tosf::Record::SVar;
use Tosf::Table::SVAR;
use Gnome2::Canvas;

my $state = 0;
# Note, the GUI callback is not wrapped in
# a try catch block so will not trap cew exceptions 
Tosf::Table::SVAR->add(name => "sv_car", value => 0);
my $d = AnyEvent->timer(
   after => 3,
   interval => 3,
   cb => sub {
      if ($state == 0) {
	      LightsTL::Plant::SYSTEM->set_lights("gray", "gray", "green", "red", "gray", "gray");
         $state = 1;
      } elsif ($state == 1) {
	      LightsTL::Plant::SYSTEM->set_lights("gray", "yellow", "gray", "red", "gray", "gray");
         $state = 2;
      } elsif ($state == 2) {
	      LightsTL::Plant::SYSTEM->set_lights("red", "gray", "gray", "gray", "gray", "green");
         $state = 3;
      } elsif ($state == 3) {
	      LightsTL::Plant::SYSTEM->set_lights("red", "gray", "gray", "gray", "yellow", "gray");
         $state = 0;
      }
   }

);

LightsTL::Plant::SYSTEM->start();

main Gtk2;

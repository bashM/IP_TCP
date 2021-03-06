#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Table/Verification/Route/ROUTE_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Try::Tiny;
use Tosf::Exception::Trap;
use Inet::Table::ROUTE;
use Inet::Record::Route;


do {
   try {

      #Inet::Table::ROUTE->set_route('192.168.6.1', '0.0.0.0', 'lo');
      #Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.6.100', 'eth0');
      #Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', 'eth0');


      #my $i;
      #my $g;
      #($i, $g) = Inet::Table::ROUTE->get_route('192.168.6.34');
      #print("Interface $i Gateway $g \n");

      print("Typical usage \n");
      Inet::Table::ROUTE->set_route('192.168.6.3', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', 'eth0');
      Inet::Table::ROUTE->set_route('0.0.0.0', '10.0.0.1', 'p2p0');

      my $i;
      my $g;

      ($i, $g) = Inet::Table::ROUTE->get_route('192.168.7.2');

      my $str = Inet::Table::ROUTE->dumps();
      print $str; 

   }

   catch {
      my $cew_e = $_;
      if (ref($cew_e) ~~ "Todf::Exception::Trap") {
         my $exc_name = $cew_e->get_name();
         print("FATAL ERROR: $exc_name \n");
      } else {
         die("ref($cew_e)");
      }
   }
}


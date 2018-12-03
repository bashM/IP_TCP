package inetApp::Plant::LAN;
#================================================================--
# File Name    : LAN.pm
#
# Purpose      : Plant set-up for LAN 
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
use constant MAXSEL => 3 ;
use constant IFACEPOLLFREQ => 0.1;

sub start {
   system('clear');

   my $inp;
   my $sel = -1;

   while (($sel < 0) || ($sel > MAXSEL))  {

      print ("\nLAN Boot Menu\n\n");
      print ("\tEarth 0\n");
      print ("\tWind 1\n");
      print ("\tFire 2\n");
      print ("\nEnter selection (CTRL C to exit) ");
      $inp = <>;
      chop($inp);
      if (($inp =~ m/\d/) && (length($inp) == 1)) {
         $sel = int($inp);
      }

   }

   if ($sel == 0) {

      # Earth 
      Inet::Collection::HOST->set_name("Earth");

      my $host = 'localhost';
      my $port = 5071;

      # no parameter checking is performed on this user data :(

      # ================ PORT =================

      Tosf::Table::TASK->new(
         name => "Eth0T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            iface => "eth0",
            handlerName => "ETHERNET",
            host => $host,
            port => $port
         )
      );
      Tosf::Table::TASK->reset("Eth0T");

      # note, ETHERNET, IP , ICMP and the other core FSMs are set up in Inet::Plant
   
      Inet::Table::ARP->set_mac('192.168.6.1', '601');
      Inet::Table::ARP->set_mac('192.168.6.2', '602');
      Inet::Table::ARP->set_mac('192.168.6.3', '603');

      Inet::Table::IFACE->set_ip("eth0", '192.168.6.1');
      Inet::Table::IFACE->set_mac("eth0", '601');

      Inet::Table::IFACE->set_type("eth0", 'ethernet');

      Inet::Table::ROUTE->set_route('192.168.6.1', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', "eth0");
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.6.0', "eth0");

   } elsif ($sel == 1) {

      # Wind 
      Inet::Collection::HOST->set_name("Wind");

      my $host = 'localhost';
      my $port = 5072;

      # no parameter checking is performed on this user data :(

      # ================ PORT =================

      Tosf::Table::TASK->new(
         name => "Eth0T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            iface => "eth0",
            handlerName => "ETHERNET",
            host => $host,
            port => $port
         )
      );
      Tosf::Table::TASK->reset("Eth0T");

      Inet::Table::ARP->set_mac('192.168.6.1', '601');
      Inet::Table::ARP->set_mac('192.168.6.2', '602');
      Inet::Table::ARP->set_mac('192.168.6.3', '603');

      Inet::Table::IFACE->set_ip("eth0", '192.168.6.2');
      Inet::Table::IFACE->set_mac("eth0", '602');

      Inet::Table::IFACE->set_type("eth0", 'ethernet');

      Inet::Table::ROUTE->set_route('192.168.6.2', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', "eth0");
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.6.0', "eth0");

   } elsif ($sel == 2) {
      
      # Fire
      Inet::Collection::HOST->set_name("Fire");

      my $host = 'localhost';
      my $port = 5073;

      # no parameter checking is performed on this user data :(

      # ================ PORT =================

      Tosf::Table::TASK->new(
         name => "Eth0T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            iface => "eth0",
            handlerName => "ETHERNET",
            host => $host,
            port => $port
         )
      );
      Tosf::Table::TASK->reset("Eth0T");

      Inet::Table::ARP->set_mac('192.168.6.1', '601');
      Inet::Table::ARP->set_mac('192.168.6.2', '602');
      Inet::Table::ARP->set_mac('192.168.6.3', '603');

      Inet::Table::NIC->set_ip("eth0", '192.168.6.3');
      Inet::Table::NIC->set_mac("eth0", '603');

      Inet::Table::IFACE->set_type("eth0", 'ethernet');

      Inet::Table::ROUTE->set_route('192.168.6.3', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', "eth0");
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.6.0', "eth0");

   }    

   # ================ STREAM =================
  
   Inet::Table::IFACE->set_type("str0", 'stream');
   Tosf::Table::TASK->new(
      name => "Str0T", 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
      deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
      run => TRUE,
      fsm => Inet::Fsm::StreamCon->new(
         iface => "str0",
         handlerName => "Stream",
      )
   );
   Tosf::Table::TASK->reset("Str0T");

   Tosf::Table::TASK->new(
      name => "Stream",
      periodic => FALSE,
      run => FALSE,
      fsm => inetApp::Fsm::STRAEMNODE->new()
   );
   Tosf::Table::TASK->reset("Stream");

   # ================ HEARTBEAT =================
  
   Tosf::Table::TASK->new(
      name => "HBeatT",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Inet::Fsm::HBEAT->new()
   );

   Tosf::Table::TASK->reset("HBeatT");

}

1;

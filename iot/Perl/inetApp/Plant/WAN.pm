package inetApp::Plant::WAN;
#================================================================--
# File Name    : WAN.pm
#
# Purpose      : Plant set-up for WAN 
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
use constant MAXSEL => 5 ;
use constant DEVPOLLFREQ => 0.1;

sub start {
   system('clear');

   my $inp;
   my $sel = -1;

   while (($sel < 0) || ($sel > MAXSEL))  {

      print ("\nWAN Boot Menu\n\n");
      print ("\tPeter 0\n");
      print ("\tPaul 1\n");
      print ("\tMary 2\n");
      print ("\tLarry 3\n");
      print ("\tCurly 4\n");
      print ("\tMoe 5\n");
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

      # Peter 
      Inet::Collection::HOST->set_name("Peter");

      my $host = 'localhost';
      my $port = 6000;

      # no parameter checking is performed on this user data :(

      # ================ PORT =================

      $devName = "dev0";
      $nicName = "eth0";
      $taskName = "task0";

      Tosf::Table::TASK->new(
         name => $taskName, 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskName => $taskName,
            devName => $devName,
            handlerName => "ETHERNET",
            host => $host,
            port => $port
         )
      );
      Tosf::Table::TASK->reset($taskName);

      # note, ETHERNET, IP , ICMP are set up in Inet::Plant
   
      Inet::Table::ARP->set_mac('192.168.6.0', '600');
      Inet::Table::ARP->set_mac('192.168.6.1', '601');
      Inet::Table::ARP->set_mac('192.168.6.2', '602');

      Inet::Table::NIC->set_ip($nicName, '192.168.6.0');
      Inet::Table::NIC->set_mac($nicName, '600');

      Inet::Table::NIC->set_devName($nicName, $devName);
      Inet::Table::DEV->set_nicName($devName, $nicName);

      Inet::Table::DEV->set_type($devName, 'ethernet');

      Inet::Table::ROUTE->set_route('192.168.6.0', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', $nicName);
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.6.2', $nicName);

   } elsif ($sel == 1) {

      # Paul 
      Inet::Collection::HOST->set_name("Paul");

      my $host = 'localhost';
      my $port = 6001;

      # no parameter checking is performed on this user data :(

      # ================ PORT =================

      $devName = "dev0";
      $nicName = "eth0";
      $taskName = "task0";

      Tosf::Table::TASK->new(
         name => $taskName, 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskName => $taskName,
            devName => $devName,
            handlerName => "ETHERNET",
            host => $host,
            port => $port
         )
      );
      Tosf::Table::TASK->reset($taskName);

      # note, ETHERNET, IP , ICMP are set up in Inet::Plant
   
      Inet::Table::ARP->set_mac('192.168.6.0', '600');
      Inet::Table::ARP->set_mac('192.168.6.1', '601');
      Inet::Table::ARP->set_mac('192.168.6.2', '602');

      Inet::Table::NIC->set_ip($nicName, '192.168.6.1');
      Inet::Table::NIC->set_mac($nicName, '601');

      Inet::Table::NIC->set_devName($nicName, $devName);
      Inet::Table::DEV->set_nicName($devName, $nicName);

      Inet::Table::DEV->set_type($devName, 'ethernet');

      Inet::Table::ROUTE->set_route('192.168.6.1', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', $nicName);
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.6.2', $nicName);

   } elsif ($sel == 2) {
      
      # Mary
      Inet::Collection::HOST->set_name("Mary");

      my $host = 'localhost';
      my $port = 6002;

      # no parameter checking is performed on this user data :(

      # ================ PORT =================

      $devName = "dev0";
      $nicName = "eth0";
      $taskName = "task0";

      Tosf::Table::TASK->new(
         name => $taskName, 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskName => $taskName,
            devName => $devName,
            handlerName => "ETHERNET",
            host => $host,
            port => $port
         )
      );

      Tosf::Table::TASK->reset($taskName);

      # note, ETHERNET, IP , ICMP are set up in Inet::Plant
   
      Inet::Table::ARP->set_mac('192.168.6.0', '600');
      Inet::Table::ARP->set_mac('192.168.6.1', '601');
      Inet::Table::ARP->set_mac('192.168.6.2', '602');

      Inet::Table::NIC->set_ip($nicName, '192.168.6.2');
      Inet::Table::NIC->set_mac($nicName, '602');

      Inet::Table::NIC->set_devName($nicName, $devName);
      Inet::Table::DEV->set_nicName($devName, $nicName);

      Inet::Table::DEV->set_type($devName, 'ethernet');

      Inet::Table::ROUTE->set_route('192.168.6.2', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', $nicName);

      $host = 'localhost';
      $port = 5000;

      $devName = "dev2";
      $nicName = "p2p0";
      $taskName = "task4";

      Tosf::Table::TASK->new(
         name => $taskName, 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskName => $taskName,
            devName => $devName,
            handlerName => "P2P",
            host => $host,
            port => $port
         )
      );

      Tosf::Table::TASK->reset($taskName);

      # note, ETHERNET, IP , ICMP are set up in Inet::Plant
   
      Inet::Table::NIC->set_ip($nicName, '10.0.6.100');
      Inet::Table::NIC->set_mac($nicName, '0');

      Inet::Table::NIC->set_devName($nicName, $devName);
      Inet::Table::DEV->set_nicName($devName, $nicName);

      Inet::Table::DEV->set_type($devName, 'p2p');

      Inet::Table::ROUTE->set_route('0.0.0.0', '10.0.6.200', $nicName);
      Inet::Table::ROUTE->set_route('10.0.0.100', '0.0.0.0', 'lo');

   } elsif ($sel == 3) {

      # Larry 
      Inet::Collection::HOST->set_name("Larry");

      my $host = 'localhost';
      my $port = 7000;

      # no parameter checking is performed on this user data :(

      # ================ PORT =================

      $devName = "dev0";
      $nicName = "eth0";
      $taskName = "task0";

      Tosf::Table::TASK->new(
         name => $taskName, 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskName => $taskName,
            devName => $devName,
            handlerName => "ETHERNET",
            host => $host,
            port => $port
         )
      );
      Tosf::Table::TASK->reset($taskName);

      # note, ETHERNET, IP , ICMP are set up in Inet::Plant
   
      Inet::Table::ARP->set_mac('192.168.7.0', '700');
      Inet::Table::ARP->set_mac('192.168.7.1', '701');
      Inet::Table::ARP->set_mac('192.168.7.2', '702');

      Inet::Table::NIC->set_ip($nicName, '192.168.7.0');
      Inet::Table::NIC->set_mac($nicName, '700');

      Inet::Table::NIC->set_devName($nicName, $devName);
      Inet::Table::DEV->set_nicName($devName, $nicName);

      Inet::Table::DEV->set_type($devName, 'ethernet');

      Inet::Table::ROUTE->set_route('192.168.7.0', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.7', '0.0.0.0', $nicName);
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.7.2', $nicName);

   } elsif ($sel == 4) {

      # Curly 
      Inet::Collection::HOST->set_name("Curly");

      my $host = 'localhost';
      my $port = 7001;

      # no parameter checking is performed on this user data :(

      # ================ PORT =================

      $devName = "dev0";
      $nicName = "eth0";
      $taskName = "task0";

      Tosf::Table::TASK->new(
         name => $taskName, 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskName => $taskName,
            devName => $devName,
            handlerName => "ETHERNET",
            host => $host,
            port => $port
         )
      );
      Tosf::Table::TASK->reset($taskName);

      # note, ETHERNET, IP , ICMP are set up in Inet::Plant
   
      Inet::Table::ARP->set_mac('192.168.7.0', '700');
      Inet::Table::ARP->set_mac('192.168.7.1', '701');
      Inet::Table::ARP->set_mac('192.168.7.2', '702');

      Inet::Table::NIC->set_ip($nicName, '192.168.7.1');
      Inet::Table::NIC->set_mac($nicName, '701');

      Inet::Table::NIC->set_devName($nicName, $devName);
      Inet::Table::DEV->set_nicName($devName, $nicName);

      Inet::Table::DEV->set_type($devName, 'ethernet');

      Inet::Table::ROUTE->set_route('192.168.7.1', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.7', '0.0.0.0', $nicName);
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.7.2', $nicName);

   } elsif ($sel == 5) {
      
      # Moe
      Inet::Collection::HOST->set_name("Moe");

      my $host = 'localhost';
      my $port = 7002;

      # no parameter checking is performed on this user data :(

      # ================ PORT =================

      $devName = "dev0";
      $nicName = "eth0";
      $taskName = "task0";

      Tosf::Table::TASK->new(
         name => $taskName, 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskName => $taskName,
            devName => $devName,
            handlerName => "ETHERNET",
            host => $host,
            port => $port
         )
      );
      Tosf::Table::TASK->reset($taskName);

      # note, ETHERNET, IP , ICMP are set up in Inet::Plant
   
      Inet::Table::ARP->set_mac('192.168.7.0', '700');
      Inet::Table::ARP->set_mac('192.168.7.1', '701');
      Inet::Table::ARP->set_mac('192.168.7.2', '702');

      Inet::Table::NIC->set_ip($nicName, '192.168.7.2');
      Inet::Table::NIC->set_mac($nicName, '702');

      Inet::Table::NIC->set_devName($nicName, $devName);
      Inet::Table::DEV->set_nicName($devName, $nicName);

      Inet::Table::DEV->set_type($devName, 'ethernet');

      Inet::Table::ROUTE->set_route('192.168.7.2', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.7', '0.0.0.0', $nicName);

      $host = 'localhost';
      $port = 5001;

      $devName = "dev2";
      $nicName = "p2p0";
      $taskName = "task4";

      Tosf::Table::TASK->new(
         name => $taskName, 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskName => $taskName,
            devName => $devName,
            handlerName => "P2P",
            host => $host,
            port => $port
         )
      );

      Tosf::Table::TASK->reset($taskName);

      # note, ETHERNET, IP , ICMP are set up in Inet::Plant
   
      Inet::Table::NIC->set_ip($nicName, '10.0.6.200');
      Inet::Table::NIC->set_mac($nicName, '0');

      Inet::Table::NIC->set_devName($nicName, $devName);
      Inet::Table::DEV->set_nicName($devName, $nicName);

      Inet::Table::DEV->set_type($devName, 'p2p');

      Inet::Table::ROUTE->set_route('0.0.0.0', '10.0.6.100', $nicName);
      Inet::Table::ROUTE->set_route('10.0.0.200', '0.0.0.0', 'lo');

   }


# ================ STREAM =================
  
   $devName = "dev1";
   $taskName = "task1";
   Inet::Table::DEV->set_type($devName, 'stream');
   Tosf::Table::TASK->new(
      name => $taskName, 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
      deadline => Tosf::Executive::TIMER->s2t(DEVPOLLFREQ),
      run => TRUE,
      fsm => Inet::Fsm::StreamCon->new(
         taskName => $taskName,
         devName => $devName,
         handlerName => "Stream",
      )
   );
   Tosf::Table::TASK->reset($taskName);

   $taskName = "Stream";
   Tosf::Table::TASK->new(
      name => $taskName,
      periodic => FALSE,
      run => FALSE,
      fsm => inetApp::Fsm::StreamHost->new(
         taskName => $taskName,
      )
   );
   Tosf::Table::TASK->reset($taskName);

   # ================ HEARTBEAT =================
  
   $taskName = "HBeat";
   Tosf::Table::TASK->new(
      name => $taskName,
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Inet::Fsm::HBeat->new(
         taskName => $taskName,
      )
   );
   Tosf::Table::TASK->reset($taskName);

}

1;

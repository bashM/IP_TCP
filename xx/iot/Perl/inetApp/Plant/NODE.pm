package inetApp::Plant::NODE;
#================================================================--
# File Name    : NODE.pm
#
# Purpose      : Plant set-up for NODE 
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

      print ("\nNODE Boot Menu\n\n");
      print ("\tSniffer 0\n");
      print ("\tHub 1\n");
      print ("\tPointToPoint 2\n");
      print ("\tSwitch 3\n");
      print ("\nEnter selection (CTRL C to exit) ");
      $inp = <>;
      chop($inp);
      if (($inp =~ m/\d/) && (length($inp) == 1)) {
         $sel = int($inp);
      }

   }

   my $host;
   my $port;
   my $port0;
   my $host4 = "none";
   my $port4 = "none";

   if ($sel == 0) {

      # no parameter checking is performed on this user data :(

      print("*************************************************\n");
      print("*****            Sniffer Setup              *****\n");
      print("*************************************************\n \n");

      print("Enter Internet host name ");
      chomp($host = <>);
      print("Enter Internet port number: ");
      chomp($port = <>);

      Inet::Collection::NODE->set_ihost($host);
      Inet::Collection::NODE->set_iport($port);

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");


      # ================ PORT =================

      Inet::Table::IFACE->set_type("eth0", 'ethernet');
      Tosf::Table::TASK->new(
         name => "Eth0T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            iface =>  "eth0",
            handlerName => "NodeT",
            host => $host,
            port => $port
         )
      );
      Tosf::Table::TASK->reset("Eth0T");

      Tosf::Table::TASK->new(
         name => "NodeT",
         periodic => FALSE,
         run => FALSE,
         fsm => Inet::Fsm::NODE->new()
      );
      Tosf::Table::TASK->reset("NodeT");

   } elsif ($sel == 1) {

      # no parameter checking is performed on this user data :(

      print("*************************************************\n");
      print("*****              Hub Setup                *****\n");
      print("*************************************************\n \n");
      print("Four consecutive Tcp Internet port numbers are required \n");
      print("on localhost for Hub ports p0 through p3 \n");
      print("Enter Internet port number for Hub p0: ");
      chomp($port0 = <>);
      print("Mapping \n");
      print("\t Hub port p0 to Internet port number ", $port0, "\n");
      print("\t Hub port p1 to Internet port number ", $port0 + 1, "\n");
      print("\t Hub port p2 to Internet port number ", $port0 + 2, "\n");
      print("\t Hub port p3 to Internet port number ", $port0 + 3, "\n \n");

      print("One Tcp Internet port number is required on a connected \n");
      print("host for Hub up-link port p4 \n");
      print("Enter Internet host name for Hub p4 (enter none to disable p4): ");
      chomp($host4 = <>);
      if ($host4 ne "none") {
         print("Enter Internet port number for Hub p4: ");
         chomp($port4 = <>);
         print("Mapping \n");
         print("\t Hub up-link port p4 to Internet port number ", $host4, ":", $port4, "\n \n");
      } else {
         print("Mapping \n");
         print("\t No up-link defined \n \n");
      }

      Inet::Collection::NODE->set_ihost($host4);
      Inet::Collection::NODE->set_iport($port4);

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");


      # ================ PORTS =================

      Inet::Table::IFACE->set_type("eth0", 'ethernet');
      Tosf::Table::TASK->new(
         name => "Eth0T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "eth0",
            handlerName => "NodeT",
            port => $port0
         )
      );
      Tosf::Table::TASK->reset("Eth0T");

      Inet::Table::IFACE->set_type("eth1", 'ethernet');

      Tosf::Table::TASK->new(
         name => "Eth1T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "eth1",
            handlerName => "NodeT",
            port => ($port0 + 1)
         )
      );
      Tosf::Table::TASK->reset("Eth1T");

      Inet::Table::IFACE->set_type("eth2", 'ethernet');
      Tosf::Table::TASK->new(
         name => "Eth2T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "eth2",
            handlerName => "NodeT",
            port => ($port0 + 2)
         )
      );
      Tosf::Table::TASK->reset("Eth2T");

      Inet::Table::IFACE->set_type("eth3", 'ethernet');
      Tosf::Table::TASK->new(
         name => "Eth3T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "eth3",
            handlerName => "NodeT",
            port => ($port0 + 3)
         )
      );

      Tosf::Table::TASK->reset("Eth3T");

      if ($host4 ne 'none') {

         #(Up link)
         Inet::Table::IFACE->set_type("eth4", 'ethernet');
         Tosf::Table::TASK->new(
            name => "Eth4T", 
            periodic => TRUE, 
            period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
            deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
            run => TRUE,
            fsm => Inet::Fsm::SocConC->new(
               iface => "eth4",
               handlerName => "NodeT",
               host => $host4,
               port => $port4
            )
         );
         Tosf::Table::TASK->reset("Eth4T");
      }

      Tosf::Table::TASK->new(
         name => "NodeT",
         periodic => FALSE,
         run => FALSE,
         fsm => Inet::Fsm::NODE->new()
      );

      Tosf::Table::TASK->reset("NodeT");

   } elsif ($sel == 2) {

      print("*************************************************\n");
      print("*****      Point2Point (P2p) Setup          *****\n");
      print("*************************************************\n \n");
      print("Two consecutive Tcp Internet port numbers are required \n");
      print("on localhost for P2p ports p0 and p1 \n");
      print("Enter Internet port number for P2p p0: ");
      chomp($port = <>);
      print("Mapping \n");
      print("\t P2p port p0 to Internet port number ", $port, "\n");
      print("\t P2p port p1 to Internet port number ", $port + 1, "\n \n");

      Inet::Collection::NODE->set_ihost("localhost");
      Inet::Collection::NODE->set_iport($port);

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");


      # ================ PORTS =================
      
      Inet::Table::IFACE->set_type("p2p0", 'p2p');
      Tosf::Table::TASK->new(
         name => "P2p0T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "p2p0",
            handlerName => "NodeT",
            port => $port
         )
      );
      Tosf::Table::TASK->reset("P2p0T");

      Inet::Table::IFACE->set_type("p2p1", 'p2p');
      Tosf::Table::TASK->new(
         name => "P2p1T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "p2p1",
            handlerName => "NodeT",
            port => ($port + 1)
         )
      );

      Tosf::Table::TASK->reset("P2p1T");

      Tosf::Table::TASK->new(
         name => "NodeT",
         periodic => FALSE,
         run => FALSE,
         fsm => Inet::Fsm::NODE->new()
      );

      Tosf::Table::TASK->reset("NodeT");


   } elsif ($sel == 3) {
         #print("Future Work\n");
          print("*************************************************\n");
      print("*****              Switch Setup                *****\n");
      print("*************************************************\n \n");
      print("Four consecutive Tcp Internet port numbers are required \n");
      print("on localhost for Switch ports p0 through p3 \n");
      print("Enter Internet port number for Switch p0: ");
      chomp($port0 = <>);
      print("Mapping \n");
      print("\t Hub port p0 to Internet port number ", $port0, "\n");
      print("\t Hub port p1 to Internet port number ", $port0 + 1, "\n");
      print("\t Hub port p2 to Internet port number ", $port0 + 2, "\n");
      print("\t Hub port p3 to Internet port number ", $port0 + 3, "\n \n");

      print("One Tcp Internet port number is required on a connected \n");
      print("host for Switch up-link port p4 \n");
      print("Enter Internet host name for Hub p4 (enter none to disable p4): ");
      chomp($host4 = <>);
      if ($host4 ne "none") {
         print("Enter Internet port number for Switch p4: ");
         chomp($port4 = <>);
         print("Mapping \n");
         print("\t Switch up-link port p4 to Internet port number ", $host4, ":", $port4, "\n \n");
      } else {
         print("Mapping \n");
         print("\t No up-link defined \n \n");
      }

      Inet::Collection::NODE->set_ihost($host4);
      Inet::Collection::NODE->set_iport($port4);

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");

    # ================ MAC Ticker =================
  
      Tosf::Table::TASK->new(
        name => "MACT",
        periodic => TRUE,
        period => Tosf::Executive::TIMER->s2t(1),
        deadline => Tosf::Executive::TIMER->s2t(0.5),
        run => TRUE,
        fsm => Inet::Fsm::MACT->new()
      );

      Tosf::Table::TASK->reset("MACT");

     
      # ================ PORTS =================

      Inet::Table::IFACE->set_type("eth0", 'ethernet');
      Tosf::Table::TASK->new(
         name => "Eth0T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "eth0",
            handlerName => "NodeT",
            port => $port0
         )
      );
      Tosf::Table::TASK->reset("Eth0T");

      Inet::Table::IFACE->set_type("eth1", 'ethernet');

      Tosf::Table::TASK->new(
         name => "Eth1T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "eth1",
            handlerName => "NodeT",
            port => ($port0 + 1)
         )
      );
      Tosf::Table::TASK->reset("Eth1T");

      Inet::Table::IFACE->set_type("eth2", 'ethernet');
      Tosf::Table::TASK->new(
         name => "Eth2T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "eth2",
            handlerName => "NodeT",
            port => ($port0 + 2)
         )
      );
      Tosf::Table::TASK->reset("Eth2T");

      Inet::Table::IFACE->set_type("eth3", 'ethernet');
      Tosf::Table::TASK->new(
         name => "Eth3T", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConS->new(
            iface => "eth3",
            handlerName => "NodeT",
            port => ($port0 + 3)
         )
      );

      Tosf::Table::TASK->reset("Eth3T");

      if ($host4 ne 'none') {

         #(Up link)
         Inet::Table::IFACE->set_type("eth4", 'ethernet');
         Tosf::Table::TASK->new(
            name => "Eth4T", 
            periodic => TRUE, 
            period => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
            deadline => Tosf::Executive::TIMER->s2t(IFACEPOLLFREQ),
            run => TRUE,
            fsm => Inet::Fsm::SocConC->new(
               iface => "eth4",
               handlerName => "NodeT",
               host => $host4,
               port => $port4
            )
         );
         Tosf::Table::TASK->reset("Eth4T");
      }

      Tosf::Table::TASK->new(
         name => "NodeT",
         periodic => FALSE,
         run => FALSE,
         fsm => Inet::Fsm::Net->new(taskName => "NodeT")
      );

      Tosf::Table::TASK->reset("NodeT");
         
      #exit();
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

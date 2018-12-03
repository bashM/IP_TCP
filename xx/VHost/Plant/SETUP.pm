package VHost::Plant::SETUP;
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
use constant DCBPOLLFREQ => 0.1;

sub start {

   open(VFH, "< ../Documentation/Version") || die "Cant open Version File \n";
   VHost::Collection::HOST->set_version(<VFH>);
   print("\n", VHost::Collection::HOST->get_version(), "\n");

   my $sel = -1;
   while (!($sel =~ m/^[0-5]/) || (length($sel) != 1))  {

      print ("\n\tBoot Menu\n\n");
      print (">>> Boot (Router) Mary <<< 0 \n");
      print (">>> Boot (Host) Peter  <<< 1\n");
      print (">>> Boot (Host) Paul   <<< 2\n");
      print (" \n");
      print ("==========================\n");
      print (" \n");
      print (">>> Boot (Router) Moe  <<< 3\n");
      print (">>> Boot (Host) Larry  <<< 4\n");
      print (">>> Boot (Host) Curly  <<< 5\n");

      print ("\nEnter Selection ");
      $sel = <>;
      chop($sel);
   }
   
   if ($sel == 0) {

      # little checking performed :(

         # little checking performed :(

     my $pHost = "localhost";
     my $pPort = 7001;
     my $p2p0pHost = "localhost";  
     my $p2p0Port = 4000;
     my $p2p1pHost= "localhost";
     my $p2p1Port = 4003;
       
     
          
       
       # no parameter checking is performed on this user data :(

      print("*************************************************\n");
      print("*****              VHost Setup               *****\n");
      print("*************************************************\n \n");

      print("Connecting to $pHost / $pPort / $p2p0pHost /$p2p0Port / $p2p1pHost / $p2p1Port  \n");

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");
      
      
      VHost::Collection::HOST->set_host("Router Mary");
      
      print(VHost::Collection::HOST->get_host(), "\n");
      print ("\n");
      VHost::Collection::HOST->set_port($pPort);

      #                Type                 Ip            Mac  Open
      Inet::Table::NIC->set('eth0', 'ethernet', '192.168.6.2', '602', '1');
      Inet::Table::NIC->set('p2p0', 'p2p', '10.0.6.100', '0','1');
      Inet::Table::NIC->set('p2p1', 'p2p', '10.0.7.200', '0','1');
      #Inet::Table::ARP->set_mac('192.168.6.1', '601');
      Inet::Table::ROUTE->set_route('192.168.6.2', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('10.0.6.100', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('10.0.8.200', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', 'eth0');
      Inet::Table::ROUTE->set_route('0.0.0.0', '10.0.6.200', 'p2p0');
      print (Inet::Table::ROUTE->dumps);  
      print ("\n");
      
       # ================ PORT =================

       Tosf::Table::SVAR->add(name => "pToSv", value => 0);
      Tosf::Table::SEMAPHORE->add(name => "pSem", value => 0, max => 1);
      Tosf::Table::SEMAPHORE->add(name => "p2p0Sem", value => 0, max => 1);
      Tosf::Table::SEMAPHORE->add(name => "p2p1Sem", value => 0, max => 1);
     
      

      Tosf::Table::TASK->new(
         name => "pCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "pCon",
            dcbID => "p",
            semID => "pSem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $pHost,
            port => $pPort
         )
      );
      
      Tosf::Table::TASK->new(
         name => "p2p0Con", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "p2p0Con",
            dcbID => "p2p0",
            semID => "p2p0Sem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $p2p0pHost,
            port => $p2p0Port
         )
      );
      
      Tosf::Table::TASK->new(
         name => "p2p1Con", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "p2p1Con",
            dcbID => "p2p1",
            semID => "p2p1Sem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $p2p1pHost,
            port => $p2p1Port
         )
      );
     
     Tosf::Table::TASK->new(
         name => "pNic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "pNic",
            dcbID => "p",
            semID => "pSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "p2p0Nic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "p2p0Nic",
            dcbID => "p2p0",
            semID => "p2p0Sem"
         )
      );
      Tosf::Table::TASK->new(
         name => "p2p1Nic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "p2p1Nic",
            dcbID => "p2p1",
            semID => "p2p1Sem"
         )
      );

      Tosf::Table::TASK->new(
         name => "pHBeat",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(20),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
         run => TRUE,
         fsm => VHost::Fsm::HBeat->new(
            taskID => "pHBeat",
            dcbID => "p"
         )
      );

      Tosf::Table::TASK->new(
         name => "pTOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(160),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "pTOut",
            sv => "pToSv"
         )
      );
      
      
      Tosf::Table::TASK->new(
         name => "p2p0TOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(160),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "p2p0TOut",
            sv => "pToSv"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "p2p1TOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(160),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "p2p1TOut",
            sv => "pToSv"
         )
      );

      Tosf::Table::TASK->reset("pNic");
      Tosf::Table::TASK->reset("pCon");
      Tosf::Table::TASK->reset("pHBeat");
      Tosf::Table::TASK->reset("pTOut");
      
      Tosf::Table::TASK->reset("p2p0TOut");
      Tosf::Table::TASK->reset("p2p1TOut");
      
       Tosf::Table::TASK->reset("p2p0Nic");
       Tosf::Table::TASK->reset("p2p1Nic");
      
       Tosf::Table::TASK->reset("p2p0Con");
       Tosf::Table::TASK->reset("p2p1Con");

      # ================ STREAM =================

      Tosf::Table::SEMAPHORE->add(name => "sSem", value => 0, max => 1);

      Tosf::Table::TASK->new(
         name => "sCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::StreamCon->new(
            taskID => "sCon",
            dcbID => "stdio",
            semID => "sSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "sSic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Sic->new(
            taskID => "sSic",
            dcbID => "stdio",
            semID => "sSem"
         )
      );
      
      Tosf::Table::TASK->reset("sSic");
      Tosf::Table::TASK->reset("sCon");
      # ==================== Handalers ======================
      Tosf::Table::SEMAPHORE->add(name => "pingSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "icmpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "ipSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "PingdSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hEthSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hArpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hP2pSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hUdpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncdSem", value => 0, max => 1);
       
     
     Tosf::Table::TASK->new(
         name => "hPing",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PING->new(
            taskID => "hPing",
            dcbID => "stdio",
            semID => "pingSem"
         )
      );
      
       Tosf::Table::TASK->new(
         name => "hIncd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INCD->new(
            taskID => "hIncd",
            dcbID => "stdio",
            semID => "IncdSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hInc",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INC->new(
            taskID => "hInc",
            dcbID => "stdio",
            semID => "IncSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIcmp",
         periodic => FALSE,
         run => FALSE,
        fsm => VHost::Fsm::ICMP->new(
            taskID => "hIcmp",
            dcbID => "stdio",
            semID => "icmpSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::IP->new(
            taskID => "hIp",
            dcbID => "stdio",
            semID => "ipSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hPingd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PINGD->new(
            taskID => "hPingd",
            dcbID => "stdio",
            semID => "PingdSem"
        )
      );
      
      Tosf::Table::TASK->new(
         name => "hEth",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ETHERNET->new(
            taskID => "hEth",
            dcbID => "stdio",
            semID => "hEthSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hArp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ARP->new(
            taskID => "hArp",
            dcbID => "stdio",
            semID => "hArpSem"
         )
      );
      Tosf::Table::TASK->new(
         name => "hUdp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::UDP->new(
            taskID => "hUdp",
            dcbID => "stdio",
            semID => "hUdpSem"
         )
      );
       Tosf::Table::TASK->new(
         name => "hP2P",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::P2P->new(
            taskID => "hP2P",
            dcbID => "stdio",
            semID => "hP2pSem"
         )
      );

       Tosf::Table::TASK->reset("hPing");
       Tosf::Table::TASK->reset("hIcmp");
       Tosf::Table::TASK->reset("hIp");
       Tosf::Table::TASK->reset("hPingd");
       Tosf::Table::TASK->reset("hEth");
       Tosf::Table::TASK->reset("hArp");
       Tosf::Table::TASK->reset("hP2P");
       Tosf::Table::TASK->reset("hUdp");
       Tosf::Table::TASK->reset("hInc");
       Tosf::Table::TASK->reset("hIncd");


   } elsif ($sel == 1) {
   
   # little checking performed :(

       my $pHost = "localhost";
      my $pPort = 7003;

      # no parameter checking is performed on this user data :(

      print("*************************************************\n");
      print("*****              VHost Setup               *****\n");
      print("*************************************************\n \n");

      print("Connecting to $pHost / $pPort \n");

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");
      

      # little checking performed :(

       VHost::Collection::HOST->set_host("host Peter");
      print(VHost::Collection::HOST->get_host(), "\n");
      print "\n";
      VHost::Collection::HOST->set_port($pPort); 
      #                           Type        Ip             Mac
      Inet::Table::NIC->set('eth0', 'ethernet', '192.168.6.1', '601', '1');
      #Inet::Table::ARP->set_mac('192.168.6.2', '602');
      Inet::Table::ROUTE->set_route('192.168.6.1', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', 'eth0');
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.6.2', 'eth0');
      print (Inet::Table::ROUTE->dumps);

      # ================ PORT =================
      
      Tosf::Table::SVAR->add(name => "pToSv", value => 0);
      Tosf::Table::SEMAPHORE->add(name => "pSem", value => 0, max => 1);
      

      Tosf::Table::TASK->new(
         name => "pCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "pCon",
            dcbID => "p",
            semID => "pSem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $pHost,
            port => $pPort
         )
      );
      
      
      

      Tosf::Table::TASK->new(
         name => "pNic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "pNic",
            dcbID => "p",
            semID => "pSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "pHBeat",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(20),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
         run => TRUE,
         fsm => VHost::Fsm::HBeat->new(
            taskID => "pHBeat",
            dcbID => "p"
         )
      );

      Tosf::Table::TASK->new(
         name => "pTOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(60),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "pTOut",
            sv => "pToSv"
         )
      );

      Tosf::Table::TASK->reset("pNic");
      Tosf::Table::TASK->reset("pCon");
      Tosf::Table::TASK->reset("pHBeat");
      Tosf::Table::TASK->reset("pTOut");

      # ================ STREAM =================

      Tosf::Table::SEMAPHORE->add(name => "sSem", value => 0, max => 1);

      Tosf::Table::TASK->new(
         name => "sCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::StreamCon->new(
            taskID => "sCon",
            dcbID => "stdio",
            semID => "sSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "sSic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Sic->new(
            taskID => "sSic",
            dcbID => "stdio",
            semID => "sSem"
         )
      );
      
      Tosf::Table::TASK->reset("sSic");
      Tosf::Table::TASK->reset("sCon");
      # ==================== Handalers ======================
        Tosf::Table::SEMAPHORE->add(name => "pingSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "icmpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "ipSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "PingdSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hEthSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hArpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hP2pSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hUdpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncdSem", value => 0, max => 1);
       
     
     Tosf::Table::TASK->new(
         name => "hPing",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PING->new(
            taskID => "hPing",
            dcbID => "stdio",
            semID => "pingSem"
         )
      );
      
       Tosf::Table::TASK->new(
         name => "hIncd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INCD->new(
            taskID => "hIncd",
            dcbID => "stdio",
            semID => "IncdSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hInc",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INC->new(
            taskID => "hInc",
            dcbID => "stdio",
            semID => "IncSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIcmp",
         periodic => FALSE,
         run => FALSE,
        fsm => VHost::Fsm::ICMP->new(
            taskID => "hIcmp",
            dcbID => "stdio",
            semID => "icmpSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::IP->new(
            taskID => "hIp",
            dcbID => "stdio",
            semID => "ipSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hPingd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PINGD->new(
            taskID => "hPingd",
            dcbID => "stdio",
            semID => "PingdSem"
        )
      );
      
      Tosf::Table::TASK->new(
         name => "hEth",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ETHERNET->new(
            taskID => "hEth",
            dcbID => "stdio",
            semID => "hEthSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hArp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ARP->new(
            taskID => "hArp",
            dcbID => "stdio",
            semID => "hArpSem"
         )
      );
      Tosf::Table::TASK->new(
         name => "hUdp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::UDP->new(
            taskID => "hUdp",
            dcbID => "stdio",
            semID => "hUdpSem"
         )
      );
       Tosf::Table::TASK->new(
         name => "hP2P",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::P2P->new(
            taskID => "hP2P",
            dcbID => "stdio",
            semID => "hP2pSem"
         )
      );

       Tosf::Table::TASK->reset("hPing");
       Tosf::Table::TASK->reset("hIcmp");
       Tosf::Table::TASK->reset("hIp");
       Tosf::Table::TASK->reset("hPingd");
       Tosf::Table::TASK->reset("hEth");
       Tosf::Table::TASK->reset("hArp");
       Tosf::Table::TASK->reset("hP2P");
       Tosf::Table::TASK->reset("hUdp");
       Tosf::Table::TASK->reset("hInc");
       Tosf::Table::TASK->reset("hIncd");
       
      #main::leaveScript();
   } elsif ($sel == 2) {
   
    my $pHost = "localhost";
      my $pPort = 7004;

      # no parameter checking is performed on this user data :(

      print("*************************************************\n");
      print("*****              VHost Setup               *****\n");
      print("*************************************************\n \n");

      print("Connecting to $pHost / $pPort \n");

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");
      

      # little checking performed :(

       VHost::Collection::HOST->set_host("Host Paul");
      print(VHost::Collection::HOST->get_host(), "\n");
      print "\n";
      VHost::Collection::HOST->set_port($pPort); 
       #                           Type        Ip             Mac
      Inet::Table::NIC->set('eth0', 'ethernet', '192.168.6.0', '600', '1');
      Inet::Table::ARP->set_mac('192.168.6.2', '602');
      Inet::Table::ROUTE->set_route('192.168.6.0', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', 'eth0');
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.6.2', 'eth0');
      print (Inet::Table::ROUTE->dumps);

      # ================ PORT =================
      
      Tosf::Table::SVAR->add(name => "pToSv", value => 0);
      Tosf::Table::SEMAPHORE->add(name => "pSem", value => 0, max => 1);
      

      Tosf::Table::TASK->new(
         name => "pCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "pCon",
            dcbID => "p",
            semID => "pSem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $pHost,
            port => $pPort
         )
      );
      
      
      

      Tosf::Table::TASK->new(
         name => "pNic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "pNic",
            dcbID => "p",
            semID => "pSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "pHBeat",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(20),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
         run => TRUE,
         fsm => VHost::Fsm::HBeat->new(
            taskID => "pHBeat",
            dcbID => "p"
         )
      );

      Tosf::Table::TASK->new(
         name => "pTOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(60),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "pTOut",
            sv => "pToSv"
         )
      );

      Tosf::Table::TASK->reset("pNic");
      Tosf::Table::TASK->reset("pCon");
      Tosf::Table::TASK->reset("pHBeat");
      Tosf::Table::TASK->reset("pTOut");

      # ================ STREAM =================

      Tosf::Table::SEMAPHORE->add(name => "sSem", value => 0, max => 1);

      Tosf::Table::TASK->new(
         name => "sCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::StreamCon->new(
            taskID => "sCon",
            dcbID => "stdio",
            semID => "sSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "sSic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Sic->new(
            taskID => "sSic",
            dcbID => "stdio",
            semID => "sSem"
         )
      );
      
      Tosf::Table::TASK->reset("sSic");
      Tosf::Table::TASK->reset("sCon");
      # ==================== Handalers ======================
       Tosf::Table::SEMAPHORE->add(name => "pingSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "icmpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "ipSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "PingdSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hEthSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hArpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hP2pSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hUdpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncdSem", value => 0, max => 1);
       
     
     Tosf::Table::TASK->new(
         name => "hPing",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PING->new(
            taskID => "hPing",
            dcbID => "stdio",
            semID => "pingSem"
         )
      );
      
       Tosf::Table::TASK->new(
         name => "hIncd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INCD->new(
            taskID => "hIncd",
            dcbID => "stdio",
            semID => "IncdSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hInc",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INC->new(
            taskID => "hInc",
            dcbID => "stdio",
            semID => "IncSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIcmp",
         periodic => FALSE,
         run => FALSE,
        fsm => VHost::Fsm::ICMP->new(
            taskID => "hIcmp",
            dcbID => "stdio",
            semID => "icmpSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::IP->new(
            taskID => "hIp",
            dcbID => "stdio",
            semID => "ipSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hPingd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PINGD->new(
            taskID => "hPingd",
            dcbID => "stdio",
            semID => "PingdSem"
        )
      );
      
      Tosf::Table::TASK->new(
         name => "hEth",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ETHERNET->new(
            taskID => "hEth",
            dcbID => "stdio",
            semID => "hEthSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hArp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ARP->new(
            taskID => "hArp",
            dcbID => "stdio",
            semID => "hArpSem"
         )
      );
      Tosf::Table::TASK->new(
         name => "hUdp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::UDP->new(
            taskID => "hUdp",
            dcbID => "stdio",
            semID => "hUdpSem"
         )
      );
       Tosf::Table::TASK->new(
         name => "hP2P",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::P2P->new(
            taskID => "hP2P",
            dcbID => "stdio",
            semID => "hP2pSem"
         )
      );

       Tosf::Table::TASK->reset("hPing");
       Tosf::Table::TASK->reset("hIcmp");
       Tosf::Table::TASK->reset("hIp");
       Tosf::Table::TASK->reset("hPingd");
       Tosf::Table::TASK->reset("hEth");
       Tosf::Table::TASK->reset("hArp");
       Tosf::Table::TASK->reset("hP2P");
       Tosf::Table::TASK->reset("hUdp");
       Tosf::Table::TASK->reset("hInc");
       Tosf::Table::TASK->reset("hIncd");
   
     # print("Coming Soon\n");
      #main::leaveScript();
   }elsif ($sel == 3) {
   
   
      my $pHost = "localhost";
      my $pPort = 8000;
      my $p2p0pHost = "localhost";  
      my $p2p0Port = 4001;
      my $p2p1pHost="localhost";
      my $p2p1Port = 4002;

      # no parameter checking is performed on this user data :(

      print("*************************************************\n");
      print("*****              VHost Setup               *****\n");
      print("*************************************************\n \n");

      print("Connecting to $pHost / $pPort / $p2p0pHost /$p2p0Port / $p2p1pHost / $p2p1Port  \n");

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");
      

      # little checking performed :(
      VHost::Collection::HOST->set_host("Router Moe");
      print(VHost::Collection::HOST->get_host(), "\n");
       print "\n";
      VHost::Collection::HOST->set_port($pPort);
     # VHost::Collection::HOST->set_port($p2p0Port);
     # VHost::Collection::HOST->set_port($p2p1Port);
      
       #                           Type        Ip             Mac
      Inet::Table::NIC->set('eth0', 'ethernet', '192.168.7.2', '702', '1');
      Inet::Table::NIC->set('p2p0', 'p2p', '10.0.7.100', '0', '1');
      Inet::Table::NIC->set('p2p1', 'p2p', '10.6.200', '0','1');
      Inet::Table::ARP->set_mac('192.168.7.1', '701');
      Inet::Table::ROUTE->set_route('192.168.7.2', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('10.0.7.100', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('10.0.6.200', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.7', '0.0.0.0', 'eth0');
      Inet::Table::ROUTE->set_route('0.0.0.0', '10.0.7.200', 'p2p0');
      print (Inet::Table::ROUTE->dumps);
   
      # ================ PORT =================
      
       Tosf::Table::SVAR->add(name => "pToSv", value => 0);
      Tosf::Table::SEMAPHORE->add(name => "pSem", value => 0, max => 1);
      Tosf::Table::SEMAPHORE->add(name => "p2p0Sem", value => 0, max => 1);
      Tosf::Table::SEMAPHORE->add(name => "p2p1Sem", value => 0, max => 1);
     
      

      Tosf::Table::TASK->new(
         name => "pCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "pCon",
            dcbID => "p",
            semID => "pSem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $pHost,
            port => $pPort
         )
      );
      
      Tosf::Table::TASK->new(
         name => "p2p0Con", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "p2p0Con",
            dcbID => "p2p0",
            semID => "p2p0Sem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $p2p0pHost,
            port => $p2p0Port
         )
      );
      
      Tosf::Table::TASK->new(
         name => "p2p1Con", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "p2p1Con",
            dcbID => "p2p1",
            semID => "p2p1Sem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $p2p1pHost,
            port => $p2p1Port
         )
      );
     
     Tosf::Table::TASK->new(
         name => "pNic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "pNic",
            dcbID => "p",
            semID => "pSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "p2p0Nic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "p2p0Nic",
            dcbID => "p2p0",
            semID => "p2p0Sem"
         )
      );
      Tosf::Table::TASK->new(
         name => "p2p1Nic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "p2p1Nic",
            dcbID => "p2p1",
            semID => "p2p1Sem"
         )
      );

      Tosf::Table::TASK->new(
         name => "pHBeat",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(20),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
         run => TRUE,
         fsm => VHost::Fsm::HBeat->new(
            taskID => "pHBeat",
            dcbID => "p"
         )
      );

      Tosf::Table::TASK->new(
         name => "pTOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(160),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "pTOut",
            sv => "pToSv"
         )
      );
      
      
      Tosf::Table::TASK->new(
         name => "p2p0TOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(160),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "p2p0TOut",
            sv => "pToSv"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "p2p1TOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(160),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "p2p1TOut",
            sv => "pToSv"
         )
      );

      Tosf::Table::TASK->reset("pNic");
      Tosf::Table::TASK->reset("pCon");
      Tosf::Table::TASK->reset("pHBeat");
      Tosf::Table::TASK->reset("pTOut");
      
      Tosf::Table::TASK->reset("p2p0TOut");
      Tosf::Table::TASK->reset("p2p1TOut");
      
       Tosf::Table::TASK->reset("p2p0Nic");
       Tosf::Table::TASK->reset("p2p1Nic");
      
       Tosf::Table::TASK->reset("p2p0Con");
       Tosf::Table::TASK->reset("p2p1Con");

      # ================ STREAM =================

      Tosf::Table::SEMAPHORE->add(name => "sSem", value => 0, max => 1);

      Tosf::Table::TASK->new(
         name => "sCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::StreamCon->new(
            taskID => "sCon",
            dcbID => "stdio",
            semID => "sSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "sSic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Sic->new(
            taskID => "sSic",
            dcbID => "stdio",
            semID => "sSem"
         )
      );
      
      Tosf::Table::TASK->reset("sSic");
      Tosf::Table::TASK->reset("sCon");
      # ==================== Handalers ======================
      Tosf::Table::SEMAPHORE->add(name => "pingSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "icmpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "ipSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "PingdSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hEthSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hArpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hP2pSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hUdpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncdSem", value => 0, max => 1);
       
     
     Tosf::Table::TASK->new(
         name => "hPing",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PING->new(
            taskID => "hPing",
            dcbID => "stdio",
            semID => "pingSem"
         )
      );
      
       Tosf::Table::TASK->new(
         name => "hIncd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INCD->new(
            taskID => "hIncd",
            dcbID => "stdio",
            semID => "IncdSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hInc",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INC->new(
            taskID => "hInc",
            dcbID => "stdio",
            semID => "IncSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIcmp",
         periodic => FALSE,
         run => FALSE,
        fsm => VHost::Fsm::ICMP->new(
            taskID => "hIcmp",
            dcbID => "stdio",
            semID => "icmpSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::IP->new(
            taskID => "hIp",
            dcbID => "stdio",
            semID => "ipSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hPingd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PINGD->new(
            taskID => "hPingd",
            dcbID => "stdio",
            semID => "PingdSem"
        )
      );
      
      Tosf::Table::TASK->new(
         name => "hEth",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ETHERNET->new(
            taskID => "hEth",
            dcbID => "stdio",
            semID => "hEthSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hArp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ARP->new(
            taskID => "hArp",
            dcbID => "stdio",
            semID => "hArpSem"
         )
      );
      Tosf::Table::TASK->new(
         name => "hUdp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::UDP->new(
            taskID => "hUdp",
            dcbID => "stdio",
            semID => "hUdpSem"
         )
      );
       Tosf::Table::TASK->new(
         name => "hP2P",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::P2P->new(
            taskID => "hP2P",
            dcbID => "stdio",
            semID => "hP2pSem"
         )
      );

       Tosf::Table::TASK->reset("hPing");
       Tosf::Table::TASK->reset("hIcmp");
       Tosf::Table::TASK->reset("hIp");
       Tosf::Table::TASK->reset("hPingd");
       Tosf::Table::TASK->reset("hEth");
       Tosf::Table::TASK->reset("hArp");
       Tosf::Table::TASK->reset("hP2P");
       Tosf::Table::TASK->reset("hUdp");
       Tosf::Table::TASK->reset("hInc");
       Tosf::Table::TASK->reset("hIncd");
       
    }elsif ($sel == 4) {
   
    my $pHost = "localhost";
      my $pPort = 8001;

      # no parameter checking is performed on this user data :(

      print("*************************************************\n");
      print("*****              VHost Setup               *****\n");
      print("*************************************************\n \n");

      print("Connecting to $pHost / $pPort \n");

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");
      

      # little checking performed :(

       VHost::Collection::HOST->set_host("Host Larry");
      print(VHost::Collection::HOST->get_host(), "\n");
      print "\n";
      VHost::Collection::HOST->set_port($pPort); 
      #                           Type        Ip             Mac      opden
      Inet::Table::NIC->set('eth0', 'ethernet', '192.168.7.1', '701', '1');
      Inet::Table::ARP->set_mac('192.168.7.2', '702');
      Inet::Table::ROUTE->set_route('192.168.7.1', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.7', '0.0.0.0', 'eth0');
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.7.2', 'eth0');
      print (Inet::Table::ROUTE->dumps);

      # ================ PORT =================
      
      Tosf::Table::SVAR->add(name => "pToSv", value => 0);
      Tosf::Table::SEMAPHORE->add(name => "pSem", value => 0, max => 1);
      

      Tosf::Table::TASK->new(
         name => "pCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "pCon",
            dcbID => "p",
            semID => "pSem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $pHost,
            port => $pPort
         )
      );
      
      
      

      Tosf::Table::TASK->new(
         name => "pNic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "pNic",
            dcbID => "p",
            semID => "pSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "pHBeat",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(20),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
         run => TRUE,
         fsm => VHost::Fsm::HBeat->new(
            taskID => "pHBeat",
            dcbID => "p"
         )
      );

      Tosf::Table::TASK->new(
         name => "pTOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(60),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "pTOut",
            sv => "pToSv"
         )
      );

      Tosf::Table::TASK->reset("pNic");
      Tosf::Table::TASK->reset("pCon");
      Tosf::Table::TASK->reset("pHBeat");
      Tosf::Table::TASK->reset("pTOut");

      # ================ STREAM =================

      Tosf::Table::SEMAPHORE->add(name => "sSem", value => 0, max => 1);

      Tosf::Table::TASK->new(
         name => "sCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::StreamCon->new(
            taskID => "sCon",
            dcbID => "stdio",
            semID => "sSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "sSic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Sic->new(
            taskID => "sSic",
            dcbID => "stdio",
            semID => "sSem"
         )
      );
      
      Tosf::Table::TASK->reset("sSic");
      Tosf::Table::TASK->reset("sCon");
      # ==================== Handalers ======================
        Tosf::Table::SEMAPHORE->add(name => "pingSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "icmpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "ipSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "PingdSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hEthSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hArpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hP2pSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hUdpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncdSem", value => 0, max => 1);
       
     
     Tosf::Table::TASK->new(
         name => "hPing",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PING->new(
            taskID => "hPing",
            dcbID => "stdio",
            semID => "pingSem"
         )
      );
      
       Tosf::Table::TASK->new(
         name => "hIncd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INCD->new(
            taskID => "hIncd",
            dcbID => "stdio",
            semID => "IncdSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hInc",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INC->new(
            taskID => "hInc",
            dcbID => "stdio",
            semID => "IncSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIcmp",
         periodic => FALSE,
         run => FALSE,
        fsm => VHost::Fsm::ICMP->new(
            taskID => "hIcmp",
            dcbID => "stdio",
            semID => "icmpSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::IP->new(
            taskID => "hIp",
            dcbID => "stdio",
            semID => "ipSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hPingd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PINGD->new(
            taskID => "hPingd",
            dcbID => "stdio",
            semID => "PingdSem"
        )
      );
      
      Tosf::Table::TASK->new(
         name => "hEth",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ETHERNET->new(
            taskID => "hEth",
            dcbID => "stdio",
            semID => "hEthSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hArp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ARP->new(
            taskID => "hArp",
            dcbID => "stdio",
            semID => "hArpSem"
         )
      );
      Tosf::Table::TASK->new(
         name => "hUdp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::UDP->new(
            taskID => "hUdp",
            dcbID => "stdio",
            semID => "hUdpSem"
         )
      );
       Tosf::Table::TASK->new(
         name => "hP2P",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::P2P->new(
            taskID => "hP2P",
            dcbID => "stdio",
            semID => "hP2pSem"
         )
      );

       Tosf::Table::TASK->reset("hPing");
       Tosf::Table::TASK->reset("hIcmp");
       Tosf::Table::TASK->reset("hIp");
       Tosf::Table::TASK->reset("hPingd");
       Tosf::Table::TASK->reset("hEth");
       Tosf::Table::TASK->reset("hArp");
       Tosf::Table::TASK->reset("hP2P");
       Tosf::Table::TASK->reset("hUdp");
       Tosf::Table::TASK->reset("hInc");
       Tosf::Table::TASK->reset("hIncd");
   
   }elsif ($sel == 5) {
   
    my $pHost = "localhost";
      my $pPort = 8002;

      # no parameter checking is performed on this user data :(

      print("*************************************************\n");
      print("*****              VHost Setup               *****\n");
      print("*************************************************\n \n");

      print("Connecting to $pHost / $pPort \n");

      print("*************************************************\n");
      print("*****               End Setup               *****\n");
      print("*************************************************\n \n");
      

      # little checking performed :(

       VHost::Collection::HOST->set_host("Host Curly");
      print(VHost::Collection::HOST->get_host(), "\n");
      print "\n";
      VHost::Collection::HOST->set_port($pPort); 
      #                           Type        Ip             Mac
      Inet::Table::NIC->set('eth0', 'ethernet', '192.168.7.0', '700', '1');
      Inet::Table::ARP->set_mac('192.168.7.2', '702');
      Inet::Table::ROUTE->set_route('192.168.7.0', '0.0.0.0', 'lo');
      Inet::Table::ROUTE->set_route('192.168.7', '0.0.0.0', 'eth0');
      Inet::Table::ROUTE->set_route('0.0.0.0', '192.168.7.0', 'eth0');
      print (Inet::Table::ROUTE->dumps);

      # ================ PORT =================
      
      Tosf::Table::SVAR->add(name => "pToSv", value => 0);
      Tosf::Table::SEMAPHORE->add(name => "pSem", value => 0, max => 1);
      

      Tosf::Table::TASK->new(
         name => "pCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "pCon",
            dcbID => "p",
            semID => "pSem",
            timeoutSv => "pToSv",
            timeoutTask => "pTOut",
            host => $pHost,
            port => $pPort
         )
      );
      
      
      

      Tosf::Table::TASK->new(
         name => "pNic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Nic->new(
            taskID => "pNic",
            dcbID => "p",
            semID => "pSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "pHBeat",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(20),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
         run => TRUE,
         fsm => VHost::Fsm::HBeat->new(
            taskID => "pHBeat",
            dcbID => "p"
         )
      );

      Tosf::Table::TASK->new(
         name => "pTOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(60),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "pTOut",
            sv => "pToSv"
         )
      );

      Tosf::Table::TASK->reset("pNic");
      Tosf::Table::TASK->reset("pCon");
      Tosf::Table::TASK->reset("pHBeat");
      Tosf::Table::TASK->reset("pTOut");

      # ================ STREAM =================

      Tosf::Table::SEMAPHORE->add(name => "sSem", value => 0, max => 1);

      Tosf::Table::TASK->new(
         name => "sCon", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::StreamCon->new(
            taskID => "sCon",
            dcbID => "stdio",
            semID => "sSem"
         )
      );

      Tosf::Table::TASK->new(
         name => "sSic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::Sic->new(
            taskID => "sSic",
            dcbID => "stdio",
            semID => "sSem"
         )
      );
      
      Tosf::Table::TASK->reset("sSic");
      Tosf::Table::TASK->reset("sCon");
      # ==================== Handalers ======================
       Tosf::Table::SEMAPHORE->add(name => "pingSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "icmpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "ipSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "PingdSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hEthSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hArpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hP2pSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "hUdpSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncSem", value => 0, max => 1);
       Tosf::Table::SEMAPHORE->add(name => "IncdSem", value => 0, max => 1);
       
     
     Tosf::Table::TASK->new(
         name => "hPing",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PING->new(
            taskID => "hPing",
            dcbID => "stdio",
            semID => "pingSem"
         )
      );
      
       Tosf::Table::TASK->new(
         name => "hIncd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INCD->new(
            taskID => "hIncd",
            dcbID => "stdio",
            semID => "IncdSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hInc",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::INC->new(
            taskID => "hInc",
            dcbID => "stdio",
            semID => "IncSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIcmp",
         periodic => FALSE,
         run => FALSE,
        fsm => VHost::Fsm::ICMP->new(
            taskID => "hIcmp",
            dcbID => "stdio",
            semID => "icmpSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hIp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::IP->new(
            taskID => "hIp",
            dcbID => "stdio",
            semID => "ipSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hPingd",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::PINGD->new(
            taskID => "hPingd",
            dcbID => "stdio",
            semID => "PingdSem"
        )
      );
      
      Tosf::Table::TASK->new(
         name => "hEth",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ETHERNET->new(
            taskID => "hEth",
            dcbID => "stdio",
            semID => "hEthSem"
         )
      );
      
      Tosf::Table::TASK->new(
         name => "hArp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::ARP->new(
            taskID => "hArp",
            dcbID => "stdio",
            semID => "hArpSem"
         )
      );
      Tosf::Table::TASK->new(
         name => "hUdp",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::UDP->new(
            taskID => "hUdp",
            dcbID => "stdio",
            semID => "hUdpSem"
         )
      );
       Tosf::Table::TASK->new(
         name => "hP2P",
         periodic => FALSE,
         run => FALSE,
         fsm => VHost::Fsm::P2P->new(
            taskID => "hP2P",
            dcbID => "stdio",
            semID => "hP2pSem"
         )
      );

       Tosf::Table::TASK->reset("hPing");
       Tosf::Table::TASK->reset("hIcmp");
       Tosf::Table::TASK->reset("hIp");
       Tosf::Table::TASK->reset("hPingd");
       Tosf::Table::TASK->reset("hEth");
       Tosf::Table::TASK->reset("hArp");
       Tosf::Table::TASK->reset("hP2P");
       Tosf::Table::TASK->reset("hUdp");
       Tosf::Table::TASK->reset("hInc");
       Tosf::Table::TASK->reset("hIncd");
   }
   
     # print("Coming Soon\n");
      #main::leaveScript();
     
     
     # print("Coming Soon\n");
      #main::leaveScript();

}

1;

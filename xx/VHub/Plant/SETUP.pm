package VHub::Plant::SETUP;
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

   my $p0Port;
   my $p4Host;
   my $p4Port;

   # no parameter checking is performed on this user data :(

   print("*************************************************\n");
   print("*****              VHub Setup               *****\n");
   print("*************************************************\n \n");
   print("Four consecutive Tcp Internet port numbers are required on localhost for VHub ports p0 through p3 \n");
   print("Enter Internet port number for VHub p0: ");
   chomp($p0Port = <>);
   print("Mapping \n");
   print("\t VHub port p0 to Internet port number ", $p0Port, "\n");
   print("\t VHub port p1 to Internet port number ", $p0Port + 1, "\n");
   print("\t VHub port p2 to Internet port number ", $p0Port + 2, "\n");
   print("\t VHub port p3 to Internet port number ", $p0Port + 3, "\n \n");

   print("One Tcp Internet port number is required on a connected host for VHub up-link port p4 \n");
   print("Enter Internet host name for VHub p4 (enter none to disable p4): ");
   chomp($p4Host = <>);
   if ($p4Host ne "none") {
      print("Enter Internet port number for VHub p4: ");
      chomp($p4Port = <>);
      print("Mapping \n");
      print("\t VHub up-link port p4 to Internet port number ", $p4Host, ":", $p4Port, "\n \n");
   } else {
      print("Mapping \n");
      print("\t No up-link defined \n \n");
   }
   print("*************************************************\n");
   print("*****               End Setup               *****\n");
   print("*************************************************\n \n");

   Tosf::Table::SVAR->add(name => "p0ToSv", value => 0);
   Tosf::Table::SVAR->add(name => "p1ToSv", value => 0);
   Tosf::Table::SVAR->add(name => "p2ToSv", value => 0);
   Tosf::Table::SVAR->add(name => "p3ToSv", value => 0);

   Tosf::Table::SEMAPHORE->add(name => "p0Sem", value => 0, max => 1);
   Tosf::Table::SEMAPHORE->add(name => "p1Sem", value => 0, max => 1);
   Tosf::Table::SEMAPHORE->add(name => "p2Sem", value => 0, max => 1);
   Tosf::Table::SEMAPHORE->add(name => "p3Sem", value => 0, max => 1);

   # ================ PORT 0 =================

   Tosf::Table::TASK->new(
      name => "p0Con", 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
      deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
      run => TRUE,
      fsm => Inet::Fsm::SocConS->new(
         taskID => "p0Con",
	 dcbID => "p0",
	 semID => "p0Sem",
         timeoutSv => "p0ToSv",
         timeoutTask => "p0TOut",
         port => $p0Port
      )
   );

   Tosf::Table::TASK->new(
      name => "p0Nic",
      periodic => FALSE,
      run => FALSE,
      fsm => VHub::Fsm::Nic->new(
         taskID => "p0Nic",
         dcbID => "p0",
         semID => "p0Sem"
      )
   );

   Tosf::Table::TASK->new(
      name => "p0HBeat",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => VHub::Fsm::HBeat->new(
         taskID => "p0HBeat",
         dcbID => "p0"
      )
   );

   Tosf::Table::TASK->new(
      name => "p0TOut",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(160),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => FALSE,
      fsm => Tosf::Fsm::ATo->new(
         taskID => "p0TOut",
         sv => "p0ToSv"
      )
   );

   # ================ PORT 1 =================
      
   Tosf::Table::TASK->new(
      name => "p1Con", 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
      deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
      run => TRUE,
      fsm => Inet::Fsm::SocConS->new(
         taskID => "p1Con",
	 dcbID => "p1",
	 semID => "p1Sem",
         timeoutSv => "p1ToSv",
         timeoutTask => "p1TOut",
         port => ($p0Port + 1)
      )
   );

   Tosf::Table::TASK->new(
      name => "p1Nic",
      periodic => FALSE,
      run => FALSE,
      fsm => VHub::Fsm::Nic->new(
         taskID => "p1Nic",
         dcbID => "p1",
         semID => "p1Sem"
      )
   );

   Tosf::Table::TASK->new(
      name => "p1HBeat",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => VHub::Fsm::HBeat->new(
         taskID => "p1HBeat",
         dcbID => "p1"
      )
   );

   Tosf::Table::TASK->new(
      name => "p1TOut",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(60),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => FALSE,
      fsm => Tosf::Fsm::ATo->new(
         taskID => "p1TOut",
         sv => "p1ToSv"
      )
   );

   # ================ PORT 2 =================
   
   Tosf::Table::TASK->new(
      name => "p2Con", 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
      deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
      run => TRUE,
      fsm => Inet::Fsm::SocConS->new(
         taskID => "p2Con",
	 dcbID => "p2",
	 semID => "p2Sem",
         timeoutSv => "p2ToSv",
         timeoutTask => "p2TOut",
         port => ($p0Port + 2)
      )
   );

   Tosf::Table::TASK->new(
      name => "p2Nic",
      periodic => FALSE,
      run => FALSE,
      fsm => VHub::Fsm::Nic->new(
         taskID => "p2Nic",
         dcbID => "p2",
         semID => "p2Sem"
      )
   );

   Tosf::Table::TASK->new(
      name => "p2HBeat",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => VHub::Fsm::HBeat->new(
         taskID => "p2HBeat",
         dcbID => "p2"
      )
   );

   Tosf::Table::TASK->new(
      name => "p2TOut",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(60),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => FALSE,
      fsm => Tosf::Fsm::ATo->new(
         taskID => "p2TOut",
         sv => "p2ToSv"
      )
   );
       
   # ================ PORT 3 =================
   #
   Tosf::Table::TASK->new(
      name => "p3Con", 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
      deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
      run => TRUE,
      fsm => Inet::Fsm::SocConS->new(
         taskID => "p3Con",
	 dcbID => "p3",
	 semID => "p3Sem",
         timeoutSv => "p3ToSv",
         timeoutTask => "p3TOut",
         port => ($p0Port + 3)
      )
   );

   Tosf::Table::TASK->new(
      name => "p3Nic",
      periodic => FALSE,
      run => FALSE,
      fsm => VHub::Fsm::Nic->new(
         taskID => "p3Nic",
         dcbID => "p3",
         semID => "p3Sem"
      )
   );

   Tosf::Table::TASK->new(
      name => "p3HBeat",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => VHub::Fsm::HBeat->new(
         taskID => "p3HBeat",
         dcbID => "p3"
      )
   );

   Tosf::Table::TASK->new(
      name => "p3TOut",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(60),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => FALSE,
      fsm => Tosf::Fsm::ATo->new(
         taskID => "p3TOut",
         sv => "p3ToSv"
      )
   );

   # ================ PORT 4 =================
   
   if ($p4Host ne "none") {   

      Tosf::Table::SVAR->add(name => "p4ToSv", value => 0);
      Tosf::Table::SEMAPHORE->add(name => "p4Sem", value => 0, max => 1);

      Tosf::Table::TASK->new(
         name => "p4Con", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         deadline => Tosf::Executive::TIMER->s2t(DCBPOLLFREQ),
         run => TRUE,
         fsm => Inet::Fsm::SocConC->new(
            taskID => "p4Con",
            dcbID => "p4",
            semID => "p4Sem",
            timeoutSv => "p4ToSv",
            timeoutTask => "p4TOut",
            host => $p4Host,
            port => $p4Port
         )
      );

      Tosf::Table::TASK->new(
         name => "p4Nic",
         periodic => FALSE,
         run => FALSE,
         fsm => VHub::Fsm::Nic->new(
            taskID => "p4Nic",
            dcbID => "p4",
            semID => "p4Sem"
         )
      );

      Tosf::Table::TASK->new(
         name => "p4HBeat",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(20),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
         run => TRUE,
         fsm => VHub::Fsm::HBeat->new(
            taskID => "p4HBeat",
            dcbID => "p4"
         )
      );

      Tosf::Table::TASK->new(
         name => "p4TOut",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(60),
         deadline => Tosf::Executive::TIMER->s2t(0.2),
         run => FALSE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "p4TOut",
            sv => "p4ToSv"
         )
      );

      Tosf::Table::TASK->reset("p4Nic");
      Tosf::Table::TASK->reset("p4Con");
      Tosf::Table::TASK->reset("p4HBeat");
      Tosf::Table::TASK->reset("p4TOut");

   }
       

   Tosf::Table::TASK->reset("p0Nic");
   Tosf::Table::TASK->reset("p0Con");
   Tosf::Table::TASK->reset("p0HBeat");
   Tosf::Table::TASK->reset("p0TOut");

   Tosf::Table::TASK->reset("p1Nic");
   Tosf::Table::TASK->reset("p1Con");
   Tosf::Table::TASK->reset("p1HBeat");
   Tosf::Table::TASK->reset("p1TOut");

   Tosf::Table::TASK->reset("p2Nic");
   Tosf::Table::TASK->reset("p2Con");
   Tosf::Table::TASK->reset("p2HBeat");
   Tosf::Table::TASK->reset("p2TOut");

   Tosf::Table::TASK->reset("p3Nic");
   Tosf::Table::TASK->reset("p3Con");
   Tosf::Table::TASK->reset("p3HBeat");
   Tosf::Table::TASK->reset("p3TOut");

}

1;

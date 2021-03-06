package VTap::Plant::SETUP;
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

   my $pHost;
   my $pPort;

   # no parameter checking is performed on this user data :(

   print("*************************************************\n");
   print("*****              VTap Setup               *****\n");
   print("*************************************************\n \n");

   print("Enter Internet host name ");
   chomp($pHost = <>);
   print("Enter Internet port number: ");
   chomp($pPort = <>);
   VTap::Collection::HOST->set_host($pHost);
   VTap::Collection::HOST->set_port($pPort);

   print("*************************************************\n");
   print("*****               End Setup               *****\n");
   print("*************************************************\n \n");

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
      fsm => VTap::Fsm::Nic->new(
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
      fsm => VTap::Fsm::HBeat->new(
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
      fsm => VTap::Fsm::Sic->new(
         taskID => "sSic",
         dcbID => "stdio",
         semID => "sSem"
      )
   );

   Tosf::Table::TASK->reset("sSic");
   Tosf::Table::TASK->reset("sCon");

}

1;

package Switch::Plant::TASK;
#================================================================--
# File Name    : TASK.pm
#
# Purpose      : Task set-up and execution
#
# Author       : Peter Walsh, Vancouver Island University
#
# Modified by  : Alwaleed (Welly) Alqufaydi
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;
use constant TRUE => 1;

sub start {

   Tosf::Table::SVAR->add(name => "p0ToSv", value => 0);
   Tosf::Table::SVAR->add(name => "p1ToSv", value => 0);
   Tosf::Table::SVAR->add(name => "p2ToSv", value => 0);
   Tosf::Table::SVAR->add(name => "p3ToSv", value => 0);

   # ================ PORT 0 =================

   Tosf::Table::TASK->new(
      name => "p0Nic", 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(0.2),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Switch::Fsm::Nic->new(
         taskID => "p0Nic",
	 nicID => "p0",
         timeoutSv => "p0ToSv",
         timeoutTask => "p0TOut",
         port => 5070
      )
   );

   Tosf::Table::TASK->new(
      name => "p0Conn",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(0.2),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Switch::Fsm::Conn->new(
         taskID => "p0Conn",
         nicID => "p0"
      )
   );

   Tosf::Table::TASK->new(
      name => "p0HBeat",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Switch::Fsm::HBeat->new(
         taskID => "p0HBeat",
         nicID => "p0"
      )
   );

   Tosf::Table::TASK->new(
      name => "p0TOut",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(60),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Tosf::Fsm::ATo->new(
         taskID => "p0TOut",
         sv => "p0ToSv"
      )
   );

   Tosf::Table::TASK->new(
      name => "p0VST",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(5),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Switch::Fsm::VST->new(
         taskID => "p0VST",
         nicID => "p0",
		 timer => 10
      )
   );
   # ================ PORT 1 =================
      
   Tosf::Table::TASK->new(
      name => "p1Nic", 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(0.2),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Switch::Fsm::Nic->new(
         taskID => "p1Nic",
	 nicID => "p1",
         timeoutSv => "p1ToSv",
         timeoutTask => "p1TOut",
         port => 5071
      )
   );

   Tosf::Table::TASK->new(
      name => "p1Conn",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(0.2),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Switch::Fsm::Conn->new(
         taskID => "p1Conn",
         nicID => "p1"
		 
      )
   );

   Tosf::Table::TASK->new(
      name => "p1HBeat",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Switch::Fsm::HBeat->new(
         taskID => "p1HBeat",
         nicID => "p1"
      )
   );

   Tosf::Table::TASK->new(
      name => "p1TOut",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(60),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Tosf::Fsm::ATo->new(
         taskID => "p1TOut",
         sv => "p1ToSv"
      )
   );

	Tosf::Table::TASK->new(
      name => "p1VST",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(5),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Switch::Fsm::VST->new(
         taskID => "p1VST",
         nicID => "p1",
		 timer => 10
      )
   );
   # ================ PORT 2 =================
   
   Tosf::Table::TASK->new(
      name => "p2Nic", 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(0.2),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Switch::Fsm::Nic->new(
         taskID => "p2Nic",
	 nicID => "p2",
         timeoutSv => "p2ToSv",
         timeoutTask => "p2TOut",
         port => 5072
      )
   );

   Tosf::Table::TASK->new(
      name => "p2Conn",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(0.2),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Switch::Fsm::Conn->new(
         taskID => "p2Conn",
         nicID => "p2"
		 
      )
   );

   Tosf::Table::TASK->new(
      name => "p2HBeat",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Switch::Fsm::HBeat->new(
         taskID => "p2HBeat",
         nicID => "p2"
      )
   );

   Tosf::Table::TASK->new(
      name => "p2TOut",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(60),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Tosf::Fsm::ATo->new(
         taskID => "p2TOut",
         sv => "p2ToSv"
      )
   );
      	
	Tosf::Table::TASK->new(
      name => "p2VST",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(5),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Switch::Fsm::VST->new(
         taskID => "p2VST",
         nicID => "p2",
		 timer => 10
      )
   ); 
   # ================ PORT 3 =================
   #
   Tosf::Table::TASK->new(
      name => "p3Nic", 
      periodic => TRUE, 
      period => Tosf::Executive::TIMER->s2t(0.2),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Switch::Fsm::Nic->new(
         taskID => "p3Nic",
	 nicID => "p3",
         timeoutSv => "p3ToSv",
         timeoutTask => "p3TOut",
         port => 5073
      )
   );

   Tosf::Table::TASK->new(
      name => "p3Conn",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(0.2),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Switch::Fsm::Conn->new(
         taskID => "p3Conn",
         nicID => "p3"
		 
		 
      )
   );

   Tosf::Table::TASK->new(
      name => "p3HBeat",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(20),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Switch::Fsm::HBeat->new(
         taskID => "p3HBeat",
         nicID => "p3"
      )
   );

   Tosf::Table::TASK->new(
      name => "p3TOut",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(60),
      deadline => Tosf::Executive::TIMER->s2t(0.2),
      run => TRUE,
      fsm => Tosf::Fsm::ATo->new(
         taskID => "p3TOut",
         sv => "p3ToSv"
      )
   );
    
	Tosf::Table::TASK->new(
      name => "p3VST",
      periodic => TRUE,
      period => Tosf::Executive::TIMER->s2t(5),
      deadline => Tosf::Executive::TIMER->s2t(0.5),
      run => TRUE,
      fsm => Switch::Fsm::VST->new(
         taskID => "p3VST",
         nicID => "p3",
		 timer => 10
      )
   );   

   Tosf::Table::TASK->reset("p0Nic");
   Tosf::Table::TASK->reset("p0Conn");
   Tosf::Table::TASK->reset("p0HBeat");
   Tosf::Table::TASK->reset("p0TOut");
   Tosf::Table::TASK->reset("p0VST");

   Tosf::Table::TASK->reset("p1Nic");
   Tosf::Table::TASK->reset("p1Conn");
   Tosf::Table::TASK->reset("p1HBeat");
   Tosf::Table::TASK->reset("p1TOut");
   Tosf::Table::TASK->reset("p1VST");

   Tosf::Table::TASK->reset("p2Nic");
   Tosf::Table::TASK->reset("p2Conn");
   Tosf::Table::TASK->reset("p2HBeat");
   Tosf::Table::TASK->reset("p2TOut");
   Tosf::Table::TASK->reset("p2VST");

   Tosf::Table::TASK->reset("p3Nic");
   Tosf::Table::TASK->reset("p3Conn");
   Tosf::Table::TASK->reset("p3HBeat");
   Tosf::Table::TASK->reset("p3TOut");
   Tosf::Table::TASK->reset("p3VST");

   Tosf::Executive::TIMER->start();

   while (1) {
      Tosf::Executive::DISPATCHER->tick();
   }

}

1;

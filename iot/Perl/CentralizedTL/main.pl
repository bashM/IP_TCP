#!/usr/bin/perl
#========================================================
# Project      : Time Oriented Software Framework
#
# File Name    : main.pl
#
# Purpose      : main routine of the traffic light example
#                containing controller and sensors/actuators
#                (non networked version)
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#========================================================

$SIG{INT} = sub {leaveScript();};

$SIG{ALRM} = sub {
   my $tl = Tosf::Exception::Monitor->new(
      fn => sub {
         Tosf::Executive::SCHEDULER->tick();
      }
   );
   $tl->run();
};


$|=1;

use strict;
use warnings;
no warnings "experimental::smartmatch";

use lib '../';

#use Sys::Mlockall qw(:all);
#if (mlockall(MCL_CURRENT | MCL_FUTURE) != 0) { die "Failed to lock RAM: $!"; }


use AnyEvent;
use Gtk2 -init;
use Try::Tiny;
use Time::HiRes qw (ualarm);
use Gnome2::Canvas;
use Tosf::Record::SVar;
use Tosf::Record::Task;
use Tosf::Record::Semaphore;
use Tosf::Collection::Queue;
use Tosf::Collection::PQueue;
use Tosf::Collection::STATUS;
use Tosf::Exception::Trap;
use Tosf::Exception::Monitor;
use Tosf::Table::SVAR;
use Tosf::Table::TASK;
use Tosf::Table::SEMAPHORE;
use Tosf::Table::QUEUE;
use Tosf::Table::PQUEUE;
use Tosf::Executive::TIMER;
use Tosf::Executive::SCHEDULER;
use Tosf::Executive::DISPATCHER;
use Tosf::Fsm::ATo;

use CentralizedTL::Plant::SYSTEM;
use CentralizedTL::Fsm::CONN;
use CentralizedTL::Fsm::DISP;

use constant TRUE => 1;
use constant FALSE => 0;
#timer period in seconds
use constant TIMER_PERIOD => 0.01;
use constant NUM_CORES => 4;
use constant SCHEDULING_DISCIPLINE => "EDF";

my $idle_event;

sub leaveScript {
   print("\nShutdown Now !!!!! \n");
   exit();
}

my $tl = Tosf::Exception::Monitor->new(
   fn => sub {

      Tosf::Executive::DISPATCHER->set_num_cores(NUM_CORES);
      Tosf::Executive::SCHEDULER->set_discipline(SCHEDULING_DISCIPLINE);
      Tosf::Executive::TIMER->set_period(TIMER_PERIOD);

      Tosf::Table::SVAR->add(name => "sv_car", value => 0);
      Tosf::Table::SVAR->add(name => "sv_lto", value => 0);
      Tosf::Table::SVAR->add(name => "sv_sto", value => 0);

      Tosf::Table::SEMAPHORE->add(name => "TL", max => 100);

      Tosf::Table::TASK->new(
         name => "STO", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(5),
         deadline => Tosf::Executive::TIMER->s2t(0.1),
         run => TRUE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "STO", 
	    sv => "sv_sto"
	 )
      );
     
      Tosf::Table::TASK->new(
         name => "LTO", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(15),
	 deadline => Tosf::Executive::TIMER->s2t(0.1),
	 run => TRUE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "LTO", 
	    sv => "sv_lto"
	 )
      );
      
      Tosf::Table::TASK->new(
         name => "CONN", 
         periodic => TRUE, 
	 run => TRUE,
	 period => Tosf::Executive::TIMER->s2t(0.1),
	 deadline => Tosf::Executive::TIMER->s2t(0.1),
         fsm => CentralizedTL::Fsm::CONN->new()
      );

      Tosf::Table::TASK->new(
         name => "DISP", 
         periodic => FALSE, 
	 run => FALSE,
         fsm => CentralizedTL::Fsm::DISP->new()
      );

      CentralizedTL::Plant::SYSTEM->start();

      Tosf::Table::TASK->reset("CONN");
      Tosf::Table::TASK->reset("DISP");
      Tosf::Table::TASK->reset("LTO");
      Tosf::Table::TASK->reset("STO");

      Tosf::Executive::TIMER->start();

      $idle_event = AnyEvent->idle(
         cb => sub {
            my $idle = Tosf::Exception::Monitor->new(
	       fn => sub {
	          Tosf::Executive::DISPATCHER->tick();
	        }
            
	    );
            $idle->run();
         } 
      
      );

      # Now enter Gtk2's event loop
      main Gtk2;

   }
);

$tl->run();

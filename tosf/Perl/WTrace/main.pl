#!/usr/bin/perl
#========================================================
# Project      : Time Oriented Software Framework
#
# File Name    : main.pl
#
# Purpose      : main routine for WTrace
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#========================================================

$SIG{INT} = sub {leaveScript();};

my $tc = 0;

$SIG{ALRM} = sub {
   my $tl = Tosf::Exception::Monitor->new(
      fn => sub {
         print("------------------ Tick $tc -----------\n");
	 $tc = $tc + 1;
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
use IO::Socket;
use Tosf::Table::QUEUE;
use Tosf::Table::PQUEUE;
use Tosf::Table::TASK;
use Tosf::Table::SEMAPHORE;
use Tosf::Record::SVar;
use Tosf::Record::Task;
use Tosf::Record::Semaphore;
use Tosf::Collection::Queue;
use Tosf::Collection::PQueue;
use Tosf::Collection::STATUS;
use Tosf::Collection::Line;
use Tosf::Exception::Trap;
use Tosf::Exception::Monitor;
use Tosf::Table::SVAR;
use Tosf::Table::TASK;
use Tosf::Table::SEMAPHORE;
use Tosf::Executive::TIMER;
use Tosf::Executive::SCHEDULER;
use Tosf::Executive::DISPATCHER;
use Tosf::Widgit::Light;
use Tosf::Widgit::Sensor;

use WTrace::Fsm::FOO;

use constant TRUE => 1;
use constant FALSE => 0;
#timer period in seconds
use constant TIMER_PERIOD => 1.0;
use constant NUM_CORES => 1;
use constant SCHEDULING_DISCIPLINE => "EDF";

sub leaveScript {
   my $ev = shift @_;

   print("\nShutdown Now !!!!! \n");
   if (defined($ev)) {
      exit($ev);
   } else {
      exit(0);
   }
}

   my $tl = Tosf::Exception::Monitor->new(
      fn => sub {

      Tosf::Executive::DISPATCHER->set_num_cores(NUM_CORES);
      Tosf::Executive::SCHEDULER->set_discipline(SCHEDULING_DISCIPLINE);
      Tosf::Executive::TIMER->set_period(TIMER_PERIOD);

      Tosf::Table::TASK->new(
         name => "t1", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(8),
         deadline => Tosf::Executive::TIMER->s2t(8),
	 run => TRUE,
	 fsm => WTrace::Fsm::FOO->new(
            name => "t1",
            steps => 1
         )
      );

      Tosf::Table::TASK->new(
         name => "t2", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(5),
         deadline => Tosf::Executive::TIMER->s2t(5),
	 run => TRUE,
	 fsm => WTrace::Fsm::FOO->new(
            name => "t2",
            steps => 2
         )
      );

      Tosf::Table::TASK->new(
         name => "t3", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(10),
         deadline => Tosf::Executive::TIMER->s2t(10),
	 run => TRUE,
	 fsm => WTrace::Fsm::FOO->new(
            name => "t3",
            steps => 4
         )
      );

      Tosf::Table::TASK->reset("t1");
      Tosf::Table::TASK->reset("t2");
      Tosf::Table::TASK->reset("t3");

      Tosf::Executive::TIMER->start();

      while (1) {
         Tosf::Executive::DISPATCHER->tick();
      }

   }
);

$tl->run();


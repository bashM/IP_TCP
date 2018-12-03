#!/usr/bin/perl
#========================================================
# Project      : Time Oriented Software Framework
#
# File Name    : main.pl
#
# Purpose      : main LIGHTS routine of the traffic light example
#                (networked version)
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

#use Sys::Mlockall qw(:all);
#if (mlockall(MCL_CURRENT | MCL_FUTURE) != 0) { die "Failed to lock RAM: $!"; }

use lib '../';
use Try::Tiny;
use Time::HiRes qw (ualarm);
use Scalar::Util qw(looks_like_number);

use IO::Socket::INET;
use Tosf::Table::QUEUE;
use Tosf::Table::PQUEUE;
use Tosf::Table::TASK;
use Tosf::Table::SEMAPHORE;
use Tosf::Record::SVar;
use Tosf::Record::Task;
use Tosf::Record::Semaphore;
use Tosf::Collection::Queue;
use Tosf::Collection::PQueue;
use Tosf::Collection::Line;
use Tosf::Collection::STATUS;
use Tosf::Exception::Trap;
use Tosf::Exception::Monitor;
use Tosf::Table::SVAR;
use Tosf::Table::TASK;
use Tosf::Table::SEMAPHORE;
use Tosf::Executive::TIMER;
use Tosf::Executive::SCHEDULER;
use Tosf::Executive::DISPATCHER;
use Tosf::Fsm::To;

use ControlTL::Fsm::LIGHT;
use ControlTL::Fsm::NIC;
use ControlTL::Fsm::CAR;

use constant TRUE => 1;
use constant FALSE => 0;
#timer period in seconds
use constant TIMER_PERIOD => 0.005;
use constant NUM_CORES => 4;
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

      our $line = Tosf::Collection::Line->new();

      Tosf::Table::SVAR->add(name => "sv_nicTo", value => 0);
      Tosf::Table::SVAR->add(name => "sv_carTo", value => 0);
      Tosf::Table::SVAR->add(name => "sv_car", value => 0);
      Tosf::Table::SVAR->add(name => "sv_lto", value => 0);
      Tosf::Table::SVAR->add(name => "sv_sto", value => 0);

      Tosf::Table::TASK->new(
         name => "LIGHT", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
         fsm => ControlTL::Fsm::LIGHT->new()
      );

      Tosf::Table::TASK->new(
         name => "CAR", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
         fsm => ControlTL::Fsm::CAR->new()
      );

      Tosf::Table::TASK->new(
         name => "NIC", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
         fsm => ControlTL::Fsm::NIC->new()
      );

      Tosf::Table::TASK->new(
         name => "CARTO", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
	 fsm => Tosf::Fsm::To->new(
            name => "CARTO",
            timeOut => 10,
            svName => "sv_carTo"
         )
      );

      Tosf::Table::TASK->new(
         name => "NICTO", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
	 fsm => Tosf::Fsm::To->new(
            name => "NICTO",
            timeOut => 150,
            svName => "sv_nicTo"
         )
      );

      Tosf::Table::TASK->new(
         name => "LTO", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => 1,
	 run => TRUE,
	 fsm => Tosf::Fsm::To->new(
            name => "LTO",
            timeOut => 40,
            svName => "sv_lto"
         )
      );

      Tosf::Table::TASK->new(
         name => "STO", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => 1,
	 run => TRUE,
	 fsm => Tosf::Fsm::To->new(
            name => "STO",
            timeOut => 20,
            svName => "sv_sto"
         )
      );

      Tosf::Table::TASK->reset("LIGHT");
      Tosf::Table::TASK->reset("CAR");
      Tosf::Table::TASK->reset("NIC");
      Tosf::Table::TASK->reset("CARTO");
      Tosf::Table::TASK->reset("NICTO");
      Tosf::Table::TASK->reset("LTO");
      Tosf::Table::TASK->reset("STO");


      Tosf::Executive::TIMER->start();

      while (1) {
         Tosf::Executive::DISPATCHER->tick();
      }

   }
);

$tl->run();

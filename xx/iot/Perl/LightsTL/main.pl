#!/usr/bin/perl
#========================================================
# Project      : Time Oriented Software Framework
#
# File Name    : main.pl
#
# Purpose      : main routine of the traffic light example
#                networkrd version lights only
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
use Tosf::Fsm::To;

use LightsTL::Plant::SYSTEM;
use LightsTL::Fsm::NIC;
use LightsTL::Fsm::LIGHT;

use constant TRUE => 1;
use constant FALSE => 0;
#timer period in seconds
use constant TIMER_PERIOD => 0.01;
use constant NUM_CORES => 4;
use constant SCHEDULING_DISCIPLINE => "EDF";

my $idle_event;

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
      Tosf::Table::SVAR->add(name => "sv_lightTo", value => 0);

      Tosf::Table::TASK->new(
         name => "LIGHT", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
         fsm => LightsTL::Fsm::LIGHT->new()
      );

      Tosf::Table::TASK->new(
         name => "NIC", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
         fsm => LightsTL::Fsm::NIC->new()
      );

      Tosf::Table::TASK->new(
         name => "LIGHTTO", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
	 fsm => Tosf::Fsm::To->new(
            name => "LIGHTTO",
            timeOut => 10,
            svName => "sv_lightTo"
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

      Tosf::Table::TASK->reset("NICTO");
      Tosf::Table::TASK->reset("LIGHTTO");
      Tosf::Table::TASK->reset("NIC");
      Tosf::Table::TASK->reset("LIGHT");

      Tosf::Executive::TIMER->start();

      LightsTL::Plant::SYSTEM->start();

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

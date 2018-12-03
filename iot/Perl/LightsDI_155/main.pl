#!/usr/bin/perl
#========================================================
# Project      : Time Oriented Software Framework
#
# File Name    : main.pl
#
# Purpose      : main routine of the traffic light example
#                connected to the DI-155 Data Capture Box
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
use AnyEvent;
use Gtk2 -init;
use Try::Tiny;
use Time::HiRes qw (ualarm);
use Scalar::Util qw(looks_like_number);
use Gnome2::Canvas;
use Device::SerialPort;
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

use LightsDI_155::Plant::SYSTEM;
use LightsDI_155::Fsm::LIGHT;
use LightsDI_155::Fsm::SIC;

use constant TRUE => 1;
use constant FALSE => 0;
#timer period in seconds
use constant TIMER_PERIOD => 0.05;
use constant NUM_CORES => 4;
use constant SCHEDULING_DISCIPLINE => "EDF";

my $idle_event;

sub leaveScript {
   print("\nShutdown Now !!!!! \n");
   if (defined($main::serialPort)) {
      $main::serialPort->write("stop" . "\r");
      $main::serialPort->write("R1" . "\r");
   }

   exit(0);
}

my $tl = Tosf::Exception::Monitor->new(
   fn => sub {

      Tosf::Executive::DISPATCHER->set_num_cores(NUM_CORES);
      Tosf::Executive::SCHEDULER->set_discipline(SCHEDULING_DISCIPLINE);
      Tosf::Executive::TIMER->set_period(TIMER_PERIOD);

      our $serialPort;
      our $line = Tosf::Collection::Line->new(
	 maxbuff => 10000,
         inLeftFrame => 'sc',
         inRightFrame => "\r",
         outLeftFrame => '', # white space
         outRightFrame => "\r"
      );

      Tosf::Table::SVAR->add(name => "sv_sicTo", value => 0);
      Tosf::Table::SVAR->add(name => "sv_lightTo", value => 0);

      Tosf::Table::TASK->new(
         name => "LIGHT", 
         periodic => TRUE, 
         period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
         fsm => LightsDI_155::Fsm::LIGHT->new()
      );

      Tosf::Table::TASK->new(
         name => "SIC", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(0.1),
         deadline => Tosf::Executive::TIMER->s2t(0.1),
	 run => TRUE,
         fsm => LightsDI_155::Fsm::SIC->new()
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
         name => "SICTO", 
         periodic => TRUE, 
	 period => Tosf::Executive::TIMER->s2t(0.5),
         deadline => Tosf::Executive::TIMER->s2t(0.5),
	 run => TRUE,
	 fsm => Tosf::Fsm::To->new(
            name => "SICTO",
            timeOut => 150,
            svName => "sv_sicTo"
         )
      );

      Tosf::Table::TASK->reset("SICTO");
      Tosf::Table::TASK->reset("LIGHTTO");
      Tosf::Table::TASK->reset("LIGHT");
      Tosf::Table::TASK->reset("SIC");


      Tosf::Executive::TIMER->start();

      LightsDI_155::Plant::SYSTEM->start();

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

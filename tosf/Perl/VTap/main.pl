#!/usr/bin/perl
#========================================================
# Project      : Time Oriented Software Framework
#
# File Name    : main.pl
#
# Purpose      : main VTap routine for Inet sniffer
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#========================================================

$SIG{INT} = sub {leaveScript();};

$SIG{PIPE} = 'IGNORE';

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
use IO::Select;
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
use Tosf::Fsm::ATo;

use Inet::Record::Dcb;
use Inet::Table::DCB;
use Inet::Fsm::SocConS;
use Inet::Fsm::SocConC;
use Inet::Fsm::StreamCon;

use VTap::Fsm::HBeat;
use VTap::Fsm::Nic;
use VTap::Fsm::Sic;
use VTap::Plant::SETUP;
use VTap::Collection::HOST;

use constant TRUE => 1;
use constant FALSE => 0;
#timer period in seconds
use constant TIMER_PERIOD => 0.005;
use constant NUM_CORES => 3;
use constant SCHEDULING_DISCIPLINE => "EDF";
use constant REAL_TIME_TYPE => "SOFT";

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
      Tosf::Executive::SCHEDULER->set_realTime(REAL_TIME_TYPE);
      Tosf::Executive::TIMER->set_period(TIMER_PERIOD);

      VTap::Plant::SETUP->start();

      Tosf::Executive::TIMER->start();

      while (1) {
         Tosf::Executive::DISPATCHER->tick();
      }

   }
);

$tl->run();

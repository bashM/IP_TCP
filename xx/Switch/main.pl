#!/usr/bin/perl
#========================================================
# Project      : Time Oriented Software Framework
#
# File Name    : main.pl
#
# Purpose      : main VHub routine for the 4 port hub (without collisions)
#                (under construction)
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

use Inet::Record::Route;
use Inet::Table::ROUTE;
use Inet::Packet::Generic;
use Inet::Packet::Ethernet;

use Switch::Fsm::Nic;
use Switch::Fsm::HBeat;
use Switch::Fsm::VST;
use Switch::Fsm::Conn;
use Switch::Table::NIC;
use Switch::Record::Nic;
use Switch::Plant::TASK;
#use Switch::Table::MAC;

use constant TRUE => 1;
use constant FALSE => 0;
#timer period in seconds
use constant TIMER_PERIOD => 0.05;
use constant NUM_CORES => 3;
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

      Switch::Plant::TASK->start();

      Tosf::Executive::TIMER->start();

      while (1) {
         Tosf::Executive::DISPATCHER->tick();
      }

   }
);

$tl->run();

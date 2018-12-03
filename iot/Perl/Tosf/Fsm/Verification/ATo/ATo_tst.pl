#!/usr/bin/perl
######################################################
# Peter Walsh
# TO test driver
######################################################

use lib '../../../../';

use strict;
use warnings;

#===================
# Note, ATo.mmt must be translated to Ato.pm
# before using this script.
# type make translate
#===================

use constant TRUE => 1;
use constant FALSE => 0;

use Time::HiRes qw (ualarm);
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

Tosf::Executive::DISPATCHER->set_num_cores(4);
Tosf::Executive::SCHEDULER->set_discipline("EDF");
Tosf::Executive::TIMER->set_period(0.05);

Tosf::Table::SVAR->add(name => "ltoSv", value => 0);

my $val = Tosf::Table::SVAR->get_value("ltoSv");
print("Initial value of ltoSv is $val  \n");

my $ticksIn15s = Tosf::Executive::TIMER->s2t(15);
print("Ticks in 15 seconds is $ticksIn15s \n");

my $t=0;
my $tr = Tosf::Exception::Monitor->new(
   fn => sub {

      Tosf::Table::TASK->new(
         name => "LTO",
         periodic => TRUE,
         period => Tosf::Executive::TIMER->s2t(15),
         deadline => Tosf::Executive::TIMER->s2t(0.1),
         run => TRUE,
         fsm => Tosf::Fsm::ATo->new(
            taskID => "LTO",
            sv => "ltoSv"
         )
      );

      Tosf::Table::TASK->reset("LTO");

      for (my $i = 0; $i <= 400; $i++) {
         Tosf::Executive::SCHEDULER->tick();
         Tosf::Executive::DISPATCHER->tick();
	 $t = $t + 1;
         $val = Tosf::Table::SVAR->get_value("ltoSv");
         print("Tick $t Current value of ltoSv is $val  \n");
	 if ($t == 10) {
	    Tosf::Table::TASK->reset("LTO");
	 }
      }
   }
);

$tr->run();


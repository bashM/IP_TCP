#!/usr/bin/perl
######################################################
# Peter Walsh
# File: SEMAPHORE_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Try::Tiny;
use Tosf::Exception::Trap;
use Tosf::Exception::Monitor;
use Tosf::Record::Semaphore;
use Tosf::Record::Task;
use Tosf::Record::SVar;
use Tosf::Table::SEMAPHORE;
use Tosf::Table::TASK;
use Tosf::Table::SVAR;
use Tosf::Table::QUEUE;
use Tosf::Collection::Queue;

my $tst = Tosf::Exception::Monitor->new(
   fn => sub {
      Tosf::Table::SEMAPHORE->add(name => "S1", value => 0, max => 2);
      Tosf::Table::SEMAPHORE->dump();
      my $val = Tosf::Table::SEMAPHORE->get_value("S1");
      my $max = Tosf::Table::SEMAPHORE->get_max("S1");
      Tosf::Table::SEMAPHORE->signal(semaphore => "S1");
      Tosf::Table::SEMAPHORE->signal(semaphore => "S1");
      print("Two signals \n");
      Tosf::Table::SEMAPHORE->dump();
      my $val = Tosf::Table::SEMAPHORE->get_value("S1");
      my $max = Tosf::Table::SEMAPHORE->get_max("S1");
      Tosf::Table::SEMAPHORE->signal(semaphore => "S1");
      print("One more signal \n");
      Tosf::Table::SEMAPHORE->dump();
      my $val = Tosf::Table::SEMAPHORE->get_value("S1");
      my $max = Tosf::Table::SEMAPHORE->get_max("S1");

      exit(0);
      Tosf::Table::SEMAPHORE->add(name => "S2");
      Tosf::Table::TASK->new(name => "T1", periodic => 1, period => 10, elapsedTime => 3, deadline => 4, fsm => "dummy");
      Tosf::Table::SEMAPHORE->dump();
      Tosf::Table::TASK->dump();

      Tosf::Table::SEMAPHORE->wait(semaphore => "S2", task => "T1");
      
      Tosf::Table::SEMAPHORE->dump();
      Tosf::Table::TASK->dump();

   }
);

$tst->run();

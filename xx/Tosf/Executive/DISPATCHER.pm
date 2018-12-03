package Tosf::Executive::DISPATCHER;
#================================================================--
# File Name    : DISPATCHER.pm
#
# Purpose      : execute scheduled tasks
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

my $num_cores = 1;

sub set_num_cores {
   my $self = shift @_;
   $num_cores = shift @_;
}

sub tick {

   my $key;
   my $fsm;
   my $res;

   while (Tosf::Collection::STATUS->get_cycleComplete()) { };

   my $core_count = 0;
   
   while (Tosf::Table::PQUEUE->get_siz('pTask') && ($core_count < $num_cores)) {
      $core_count = $core_count + 1;
      $key = Tosf::Table::PQUEUE->dequeue('pTask');
      #Tosf::Collection::STATUS->set_currentExecutingTask($key);
      $fsm = Tosf::Table::TASK->get_fsm($key);
      Tosf::Table::TASK->set_nextState($key, $fsm->tick(Tosf::Table::TASK->get_nextState($key)));
   }

   # dequeue remaining periodic tasks and throw away
   while (Tosf::Table::PQUEUE->get_siz('pTask')) {
      $key = Tosf::Table::PQUEUE->dequeue('pTask');
   }

   while (Tosf::Table::QUEUE->get_siz('apTask') && ($core_count < $num_cores)) {
      $core_count = $core_count + 1;
      $key = Tosf::Table::QUEUE->dequeue('apTask');
      #Tosf::Collection::STATUS->set_currentExecutingTask($key);
      $fsm = Tosf::Table::TASK->get_fsm($key);
      Tosf::Table::TASK->set_nextState($key, $fsm->tick(Tosf::Table::TASK->get_nextState($key)));
   }

   # aperiodic tasks are executed round-robin

   Tosf::Collection::STATUS->set_cycleComplete(1);
}

1;

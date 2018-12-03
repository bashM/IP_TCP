package Tosf::Executive::SCHEDULER;
#================================================================--
# File Name    : SCHEDULER.pm
#
# Purpose      : EDF schedular
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;
#no warnings "experimental::smartmatch";

my $discipline = "EDF";
my $realTime = "HARD";
my $cycleWarningCount = 0;

sub set_discipline {
   my $self = shift @_;
   $discipline = shift @_;
}

sub set_realTime {
   my $self = shift @_;
   $realTime = shift @_;
}
 
sub tick {

   my @keys = Tosf::Table::TASK->get_keys();
   my $k;
   my $priority;
   my $inq;
   my $et;
   
   if (!Tosf::Collection::STATUS->get_cycleComplete()) {
      if ($realTime eq "SOFT") {
         $cycleWarningCount = $cycleWarningCount + 1;
         print("WARNING: $cycleWarningCount not all tasks executed on the previous cycle \n");
         return;
      } else {
      # $et = Tosf::Collection::STATUS->get_currentExecutingTask(); 
      # print("FATAL ERROR occurred during the executio of task $et \n");
      die(Tosf::Exception::Trap->new(
         name => "cycleNotComplete" , 
         description => "Executive::SCHEDULER->tick not all tasks executed on the previous cycle"
      ));

      }
   }

   Tosf::Table::SVAR->update_all();

   foreach $k (@keys) {

      if (Tosf::Table::TASK->get_periodic($k)) { 

         #my $b = Tosf::Table::TASK->get_blocked($k);
	 #my $d = Tosf::Table::TASK->get_deadline($k);
	 #my $e = Tosf::Table::TASK->get_elapsedTime($k);
	 #print("Task $k Blocked $b Elapsed Time $e Deadline $d \n"); 

         if (Tosf::Table::TASK->get_blocked($k)) {
            if (Tosf::Table::TASK->get_period($k) == (Tosf::Table::TASK->get_elapsedTime($k))) {
               Tosf::Table::TASK->resume($k);
	       #print("Resume $k  \n");
            } else {
	       Tosf::Table::TASK->increment_elapsedTime($k);
            }
         } 

         if (!Tosf::Table::TASK->get_blocked($k)) {

            if ($discipline eq "EDF") {
               $priority = Tosf::Table::TASK->get_deadline($k) - Tosf::Table::TASK->get_elapsedTime($k);
            } elsif ($discipline eq "RM") {
               $priority = Tosf::Table::TASK->get_period($k);
            } else {
               die(Tosf::Exception::Trap->new(
                  name => "invalidSchedulingArgorithm" ,
                  description => "Executive::SCHEDULER-> invalid scheduling algorithm specified in main.pl"
               ));
            }

	    #print("Priority for task $k is $priority \n");
            if (Tosf::Table::TASK->get_deadline($k) <= Tosf::Table::TASK->get_elapsedTime($k)) {
               die(Tosf::Exception::Trap->new(name => "Event::SCHEDULER->tick task $k missed deadline"));
            }
	    Tosf::Table::PQUEUE->enqueue('pTask', $k, $priority);
	    Tosf::Table::TASK->increment_elapsedTime($k);
         }

      } else {
         if (!Tosf::Table::TASK->get_blocked($k)) {
            #print("Aperiodic task $k is not blocked \n");
            $inq = Tosf::Table::QUEUE->is_member('apTask', $k);
            if (!$inq) {
               Tosf::Table::QUEUE->enqueue('apTask', $k);
            }
	    # Note, this task is enqueued on a non priority queue
         }
      }

   }

   Tosf::Collection::STATUS->set_cycleComplete(0);

}

1;

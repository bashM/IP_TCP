package Tosf::Record::Task;
#================================================================--
# File Name    : Task.pm
#
# Purpose      : implements Task record
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

my $name = ' ';
my $period = ' ';
my $periodic = ' ';
my $elapsedTime = 0;
my $deadline = 0;
my $fsm = ' ';
my $currentState = ' ';
my $nextState = ' ';

sub  new {
   my $class = shift @_;

   my $self = {
      name => $name,
      period => $period,
      periodic => $periodic,
      elapsedTime => $elapsedTime,
      deadline => $deadline,
      fsm => $fsm,
      currentState => $currentState,
      nextState => $nextState
   };
                
   bless ($self, $class);
   return $self;
}

sub get_name {
   my $self = shift @_;
   
   return $self->{name};
}

sub set_name {
   my $self = shift @_;
   my $n = shift @_;
 
   $self->{name} = $n;
   return;
}

sub get_period {
   my $self = shift @_;
   
   return $self->{period};
}

sub set_period {
   my $self = shift @_;
   my $p = shift @_;
 
   $self->{period} = $p;
   return;
}

sub get_periodic {
   my $self = shift @_;

   return $self->{periodic};
}

sub set_periodic {
   my $self = shift @_;
   my $pflag = shift @_;
 
   $self->{periodic} = $pflag;
   return;
}

sub get_elapsedTime {
   my $self = shift @_;
   
   return $self->{elapsedTime};
}

sub set_elapsedTime {
   my $self = shift @_;
   my $et = shift @_;
 
   $self->{elapsedTime} = $et;
   return;
}

sub get_deadline {
   my $self = shift @_;

   return $self->{deadline};
}

sub set_deadline {
   my $self = shift @_;
   my $d = shift @_;
 
   $self->{deadline} = $d;
   return;
}

sub get_fsm {
   my $self = shift @_;

   return $self->{fsm};
}

sub set_fsm {
   my $self = shift @_;
   my $f = shift @_;

   $self->{fsm} = $f;
   return;
}

sub get_currentState {
   my $self = shift @_;
   
   return $self->{currentState};
}

sub set_currentState {
   my $self = shift @_;
   my $s = shift @_;
 
   $self->{currentState} = $s;
   return;
}

sub get_nextState {
   my $self = shift @_;
   
   return $self->{nextState};
}

sub set_nextState {
   my $self = shift @_;
   my $s = shift @_;
 
   $self->{nextState} = $s;
   return;
}

sub dump {
   my $self = shift @_;

   print ("Name: $self->{name} \n");
   print ("Period: $self->{period} \n");
   print ("Periodic: $self->{periodic} \n");
   print ("Elapsed Time: $self->{elapsedTime} \n");
   print ("Deadline: $self->{deadline} \n");
   print ("FSM: $self->{fsm} \n");
   print ("Current State: $self->{currentState} \n");
   print ("Next State: $self->{nextState} \n");
   return;
}

1;

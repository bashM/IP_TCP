package Tosf::Record::Semaphore;
#================================================================--
# File Name    : Semaphore.pm
#
# Purpose      : implements Semaphore record
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

my $value = 0;
my $max = 1;

sub  new {
   my $class = shift @_;
   my %params = @_;

   if (defined($params{value})) {
      $value = $params{value};
   }

   if (defined($params{max})) {
      $max = $params{max};
   }

   my $self = {
      value => $value,
      max => $max,
      waitQueue => Tosf::Collection::Queue->new()
   };
                
   bless ($self, $class);
   return $self;
}

sub get_max {
   my $self = shift @_;
   
   return $self->{max};
}

sub set_max {
   my $self = shift @_;
   my $m = shift @_;
 
   $self->{max} = $m;
   return;
}

sub get_value	 {
   my $self = shift @_;
   
   return $self->{value};
}

sub set_value {
   my $self = shift @_;
   my $v = shift @_;
 
   $self->{value} = $v;
   return;
}

sub wait {
   my $self = shift @_;
   my $t = shift @_;

   if ($self->{value} == 0) {
      Tosf::Table::TASK->set_blocked($t, 1); 
      $self->{waitQueue}->enqueue($t);
   } else {
      $self->{value} = $self->{value} - 1;
   }

   return;
}

sub signal {
   my $self = shift @_;
   my $t;

   my $q_size = $self->{waitQueue}->get_siz();
   if ($q_size > 0) {
      $t = $self->{waitQueue}->dequeue();
      Tosf::Table::TASK->set_blocked($t, 0); 
   } else {
      if ($self->{value} < $self->{max}) {
         $self->{value} = $self->{value} + 1;
      }
   }

   return;
}

sub dump {
   my $self = shift @_;

   print ("Value: $self->{value} \n");
   print ("Max: $self->{max} \n");
   return;
}

1;

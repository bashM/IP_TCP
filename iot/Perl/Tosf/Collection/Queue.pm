package Tosf::Collection::Queue;
#================================================================--
# File Name    : Queue.pm
#
# Purpose      : implements queue ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant TRUE => 1;
use constant FALSE => 0;

no warnings "experimental::smartmatch";

sub  new {
   my $class = shift @_;

   my $self = {
      queue => [ ]
   };
                
   bless ($self, $class);

   return $self;
}

sub enqueue {
   my $self = shift @_;
   my $l = shift @_;
   
   push (@{$self->{queue}}, $l);

   return;
}

sub dequeue {
   my $self = shift @_;

   return shift(@{$self->{queue}});
}
   
sub get_siz {
   my $self = shift @_;

   return ($#{$self->{queue}} + 1 );
}

sub is_member {
   my $self = shift @_;
   my $l = shift @_;

   my $siz = ($#{$self->{queue}});
   for (my $i=0; $i<=$siz; $i++) {
      if ($l ~~ $self->{queue}[$i]) {
         return TRUE;
      }
   }

   return FALSE;
}

sub dump {
   my $self = shift @_;

   my @q = @{$self->{queue}};

   print("Queue:  @q \n");
}

1;

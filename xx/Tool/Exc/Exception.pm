package Exc::Exception;
#================================================================--
# Design Unit  : exception module
#
# File Name    : Exception.pm
#
# Purpose      : implements exception service routines
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

sub new {
   my $class = shift @_;
   my %params = @_;

   my $self = {
      name => 0,
   };

   $self->{name} = $params{name};

   bless ($self, $class);

   return $self;
}

sub get_name {
   my $self = shift @_;

    return $self->{name};
}

sub set_name {
   my $self = shift @_;
   my $val = shift @_;

   $self->{name} = $val;

   return 0;
}


1;

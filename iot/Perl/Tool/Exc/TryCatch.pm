package Exc::TryCatch;
#================================================================--
# File Name    : Exc/TryCatch.pm
#
# Purpose      : Wrap generic try/catch blocks around a function
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;
no warnings "experimental::smartmatch";

use Try::Tiny;

my $mon_ref =  sub {
   my $code = shift @_;

   # a reference to this routine is returned
   return sub {
      my @p = @_;
      
      try {
         $code->(@p);
      }
      catch {
         my $cew_e = $_;
         if (ref($cew_e) ~~ "Exc::Exception") {
            my $exc_name = $cew_e->get_name();
            print("FATAL ERROR: $exc_name \n");
         } else {
            print("FATAL ERROR: $cew_e");
         }

         exit();
      }
   }   
};

sub new {
   my $class = shift @_;
   my %params = @_;

   my $self = {
      fn => ' '
   };

   $self->{fn} = $params{fn};

   bless ($self, $class);

   return $self;
}

sub run {
   my $self = shift @_;

   ($mon_ref->($self->{fn}))->(@_);
}

sub get_wfn {
   my $self = shift @_;

   return $mon_ref->($self->{fn});
}


1;

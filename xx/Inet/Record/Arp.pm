package Inet::Record::Arp;
#================================================================--
# File Name    : Record/Arp.pm
#
# Purpose      : implements Route record
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;


my $mac = ' ';
my $time = 10 ; #change to 60

sub  new {
   my $class = shift @_;

   my $self = {mac => $mac,
    time => $time
   };
                
   bless ($self, $class);
   return $self;
}

sub get_mac {
   my $self = shift @_;
   
   return $self->{mac};
}

sub get_time {
   my $self = shift @_;
   
   return $self->{time};
}

sub count_down{
   my $self = shift @_;
   
   if(defined $self->{time}){
        $self->{time}--;
        if ($self->{time} eq 0 ){
            $self->{time} = undef;
            
        }         
   }
   
   return $self->{mac};
}

sub set_mac {
   my $self = shift @_;
   my $m = shift @_;
 
   $self->{mac} = $m;
   return;
}

sub dump {
   my $self = shift @_;

   print ("Mac: $self->{mac} \n");
   return;
}

1;

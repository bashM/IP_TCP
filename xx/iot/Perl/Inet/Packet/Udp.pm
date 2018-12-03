package Inet::Packet::Udp;
#================================================================--
# File Name    : Packet/Udp.pm
#
# Purpose      : implements Udp packet ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant PCHAR => '_J_';

my $src_port = ' ';
my $dest_port = ' ';
my $msg = ' ';

sub  new {
   my $class = shift @_;
   my $name = shift @_;

   my $self = {src_port => $src_port,
      dest_port => $dest_port,
      msg => $msg
   };
                
   bless ($self, $class);

   return $self;
}

sub get_src_port {
   my $self = shift @_;
   
   return $self->{src_port};
}

sub set_src_port {
   my $self = shift @_;
   my $srp = shift @_;
 
   if (defined($srp)) {
      $self->{src_port} = $srp;
   }

   return;
}

sub get_dest_port {
   my $self = shift @_;

   return $self->{dest_port};
}

sub set_dest_port {
   my $self = shift @_;
   my $dep = shift @_;
 
   if (defined($dep)) {
      $self->{dest_port} = $dep;
   }

   return;
}

sub get_msg {
   my $self = shift @_;

   return $self->{msg};
}

sub set_msg {
   my $self = shift @_;
   my $ms = shift @_;

   if (defined($ms)) {
      $self->{msg} = $ms;
   }

   return;
}

sub encode {
   my $self = shift @_;

   my @m;
   $m[0] = $self->{src_port};
   $m[1] = $self->{dest_port};
   $m[2] = $self->{msg};

   return join(PCHAR, @m);
}

sub decode {
   my $self = shift @_;
   my $pkt = shift @_;

   my @m = split(PCHAR, $pkt);

   $self->{src_port} = $m[0];
   $self->{dest_port} = $m[1];
   $self->{msg} = $m[2];
 
   return;
}

sub dump {
   my $self = shift @_;

   print ("SRC_PORT: $self->{src_port} \n");
   print ("DEST_PORT: $self->{dest_port} \n");
   print ("MSG: $self->{msg} \n");

   return;
}

1;

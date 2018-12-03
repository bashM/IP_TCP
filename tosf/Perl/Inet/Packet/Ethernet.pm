package Inet::Packet::Ethernet;
#================================================================--
# File Name    : Packet/Ethernet.pm
#
# Purpose      : implements Ethernet packet ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant PCHAR => '_I_';

my $src_mac = ' ';
my $dest_mac = ' ';
my $proto = ' ';
my $err = ' ';
my $msg = ' ';

my $password = "Matthew_spelt_incorrectly-Ethernet";

sub  new {
   my $class = shift @_;
   my $name = shift @_;

   my $self = {src_mac => $src_mac,
      dest_mac => $dest_mac,
      proto => $proto,
      err => $err,
      msg => $msg
   };

   $self->{err} = $password;
   bless ($self, $class);

   return $self;
}

sub get_src_mac {
   my $self = shift @_;
   
   return $self->{src_mac};
}

sub set_src_mac {
   my $self = shift @_;
   my $smac = shift @_;
 
   if (defined($smac)) {
      $self->{src_mac} = $smac;
   }

   return;
}

sub get_dest_mac {
   my $self = shift @_;

   return $self->{dest_mac};
}

sub set_dest_mac {
   my $self = shift @_;
   my $dm = shift @_;
 
   if (defined($dm)) {
      $self->{dest_mac} = $dm;
   }

   return;
}

sub get_proto {
   my $self = shift @_;

   return $self->{proto};
}

sub set_proto {
   my $self = shift @_;
   my $pro = shift @_;
 
   if (defined($pro)) {
      $self->{proto} = $pro;
   }

   return;
}

sub get_err {
   my $self = shift @_;

   return $self->{err};
}

sub packet_in_error {
   my $self = shift @_;

   return ($self->{err} ne $password);
}

sub set_err {
   my $self = shift @_;
   my $er = shift @_;
 
   if (defined($er)) {
      $self->{err} = $er;
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
   $m[0] = $self->{src_mac};
   $m[1] = $self->{dest_mac};
   $m[2] = $self->{proto};
   $m[3] = $self->{err};
   $m[4] = $self->{msg};

   return join(PCHAR, @m);
}

sub decode {
   my $self = shift @_;
   my $pkt = shift @_;

   my @m = split(PCHAR, $pkt);

   $self->{src_mac} = $m[0];
   $self->{dest_mac} = $m[1];
   $self->{proto} = $m[2];
   $self->{err} = $m[3];
   $self->{msg} = $m[4];

   return;
}

sub dump {
   my $self = shift @_;

   print ("SRC_MAC: $self->{src_mac} \n");
   print ("DEST_MAC: $self->{dest_mac} \n");
   print ("PROTO: $self->{proto} \n");
   print ("ERR: $self->{err} \n");
   print ("MSG: $self->{msg} \n");

   return;
}

1;

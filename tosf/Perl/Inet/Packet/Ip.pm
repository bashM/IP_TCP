package Inet::Packet::Ip;
#================================================================--
# File Name    : Packet/Ip.pm
#
# Purpose      : implements Ip packet ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant PCHAR => '_K_';

my $src_ip = ' ';
my $dest_ip = ' ';
my $proto = ' ';
my $err = ' ';
my $ttl = 32;
my $msg = ' ';

my $password = "Peter-IP";

sub  new {
   my $class = shift @_;
   my $name = shift @_;

   my $self = {src_ip => $src_ip,
      dest_ip => $dest_ip,
      proto => $proto,
      err => $err,
      ttl => $ttl,
      msg => $msg
   };

   $self->{err} = $password;
   bless ($self, $class);

   return $self;
}

sub get_src_ip {
   my $self = shift @_;
   
   return $self->{src_ip};
}

sub set_src_ip {
   my $self = shift @_;
   my $srp = shift @_;
 
   if (defined($srp)) {
      $self->{src_ip} = $srp;
   }

   return;
}

sub get_dest_ip {
   my $self = shift @_;

   return $self->{dest_ip};
}

sub set_dest_ip {
   my $self = shift @_;
   my $des = shift @_;
 
   if (defined($des)) {
      $self->{dest_ip} = $des;
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

sub set_err {
   my $self = shift @_;
   my $er = shift @_;
 
   if (defined($er)) {
      $self->{err} = $er;
   }

   return;
}

sub  packet_in_error {
   my $self = shift @_;

   return $self->{err} ne $password;
}

sub get_ttl {
   my $self = shift @_;

   return $self->{ttl};
}

sub set_ttl {
   my $self = shift @_;
   my $tl = shift @_;
 
   if (defined($tl)) {
      $self->{ttl} = $tl;
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
   $m[0] = $self->{src_ip};
   $m[1] = $self->{dest_ip};
   $m[2] = $self->{proto};
   $m[3] = $self->{err};
   $m[4] = $self->{ttl};
   $m[5] = $self->{msg};

   return join(PCHAR, @m);
}

sub decode {
   my $self = shift @_;
   my $pkt = shift @_;

   my @m = split(PCHAR, $pkt);

   $self->{src_ip} = $m[0];
   $self->{dest_ip} = $m[1];
   $self->{proto} = $m[2];
   $self->{err} = $m[3];
   $self->{ttl} = $m[4];
   $self->{msg} = $m[5];

   return;
}

sub dump {
   my $self = shift @_;

   print ("SRC_IP: $self->{src_ip} \n");
   print ("DEST_IP: $self->{dest_ip} \n");
   print ("PROTO: $self->{proto} \n");
   print ("ERR: $self->{err} \n");
   print ("TTL: $self->{ttl} \n");
   print ("MSG: $self->{msg} \n");

   return;
}

1;

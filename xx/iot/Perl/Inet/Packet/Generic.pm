package Inet::Packet::Generic;
#================================================================--
# File Name    : Packet/Generic.pm
#
# Purpose      : implements Generic packet ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant PCHAR => '_N_';

sub  new {
   my $class = shift @_;
   my $name = shift @_;

   my $self = {
      src_port => my $src_port = ' ',
      dest_port => my $dest_port = ' ',
      src_ip => my $src_ip = ' ',
      dest_ip => my $dest_ip = ' ',
      src_mac => my $src_mac = ' ',
      dest_mac => my $dest_mac = ' ',
      interface => my $interface = ' ',
      gateway => my $gateway = ' ',
      device => my $device = ' ',
      msg => my $msg = ' ',
      opcode => my $opcode = ' ',
      ttl => my $ttl = 32
   };

   bless ($self, $class);

   return $self;
}

sub get_interface {
   my $self = shift @_;
   
   return $self->{interface};
}

sub set_interface {
   my $self = shift @_;
   my $s = shift @_;
 
   if (defined($s)) {
      $self->{interface} = $s;
   }

   return;
}

sub get_gateway {
   my $self = shift @_;

   return $self->{gateway};
}

sub set_gateway {
   my $self = shift @_;
   my $g = shift @_;

   if (defined($g)) {
      $self->{gateway} = $g;
   }

   return;
}

sub get_src_ip {
   my $self = shift @_;
   
   return $self->{src_ip};
}

sub set_src_ip {
   my $self = shift @_;
   my $s = shift @_;
 
   if (defined($s)) {
      $self->{src_ip} = $s;
   }

   return;
}

sub get_dest_ip {
   my $self = shift @_;

   return $self->{dest_ip};
}

sub set_dest_ip {
   my $self = shift @_;
   my $d = shift @_;
 
   if (defined($d)) {
      $self->{dest_ip} = $d;
   }

   return;
}

sub set_src_mac {
   my $self = shift @_;
   my $sm = shift @_;
 
   if (defined($sm)) {
      $self->{src_mac} = $sm;
   }

   return;
}

sub get_src_mac {
   my $self = shift @_;

   return $self->{src_mac};
}

sub set_dest_mac {
   my $self = shift @_;
   my $dm = shift @_;
 
   if (defined($dm)) {
      $self->{dest_mac} = $dm;
   }

   return;
}

sub get_dest_mac {
   my $self = shift @_;

   return $self->{dest_mac};
}

sub set_src_port {
   my $self = shift @_;
   my $sp = shift @_;
 
   if (defined($sp)) {
      $self->{src_port} = $sp;
   }

   return;
}

sub get_src_port {
   my $self = shift @_;

   return $self->{src_port};
}

sub set_dest_port {
   my $self = shift @_;
   my $dp = shift @_;
 
   if (defined($dp)) {
      $self->{dest_port} = $dp;
   }

   return;
}

sub get_dest_port {
   my $self = shift @_;

   return $self->{dest_port};
}

sub set_device {
   my $self = shift @_;
   my $d = shift @_;
 
   if (defined($d)) {
      $self->{device} = $d;
   }

   return;
}

sub get_device {
   my $self = shift @_;

   return $self->{device};
}

sub set_ttl { 
   my $self = shift @_;
   my $t = shift @_;

   if (defined($t)) {
      $self->{ttl} = $t;
   }

   return;
}

sub get_ttl { 
   my $self = shift @_;

   return $self->{ttl};
}

sub set_opcode {
   my $self = shift @_;
   my $ph = shift @_;
 
   if (defined($ph)) {
      $self->{opcode} = $ph;
   }

   return;
}

sub get_opcode {
   my $self = shift @_;

   return $self->{opcode};
}

sub set_msg {
   my $self = shift @_;
   my $m = shift @_;
 
   if (defined($m)) {
      $self->{msg} = $m;
   }

   return;
}

sub get_msg {
   my $self = shift @_;

   return $self->{msg};
}

sub encode {
   my $self = shift @_;

   my @m;

   $m[0] = $self->{src_port};
   $m[1] = $self->{dest_port};
   $m[2] = $self->{src_ip};
   $m[3] = $self->{dest_ip};
   $m[4] = $self->{src_mac};
   $m[5] = $self->{dest_mac};
   $m[6] = $self->{interface};
   $m[7] = $self->{gateway};
   $m[8] = $self->{device};
   $m[9] = $self->{msg};
   $m[10] = $self->{opcode};
   $m[11] = $self->{ttl};

   return join(PCHAR, @m);
}

sub decode {
   my $self = shift @_;
   my $pkt = shift @_;

   my @m = split(PCHAR, $pkt);

   $self->{src_port} = $m[0];
   $self->{dest_port} = $m[1];
   $self->{src_ip} = $m[2];
   $self->{dest_ip} = $m[3];
   $self->{src_mac} = $m[4];
   $self->{dest_mac} = $m[5];
   $self->{interface} = $m[6];
   $self->{gateway} = $m[7];
   $self->{device} = $m[8];
   $self->{msg} = $m[9];
   $self->{opcode} = $m[10];
   $self->{ttl} = $m[11];

   return;
}

sub dump {
   my $self = shift @_;

   print ("SRC PORT: $self->{src_port} \n");
   print ("DEST PORT: $self->{dest_port} \n");
   print ("SRC IP: $self->{src_ip} \n");
   print ("DEST IP: $self->{dest_ip} \n");
   print ("SRC MAC: $self->{src_mac} \n");
   print ("DEST MAC: $self->{dest_mac} \n");
   print ("INTERFACE: $self->{interface} \n");
   print ("GATEWAY: $self->{gateway} \n");
   print ("DEVICE: $self->{device} \n");
   print ("MSG: $self->{msg} \n");
   print ("OPCODE: $self->{opcode} \n");
   print ("TTL: $self->{ttl} \n");

   return;
}

1;

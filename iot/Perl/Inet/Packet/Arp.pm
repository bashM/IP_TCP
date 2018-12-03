package Inet::Packet::Arp;
#================================================================--
# File Name    : Packet/Arp.pm
#
# Purpose      : implements Arp packet ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant PCHAR => '_L_';

my $src_ip = ' ';
my $dest_ip = ' ';
my $src_mac = ' ';
my $dest_mac = ' ';
my $opcode = ' ';

sub  new {
   my $class = shift @_;
   my $name = shift @_;

   my $self = {src_ip => $src_ip,
      dest_ip => $dest_ip,
      src_mac => $src_mac,
      dest_mac => $dest_mac,
      opcode => $opcode
   };
                
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

sub get_opcode {
   my $self = shift @_;

   return $self->{opcode};
}

sub set_opcode {
   my $self = shift @_;
   my $op = shift @_;
 
   if (defined($op)) {
      $self->{opcode} = $op;
   }

   return;
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
   my $dmac = shift @_;
 
   if (defined($dmac)) {
      $self->{dest_mac} = $dmac;
   }
   
   return;
}

sub encode {
   my $self = shift @_;

   my @m;
   $m[0] = $self->{src_ip};
   $m[1] = $self->{dest_ip};
   $m[2] = $self->{src_mac};
   $m[3] = $self->{dest_mac};
   $m[4] = $self->{opcode};

   return join(PCHAR, @m);
}

sub decode {
   my $self = shift @_;
   my $pkt = shift @_;

   my @m = split(PCHAR, $pkt);

   $self->{src_ip} = $m[0];
   $self->{dest_ip} = $m[1];
   $self->{src_mac} = $m[2];
   $self->{dest_mac} = $m[3];
   $self->{opcode} = $m[4];

   return;
}

sub dump {
   my $self = shift @_;

   print ("SRC_IP: $self->{src_ip} \n");
   print ("DEST_IP: $self->{dest_ip} \n");
   print ("SRC_MAC: $self->{src_mac} \n");
   print ("DEST_MAC: $self->{dest_mac} \n");
   print ("OPCODE: $self->{opcode} \n");

   return;
}

1;

package Inet::Table::NIC;
#================================================================--
# File Name    : Table/NIC.pm
#
# Purpose      : table of Nic (Socket Cleint) records
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

my %table;

sub get_keys {

   return keys(%table);
}

sub set {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $type = shift @_;
   my $ip = shift @_;
   my $mac = shift @_;
   my $open = shift @_;


   if (!defined($nic_name) || (!defined($type)) || (!defined($ip)) || (!defined($mac)) || (!defined($open))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->set missing parameter"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Inet::Record::Nic->new();
   }

   $table{$nic_name}->set_type($type);
   $table{$nic_name}->set_ip($ip);
   $table{$nic_name}->set_mac($mac);
   $table{$nic_name}->set_open($open);
}

sub set_open {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $o = shift @_;

   if (!defined($nic_name) || (!defined($o))) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->set_open"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Inet::Record::Nic->new();
   }

   $table{$nic_name}->set_open($o);
}

sub get_open {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->get_ip"));
   }

   if (exists($table{$nic_name})) {
      return $table{$nic_name}->get_open();
   } else {
      return undef;
   }
}

sub set_type {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $t = shift @_;

   if (!defined($nic_name) || (!defined($t))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->set_type"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Inet::Record::Nic->new();
   } 

   $table{$nic_name}->set_type($t);
}

sub set_ip {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $ip = shift @_;

   if (!defined($nic_name) || (!defined($ip))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->set_ip"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Inet::Record::Nic->new();
   }

   $table{$nic_name}->set_ip($ip);
}

sub set_mac {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $m = shift @_;

   if (!defined($nic_name) || (!defined($m))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->set_mac"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Inet::Record::Nic->new();
   }

   $table{$nic_name}->set_mac($m);
}


sub get_type {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->get_type"));
   }

   if (exists($table{$nic_name})) {
      return $table{$nic_name}->get_type();
   } else {
      return undef;
   } 
}

sub get_ip {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->get_ip"));
   }

   if (exists($table{$nic_name})) {
      return $table{$nic_name}->get_ip();
   } else {
      return undef;
   }
}

sub get_mac {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->get_mac"));
   }

   if (exists($table{$nic_name})) {
      return $table{$nic_name}->get_mac();
   } else {
      return undef;
   }
}

sub flush {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->flush"));
   }

   if (exists($table{$nic_name})) {
      $table{$nic_name}->flush();
   } 
}

sub dequeue_packet_fragment {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->dequeue_packet_fragment"));
   }

   if (exists($table{$nic_name})) {
      return $table{$nic_name}->dequeue_packet_fragment();
   } else {
      return undef;
   } 
}

sub dequeue_packet {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->dequeue_packet"));
   }

   if (exists($table{$nic_name})) {
      return $table{$nic_name}->dequeue_packet();
   } else {
      return undef;
   } 
}

sub enqueue_packet {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $p = shift @_;

   if (!defined($nic_name) || (!defined($p))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->enqueue_packet"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Inet::Record::Nic->new();
   } 

   $table{$nic_name}->enqueue_packet($p);
}

sub enqueue_packet_fragment {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $f = shift @_;

   if (!defined($nic_name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->enqueue_packet_fragment"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Inet::Record::Nic->new();
   } 

   $table{$nic_name}->enqueue_packet_fragment($f);
}


sub dumps {
   my $self = shift @_;

   my $key;
   my $s = '';

   foreach $key (keys(%table)) {
      $s = $s . "Interface: $key ";
      $s = $s . $table{$key}->dumps();
      $s = $s . "\n";
   } 

   return $s;
}

sub dump {
   my $self = shift @_;

   my $key;

   foreach $key (keys(%table)) {
      print ("Name: $key \n");
      $table{$key}->dump();
      print ("\n");
   } 
}


1;

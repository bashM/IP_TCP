package Switch::Table::NIC;
#================================================================--
# File Name    : Table/NIC.pm
#
# Purpose      : table of Nic records
#
# Author       : Peter Walsh, Vancouver Island University
#
# Modified by  : Alwaleed (Welly) Alqufaydi
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
   my $open = shift @_;
   my $mac = shift @_;
   my $time = shift @_;

   if (!defined($nic_name) || (!defined($open)) || (!defined($mac)) || (!defined($time))) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->set"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Switch::Record::Nic->new();
   }

   #$table{$nic_name}->set_name($nic_name);
   $table{$nic_name}->set_open($open);
   $table{$nic_name}->set_mac($mac);
   $table{$nic_name}->set_time($time);
}

sub set_open {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $o = shift @_;

   if (!defined($nic_name) || (!defined($o))) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->set_open"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Switch::Record::Nic->new();
   }

   $table{$nic_name}->set_open($o);
}

sub set_mac {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $m = shift @_;
   #my $time = shift @_;

   if (!defined($nic_name) || (!defined($m))) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->set_mac"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Switch::Record::Nic->new();
   }

   $table{$nic_name}->set_mac($m);
   #$table{$nic_name}->set_mac($time);
}
sub set_time {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $time = shift @_;
   #my $time = shift @_;

   if (!defined($nic_name) || (!defined($time))) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->set_time"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Switch::Record::Nic->new();
   }

   $table{$nic_name}->set_time($time);
   #$table{$nic_name}->set_mac($time);
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

sub get_mac {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->get_mac"));
   }

   if (exists($table{$nic_name})) {
      return $table{$nic_name}->get_mac();
   } else {
      return undef;
   }
}
sub get_time {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->get_time"));
   }

   if (exists($table{$nic_name})) {
      return $table{$nic_name}->get_time();
   } else {
      return undef;
   }
}
sub flush {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->flush"));
   }

   if (exists($table{$nic_name})) {
      $table{$nic_name}->flush();
   } 
}

sub dequeue_packet_fragment {
   my $pkg = shift @_;
   my $nic_name = shift @_;

   if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->dequeue_packet_fragment"));
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
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->dequeue_packet"));
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
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->enqueue_packet"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Switch::Record::Nic->new();
   } 

   $table{$nic_name}->enqueue_packet($p);
}

sub enqueue_packet_fragment {
   my $pkg = shift @_;
   my $nic_name = shift @_;
   my $f = shift @_;

   if (!defined($nic_name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->enqueue_packet_fragment"));
   }

   if (!exists($table{$nic_name})) {
      $table{$nic_name} = Switch::Record::Nic->new();
   } 

   $table{$nic_name}->enqueue_packet_fragment($f);
}

sub remove {
   my $self = shift @_;
   my $nic_name = shift @_;

    if (!defined($nic_name)) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::NIC->remove"));
   }

   delete($table{$nic_name});
	
    
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

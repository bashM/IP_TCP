package Inet::Table::NIC;
#================================================================--
# File Name    : Table/NIC.pm
#
# Purpose      : table of Nic records
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;
use constant TRUE => 1;
use constant FALSE => 0;

my %table;

sub get_keys {

   return keys(%table);
}

sub set_ip {
   my $pkg = shift @_;
   my $name = shift @_;
   my $ip = shift @_;

   if (!defined($name) || (!defined($ip))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->set_ip"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Nic->new();
   }

   $table{$name}->set_ip($ip);
}

sub set_mac {
   my $pkg = shift @_;
   my $name = shift @_;
   my $m = shift @_;

   if (!defined($name) || (!defined($m))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->set_mac"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Nic->new();
   }

   $table{$name}->set_mac($m);
}

sub set_devName {
   my $pkg = shift @_;
   my $name = shift @_;
   my $d = shift @_;

   if (!defined($name) || (!defined($d))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->set_devName"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Nic->new();
   }

   $table{$name}->set_devName($d);
}



sub get_ip {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->get_ip"));
   }

   if (exists($table{$name})) {
      return $table{$name}->get_ip();
   } else {
      return undef;
   }
}

sub get_mac {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->get_mac name undefined"));
   }

   if (exists($table{$name})) {
      return $table{$name}->get_mac();
   } else {
      return undef;
   }
}

sub get_devName {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->get_devName"));
   }

   if (exists($table{$name})) {
      return $table{$name}->get_devName();
   } else {
      return undef;
   }
}

sub my_mac {
   my $self = shift @_;
   my $m = shift @_;

   if (!defined($m)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::NIC->my_mac"));
   }


   my $key;

   foreach $key (keys(%table)) {
       my $x = $table{$key}->get_mac();
       if ($m eq $table{$key}->get_mac()) {
         return TRUE;
      }
   } 

   return FALSE;
}

sub dumps {
   my $self = shift @_;

   my $key;
   my $s = '';

   foreach $key (keys(%table)) {
      $s = $s . "Name: $key ";
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

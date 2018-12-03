package Inet::Table::DCB;
#================================================================--
# File Name    : Table/DCB.pm
#
# Purpose      : table of Dcb (device control block) records
#
#                Note that you can explicitly add records to the table
#                using the add method or implicitly add records 
#                using the enqueue methods
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

sub add {
   my $pkg = shift @_;
   my $name = shift @_;
   my %lineParams = @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DCB->add missing name"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dcb->new(
         %lineParams
      );
   } else {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DCB->add name already exists in table"));
   }
}

sub set_opened {
   my $pkg = shift @_;
   my $name = shift @_;
   my $o = shift @_;
   my %lineParams = @_;

   if (!defined($name) || (!defined($o))) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::DCB->set_opened"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dcb->new(
         %lineParams
      );
   }

   $table{$name}->set_opened($o);
}

sub get_opened {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "VHub::Table::DCB->get_ip"));
   }

   if (exists($table{$name})) {
      return $table{$name}->get_opened();
   } else {
      return undef;
   }
}

sub flush {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DCB->flush"));
   }

   if (exists($table{$name})) {
      $table{$name}->flush();
   } 
}

sub dequeue_packet_fragment {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DCB->dequeue_packet_fragment"));
   }

   if (exists($table{$name})) {
      return $table{$name}->dequeue_packet_fragment();
   } else {
      return undef;
   } 
}

sub dequeue_packet {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DCB->dequeue_packet"));
   }

   if (exists($table{$name})) {
      return $table{$name}->dequeue_packet();
   } else {
      return undef;
   } 
}

sub enqueue_packet {
   my $pkg = shift @_;
   my $name = shift @_;
   my $p = shift @_;
   my %lineParams = @_;

   if (!defined($name) || (!defined($p))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DCB->enqueue_packet"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dcb->new(
         %lineParams
      );
   } 

   $table{$name}->enqueue_packet($p);
}

sub enqueue_packet_fragment {
   my $pkg = shift @_;
   my $name = shift @_;
   my $f = shift @_;
   my %lineParams = @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DCB->enqueue_packet_fragment"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dcb->new(
         %lineParams
      );
   } 

   $table{$name}->enqueue_packet_fragment($f);
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

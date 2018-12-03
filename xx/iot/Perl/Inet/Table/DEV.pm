package Inet::Table::DEV;
#================================================================--
# File Name    : Table/DEV.pm
#
# Purpose      : table of Dev (device control block) records
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
my $streamDev = undef;

sub get_keys {

   return keys(%table);
}

sub set_inRightFrame {
   my $self = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->set_inRightFrame"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dev->new();
   }

   $table{$name}->set_inRightFrame($f);

   return;
}

sub set_outRightFrame {
   my $self = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->set_outRightFrame"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dev->new();
   }

   $table{$name}->set_outRightFrame($f);

   return;
}

sub set_outLeftFrame {
   my $self = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->set_outLeftFrame"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dev->new();
   }

   $table{$name}->set_outLeftFrame($f);

   return;
}

sub set_inLeftFrame {
   my $self = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->set_inLeftFrame"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dev->new();
   }

   $table{$name}->set_inLeftFrame($f);

   return;
}

sub set_type {
   my $pkg = shift @_;
   my $name = shift @_;
   my $t = shift @_;

   if (!defined($name) || (!defined($t))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->set_type"));
   }

   if (defined($streamDev)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->set_type only one stream is allowed"));
   } elsif ($t eq 'stream') {
      $streamDev = $name;
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dev->new();
   }

   $table{$name}->set_type($t);
}

sub get_type {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->get_type"));
   }

   if (exists($table{$name})) {
      return $table{$name}->get_type();
   } else {
      return undef;
   }
}

sub set_nicName {
   my $pkg = shift @_;
   my $name = shift @_;
   my $n = shift @_;

   if (!defined($name) || (!defined($n))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->set_nicName"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dev->new();
   }

   $table{$name}->set_nicName($n);
}

sub get_nicName {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->get_nicName"));
   }

   if (exists($table{$name})) {
      return $table{$name}->get_nicName();
   } else {
      return undef;
   }
}

sub get_streamDev {
   my $pkg = shift @_;

   return $streamDev;

}

sub set_opened {
   my $pkg = shift @_;
   my $name = shift @_;
   my $o = shift @_;

   if (!defined($name) || (!defined($o))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->set_opened"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dev->new();
   }

   $table{$name}->set_opened($o);
}

sub get_opened {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->get_opened name undefined"));
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
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->flush"));
   }

   if (exists($table{$name})) {
      $table{$name}->flush();
   } 
}

sub dequeue_packet_fragment {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->dequeue_packet_fragment"));
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
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->dequeue_packet"));
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

   if (!defined($name) || (!defined($p))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->enqueue_packet"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dev->new();
   } 

   $table{$name}->enqueue_packet($p);
}

sub enqueue_packet_fragment {
   my $pkg = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::DEV->enqueue_packet_fragment"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Dev->new();
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

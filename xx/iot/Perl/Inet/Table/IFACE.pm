package Inet::Table::IFACE;
#================================================================--
# File Name    : Table/IFACE.pm
#
# Purpose      : table of Iface (device control block) records
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
my $streamIface = undef;

sub get_keys {

   return keys(%table);
}

sub set_inRightFrame {
   my $self = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_inRightFrame"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   }

   $table{$name}->set_inRightFrame($f);

   return;
}

sub set_outRightFrame {
   my $self = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_outRightFrame"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   }

   $table{$name}->set_outRightFrame($f);

   return;
}

sub set_outLeftFrame {
   my $self = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_outLeftFrame"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   }

   $table{$name}->set_outLeftFrame($f);

   return;
}

sub set_inLeftFrame {
   my $self = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_inLeftFrame"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   }

   $table{$name}->set_inLeftFrame($f);

   return;
}

sub set_ip {
   my $pkg = shift @_;
   my $name = shift @_;
   my $ip = shift @_;

   if (!defined($name) || (!defined($ip))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_ip"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   }

   $table{$name}->set_ip($ip);
}

sub set_mac {
   my $pkg = shift @_;
   my $name = shift @_;
   my $m = shift @_;

   if (!defined($name) || (!defined($m))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_mac"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   }

   $table{$name}->set_mac($m);
}

sub get_ip {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->get_ip"));
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
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->get_mac name undefined"));
   }

   if (exists($table{$name})) {
      return $table{$name}->get_mac();
   } else {
      return undef;
   }
}


sub my_mac {
   my $self = shift @_;
   my $m = shift @_;

   if (!defined($m)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->my_mac"));
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

sub set_type {
   my $pkg = shift @_;
   my $name = shift @_;
   my $t = shift @_;

   if (!defined($name) || (!defined($t))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_type"));
   }

   if (defined($streamIface)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_type only one stream is allowed"));
   } elsif ($t eq 'stream') {
      $streamIface = $name;
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   }

   $table{$name}->set_type($t);
}

sub get_type {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->get_type"));
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
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_nicName"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   }

   $table{$name}->set_nicName($n);
}

sub get_streamIface {
   my $pkg = shift @_;

   return $streamIface;

}

sub set_opened {
   my $pkg = shift @_;
   my $name = shift @_;
   my $o = shift @_;

   if (!defined($name) || (!defined($o))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->set_opened"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   }

   $table{$name}->set_opened($o);
}

sub get_opened {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->get_opened name undefined"));
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
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->flush"));
   }

   if (exists($table{$name})) {
      $table{$name}->flush();
   } 
}

sub dequeue_packet_fragment {
   my $pkg = shift @_;
   my $name = shift @_;

   if (!defined($name)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->dequeue_packet_fragment"));
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
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->dequeue_packet"));
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
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->enqueue_packet"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
   } 

   $table{$name}->enqueue_packet($p);
}

sub enqueue_packet_fragment {
   my $pkg = shift @_;
   my $name = shift @_;
   my $f = shift @_;

   if (!defined($name) || (!defined($f))) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::IFACE->enqueue_packet_fragment"));
   }

   if (!exists($table{$name})) {
      $table{$name} = Inet::Record::Iface->new();
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

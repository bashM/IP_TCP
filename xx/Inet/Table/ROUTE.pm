package Inet::Table::ROUTE;
#================================================================--
# File Name    : Table/ROUTE.pm
#
# Purpose      : table of  Route records
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

sub set_route {
   my $pkg = shift @_;
   my $net = shift @_;
   my $gateway = shift @_;
   my $interface = shift @_;

   if (!defined($net) || !defined($gateway) || !defined($interface)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::ROUTE->set_route"));
   }

   if (!exists($table{$net})) {
      $table{$net} = Inet::Record::Route->new();
   }

   $table{$net}->set_interface($interface);
   $table{$net}->set_gateway($gateway);
}

sub get_route {
   my $pkg = shift @_;
   my $ip = shift @_;

   if (!defined($ip)) {
      die(Tosf::Exception::Trap->new(name => "Inet::Table::ROUTE->get_route"));
   }

   my $key;
   my $max = 0;
   my $match = undef;

   foreach $key (keys(%table)) {
      if ($ip =~ m/$key/) {
         if (length($&) > $max) {
            $match = $key;
            $max = length($&);
         }
      }
   }
   
   
   if (defined($match)) {
      return ($table{$match}->get_interface(), $table{$match}->get_gateway());
   } elsif (exists($table{'0.0.0.0'})) {
      return ($table{'0.0.0.0'}->get_interface(), $table{'0.0.0.0'}->get_gateway());
   } else {
      return (undef, undef);
   }
}

sub dumps {
   my $self = shift @_;

   my $key;
   my $s = '';

   foreach $key (keys(%table)) {
      $s = $s . "Net: $key ";
      $s = $s . $table{$key}->dumps();
      $s = $s . "\n";
   }

   return $s;
}

sub dump {
   my $self = shift @_;

   my $key;

   foreach $key (keys(%table)) {
      print ("Net: $key ");
      $table{$key}->dump();
   } 
}

1;

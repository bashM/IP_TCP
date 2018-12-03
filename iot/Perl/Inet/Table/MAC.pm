package Inet::Table::MAC;
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

my $TimeOut = 60;
sub get_keys {

   return keys(%table);
}

sub add{
   my $self = shift @_;
   my $src_mac = shift @_;
   my $iface = shift @_;
   if (!defined($src_mac ) || (!defined($iface))){
      print "Erros\n";
   }
   if (!Inet::Table::MAC->checkMac($src_mac)){
      my $first = {
         #mac => $src_mac,
         iface => $iface,
         timeout => $TimeOut,
      };
      $table{$src_mac} = $first; 
   }else {
      foreach my $mac (keys %table ){
         if($mac eq $src_mac){
           $table{$mac}->{timeout} = $TimeOut ;
         }
      }
   }   
}

sub checkMac{

  my $self = shift @_;
  my $dest_mac = shift @_;
  if(exists ($table {$dest_mac})){
        return $table {$dest_mac}->{iface};
  }else{
      return 0;
  }
   return 0; 
}

sub clean{
        %table = ();
}

sub ticks {
        foreach my $mac (keys %table){
          $table{$mac}->{timeout}--;
          if ($table{$mac}->{timeout} eq 0){
                delete $table{$mac};
          }
   }
}
sub dump{
        print "mac\tiface\ttimeout\n";
        foreach my $mac (keys %table){
        print $mac . "\t". $table{$mac}->{iface}."\t". $table{$mac}->{timeout}."\n";
        }
        
}

1;

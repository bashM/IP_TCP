package Inet::Fsm::Net;

#================================================================--
# File Name    : Fsm/NODE.pm
#
# Purpose      : NODE Controller
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant TRUE  => 1;
use constant FALSE => 0;

sub new {
   my $class  = shift @_;
   my %params = @_;

   my $self = { taskName => my $taskName = "Fsm::NODE::noname" };

   bless( $self, $class );
   return $self;
}

my $gpkt;
my $pkt;
my $raw;
my @keys;
my $k;
my $readSuccess;
my $msg;
my $ns;
my $eth_pkt = Inet::Packet::Ethernet->new();
my $iface;

my $self;
my $mmt_taskName;
my $mmt_currentState;

sub tick {
   $self             = shift @_;
   $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "S0" ) {
      $raw = Tosf::Table::MESSAGE->dequeue( $self->{taskName} );
      $gpkt->decode($raw);
      $iface = $gpkt->get_msg();
      return ( "S1" );
   }

   if ( $mmt_currentState ~~ "S1" ) {
      $readSuccess = FALSE;
      if ( Inet::Table::IFACE->get_opened($iface) ) {
         $pkt = Inet::Table::IFACE->dequeue_packet($iface);
         if ( defined($pkt) ) {
            $readSuccess = TRUE;
            if ( $pkt ne 'heartbeat' ) {

               $eth_pkt->decode($pkt);

               #$eth_pkt->dump();

               my $msg      = $eth_pkt->get_msg();
               my $src_mac  = $eth_pkt->get_src_mac();
               my $dest_mac = $eth_pkt->get_dest_mac();
               Inet::Table::MAC->add( $src_mac, $iface );
               my $dest_Iface = Inet::Table::MAC->checkMac($dest_mac);

               if ($dest_Iface) {
                  Inet::Table::IFACE->enqueue_packet( $dest_Iface, $pkt );

               }
               else {
                  @keys = Inet::Table::IFACE->get_keys();

                  foreach $k (@keys) {
                     if (  ( $k ne $iface )
                        && ( Inet::Table::IFACE->get_opened($k) ) )
                     {
                        Inet::Table::IFACE->enqueue_packet( $k, $pkt );
                     }
                  }

               }

            }
         }
      }

      if ( !$readSuccess ) {
         Tosf::Table::MESSAGE->wait( $self->{taskName} );
         $ns = "S0";
      }
      else {
         $ns = "S1";
      }
      return ( $ns );
   }

   die( Tosf::Exception::Trap->new( name => "Tosf:Mmt  no such state" ) );
}

sub whoami {

   if ( $mmt_taskName eq "none" ) {
      die(
         Tosf::Exception::Trap->new(
            name => "Tosf:Mmt  whoami can only be called from reset"
         )
      );
   }

   return $mmt_taskName;
}

sub reset {
   $self         = shift @_;
   $mmt_taskName = shift @_;
   no warnings "experimental::smartmatch";

   $self->{taskName} = whoami();
   Tosf::Table::MESSAGE->wait( $self->{taskName} );
   $gpkt = Inet::Packet::Generic->new();

   $mmt_taskName = "none";
   return ("S0");
}

1;

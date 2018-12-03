package Inet::Fsm::ETHERNET;

#================================================================--
# File Name    : Fsm/ETHERNET.pm
#
# Purpose      : ETHERNET Controller
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

   my $self = { taskName => my $taskName };

   if ( defined( $params{taskName} ) ) {
      $self->{taskName} = $params{taskName};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::ETHERNET->new  taskName undefined"
         )
      );
   }

   bless( $self, $class );
   return $self;
}

my $generic_pkt;
my $ethernet_pkt;
my $ip_pkt;
my $raw;
my @keys;
my $k;
my $readSuccess;
my $msg;
my $ns;
my $dev;
my $opcode;
my $in_mac;
my $dest_mac;

my $self;
my $mmt_taskName;
my $mmt_currentState;

sub tick {
   $self             = shift @_;
   $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "SIN" ) {
      if ( Inet::Collection::FLAG->get_trace() ) {
         print("In ETHERNET\n");
      }

      $raw = Tosf::Table::MESSAGE->dequeue( $self->{taskName} );
      $generic_pkt->decode($raw);
      $opcode = $generic_pkt->get_opcode();
      return ( $opcode );
   }

   if ( $mmt_currentState ~~ "SOUT" ) {
      if ( Inet::Collection::FLAG->get_trace() ) {
         print("Out ETHERNET\n");
      }

      Tosf::Table::MESSAGE->wait( $self->{taskName} );
      return ( "SIN" );
   }

   if ( $mmt_currentState ~~ "EN2" ) {
      $dev = Inet::Table::NIC->get_devName( $generic_pkt->get_interface() );
      $ethernet_pkt->set_src_mac(
         Inet::Table::ARP->get_mac( $generic_pkt->get_src_ip() ) );

      if ( $generic_pkt->get_gateway() eq '0.0.0.0' ) {
         $dest_mac = Inet::Table::ARP->get_mac( $generic_pkt->get_dest_ip() );
      }
      else {
         $dest_mac = Inet::Table::ARP->get_mac( $generic_pkt->get_gateway() );
      }

      $ethernet_pkt->set_dest_mac($dest_mac);
      $ethernet_pkt->set_msg( $generic_pkt->get_msg() );
      $ethernet_pkt->set_proto("IP");
      Inet::Table::DEV->enqueue_packet( $dev, $ethernet_pkt->encode() );
      return ( "SOUT" );
   }

   if ( $mmt_currentState ~~ "EN1" ) {
      $ethernet_pkt->decode( $generic_pkt->get_msg() );
      $in_mac = $ethernet_pkt->get_dest_mac();
      $generic_pkt->set_src_mac( $ethernet_pkt->get_src_mac() );
      $generic_pkt->set_dest_mac( $ethernet_pkt->get_dest_mac() );
      if ( Inet::Table::NIC->my_mac($in_mac) ) {
         if ( $ethernet_pkt->get_proto() eq 'IP' ) {
            $ip_pkt->decode( $ethernet_pkt->get_msg() );
            $generic_pkt->set_msg( $ethernet_pkt->get_msg() );
            $generic_pkt->set_opcode(0);
            Tosf::Table::MESSAGE->enqueue( "IP", $generic_pkt->encode() );
            Tosf::Table::MESSAGE->signal("IP");
         }
      }
      else {
         #print("Ethernet pkt dropped \n");
      }
      return (
         "SOUT"

      );
   }

   if ( $mmt_currentState ~~ "EN0" ) {
      $dev         = $generic_pkt->get_msg();
      $readSuccess = FALSE;
      if ( Inet::Table::DEV->get_opened($dev) ) {
         $raw = Inet::Table::DEV->dequeue_packet($dev);
         if ( defined($raw) ) {
            $readSuccess = TRUE;
            if ( $raw ne 'heartbeat' ) {
               $generic_pkt->set_opcode("EN1");
               $generic_pkt->set_msg($raw);
               Tosf::Table::MESSAGE->enqueue( "ETHERNET",
                  $generic_pkt->encode() );
               Tosf::Table::MESSAGE->signal("ETHERNET");
            }
         }
      }

      if ($readSuccess) {
         $ns = "EN0";
      }
      else {
         $ns = "SOUT";
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

   Tosf::Table::MESSAGE->wait( $self->{taskName} );

   $generic_pkt  = Inet::Packet::Generic->new();
   $ethernet_pkt = Inet::Packet::Ethernet->new();
   $ip_pkt       = Inet::Packet::Ip->new();

   $mmt_taskName = "none";
   return ("SIN");
}

1;

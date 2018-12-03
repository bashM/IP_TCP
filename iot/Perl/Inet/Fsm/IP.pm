package Inet::Fsm::IP;

#================================================================--
# File Name    : Fsm/IP.pm
#
# Purpose      : IP Controller
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
            name => "Fsm::IP->new  taskName undefined"
         )
      );
   }

   bless( $self, $class );
   return $self;
}

my $dev;
my $generic_pkt;
my $ethernet_pkt;
my $ip_pkt;
my $icmp_pkt;
my $raw;
my @keys;
my $k;
my $readSuccess;
my $ns;
my $opcode;
my $iface;
my $gateway;

my $self;
my $mmt_taskName;
my $mmt_currentState;

sub tick {
   $self             = shift @_;
   $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "SIN" ) {
      if ( Inet::Collection::FLAG->get_trace() ) {
         print("In IP\n");
      }

      $raw = Tosf::Table::MESSAGE->dequeue( $self->{taskName} );
      $generic_pkt->decode($raw);
      $opcode = $generic_pkt->get_opcode();
      if ( $opcode == 0 ) {
         $ns = "OP0";
      }
      elsif ( $opcode == 1 ) {
         $ns = "OP1";
      }
      elsif ( $opcode == 2 ) {
         $ns = "OP2";
      }
      else {
         die(
            Tosf::Exception::Trap->new(
               name => "Fsm::IP->new  invalid opcode $opcode"
            )
         );
      }
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "SOUT" ) {
      if ( Inet::Collection::FLAG->get_trace() ) {
         print("Out IP\n");
      }

      Tosf::Table::MESSAGE->wait( $self->{taskName} );
      return ( "SIN" );
   }

   if ( $mmt_currentState ~~ "OP0" ) {
      $ip_pkt->decode( $generic_pkt->get_msg() );
      $generic_pkt->set_src_ip( $ip_pkt->get_src_ip() );
      $generic_pkt->set_dest_ip( $ip_pkt->get_dest_ip() );
      ( $iface, $gateway ) =
        Inet::Table::ROUTE->get_route( $generic_pkt->get_dest_ip() );
      $generic_pkt->set_interface($iface);
      $generic_pkt->set_gateway($gateway);

      if ( $iface eq "lo" ) {
         if ( $ip_pkt->get_proto() eq 'ICMP' ) {
            $generic_pkt->set_opcode(1);
            $generic_pkt->set_msg( $ip_pkt->get_msg() );
            Tosf::Table::MESSAGE->enqueue( "ICMP", $generic_pkt->encode() );
            Tosf::Table::MESSAGE->signal("ICMP");
         }
      }
      else {
         $dev = Inet::Table::NIC->get_devName($iface);
         if ( Inet::Table::DEV->get_type($dev) eq 'ethernet' ) {
            $generic_pkt->set_opcode(0);
            $generic_pkt->set_msg( $ip_pkt->encode() );
            Tosf::Table::MESSAGE->enqueue( "ETHERNET", $generic_pkt->encode() );
            Tosf::Table::MESSAGE->signal("ETHERNET");
         }
         else {
            Inet::Table::DEV->enqueue_packet( $dev, $ip_pkt->encode() );
         }
      }
      return ( "SOUT" );
   }

   if ( $mmt_currentState ~~ "OP1" ) {

     # Expect an ICMP datagram. Encode an IP packet. Demux to  either localhost,
     # ETHERNET or to DEV ADT

      ( $iface, $gateway ) =
        Inet::Table::ROUTE->get_route( $generic_pkt->get_dest_ip() );
      $generic_pkt->set_interface($iface);
      $generic_pkt->set_gateway($gateway);
      if ( defined($iface) ) {
         if ( $iface eq "lo" ) {
            $generic_pkt->set_src_ip( $generic_pkt->get_dest_ip() );
            $generic_pkt->set_opcode(1);
            Tosf::Table::MESSAGE->enqueue( "ICMP", $generic_pkt->encode() );
            Tosf::Table::MESSAGE->signal("ICMP");
         }
         else {
            if ( $generic_pkt->get_src_ip() eq "0.0.0.0" ) {
               $generic_pkt->set_src_ip( Inet::Table::NIC->get_ip($iface) );
            }
            $generic_pkt->set_interface($iface);

            $ip_pkt->set_src_ip( $generic_pkt->get_src_ip() );
            $ip_pkt->set_dest_ip( $generic_pkt->get_dest_ip() );
            $ip_pkt->set_proto("ICMP");
            $ip_pkt->set_msg( $generic_pkt->get_msg() );

            $dev = Inet::Table::NIC->get_devName($iface);
            if ( Inet::Table::DEV->get_type($dev) eq 'ethernet' ) {
               $generic_pkt->set_opcode(0);
               $generic_pkt->set_msg( $ip_pkt->encode() );
               Tosf::Table::MESSAGE->enqueue( "ETHERNET",
                  $generic_pkt->encode() );
               Tosf::Table::MESSAGE->signal("ETHERNET");
            }
            else {
               Inet::Table::DEV->enqueue_packet( $dev, $ip_pkt->encode() );
            }
         }
      }
      return ( "SOUT" );
   }

   if ( $mmt_currentState ~~ "OP2" ) {
      $dev         = $generic_pkt->get_msg();
      $readSuccess = FALSE;
      if ( Inet::Table::DEV->get_opened($dev) ) {
         $raw = Inet::Table::DEV->dequeue_packet($dev);
         if ( defined($raw) ) {
            $readSuccess = TRUE;
            if ( $raw ne 'heartbeat' ) {
               $generic_pkt->set_opcode(0);
               $generic_pkt->set_msg($raw);
               Tosf::Table::MESSAGE->enqueue( "IP", $generic_pkt->encode() );
               Tosf::Table::MESSAGE->signal("IP");
            }
         }
      }

      if ($readSuccess) {
         $ns = "OP2";
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
   $icmp_pkt     = Inet::Packet::Icmp->new();

   $mmt_taskName = "none";
   return ("SIN");
}

1;

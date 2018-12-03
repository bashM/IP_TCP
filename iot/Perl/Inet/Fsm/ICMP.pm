package Inet::Fsm::ICMP;

#================================================================--
# File Name    : Fsm/ICMP.pm
#
# Purpose      : ICMP Controller
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
            name => "Fsm::ICMP->new  taskName undefined"
         )
      );
   }

   bless( $self, $class );
   return $self;
}

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
my $streamDev;

my $self;
my $mmt_taskName;
my $mmt_currentState;

sub tick {
   $self             = shift @_;
   $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "SIN" ) {
      if ( Inet::Collection::FLAG->get_trace() ) {
         print("In ICMP\n");
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
      else {
         die(
            Tosf::Exception::Trap->new(
               name => "Fsm::ICMP->new  invalid opcode $opcode"
            )
         );
      }
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "SOUT" ) {
      if ( Inet::Collection::FLAG->get_trace() ) {
         print("Out ICMP\n");
      }

      Tosf::Table::MESSAGE->wait( $self->{taskName} );
      return ( "SIN" );
   }

   if ( $mmt_currentState ~~ "OP0" ) {
      $icmp_pkt->set_msg( time() );
      $icmp_pkt->set_type("ECHO");
      $generic_pkt->set_msg( $icmp_pkt->encode() );
      $generic_pkt->set_opcode(1);
      Tosf::Table::MESSAGE->enqueue( "IP", $generic_pkt->encode() );
      Tosf::Table::MESSAGE->signal("IP");
      return ( "SOUT" );
   }

   if ( $mmt_currentState ~~ "OP1" ) {
      $icmp_pkt->decode( $generic_pkt->get_msg() );
      if ( $icmp_pkt->get_type() eq "REPLY" ) {
         $streamDev = Inet::Table::DEV->get_streamDev();
         my $t = time() - $icmp_pkt->get_msg();
         my $s = $generic_pkt->get_src_ip();
         Inet::Table::DEV->enqueue_packet( $streamDev,
            "Ping Reply from $s Turn-arount-time = $t (s)\n" );
      }
      elsif ( $icmp_pkt->get_type() eq "ECHO" ) {
         $icmp_pkt->set_type("REPLY");
         $k = $generic_pkt->get_src_ip();
         $generic_pkt->set_msg( $icmp_pkt->encode() );
         $generic_pkt->set_src_ip( $generic_pkt->get_dest_ip() );
         $generic_pkt->set_dest_ip($k);
         $generic_pkt->set_opcode(1);
         Tosf::Table::MESSAGE->enqueue( "IP", $generic_pkt->encode() );
         Tosf::Table::MESSAGE->signal("IP");
      }
      else {
         #print("unknown ICMP type \n");
      }
      return ( "SOUT" );
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

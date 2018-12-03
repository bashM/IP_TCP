package Inet::Fsm::INCRD;

#================================================================--
# File Name    : Fsm/INCRD.pm
#
# Purpose      : INCRD Controller
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
use constant PORT  => 40;

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
            name => "Fsm::INCRD->new  taskName undefined"
         )
      );
   }

   bless( $self, $class );
   return $self;
}

my $generic_pkt;
my $ethernet_pkt;
my $ip_pkt;
my $udp_pkt;
my $icmp_pkt;
my $raw;
my @keys;
my $k;
my $ns;
my $opcode;

my $self;
my $mmt_taskName;
my $mmt_currentState;

sub tick {
   $self             = shift @_;
   $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "SIN" ) {
      if ( Inet::Collection::FLAG->get_trace() ) {
         print("In INCRD\n");
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
               name => "Fsm::INCRD->new  invalid opcode $opcode"
            )
         );
      }
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "SOUT" ) {
      if ( Inet::Collection::FLAG->get_trace() ) {
         print("Out INCRD\n");
      }

      Tosf::Table::MESSAGE->wait( $self->{taskName} );
      return ( "SIN" );
   }

   if ( $mmt_currentState ~~ "OP0" ) {
      $udp_pkt->decode( generic_pkt->get_msg() );
      $dest_port = $udp_pkt->get_dest_port();
      if ( $est_port == ) {
         Tosf::Table::MESSAGE->enqueue( "INC", $generic_pkt->encode() );
         Tosf::Table::MESSAGE->signal("INC");
      }
      elsif ( dest_port == ) {
         Tosf::Table::MESSAGE->enqueue( "INCD", $generic_pkt->encode() );
         Tosf::Table::MESSAGE->signal("INCD");
      }
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
         #print("unknown INCRD type \n");
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
   $generic_pkt = Inet::Packet::Generic->new();
   $icmp_pkt    = Inet::Packet::Icmp->new();
   $udp_pkt     = Inet::Packet::Udp->new();

   $mmt_taskName = "none";
   return ("SIN");
}

1;

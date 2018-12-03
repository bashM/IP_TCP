package VHost::Fsm::IP;

#================================================================--
# File Name    : Fsm/IP.pm
#
# Purpose      : using IP to pass a packet.
#
# Author       : Basheer, Vancouver Island University
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

   my $self = {
      taskID => my $taskID,
      dcbID  => my $dcbID,
      semID  => my $semID
   };

   if ( defined( $params{taskID} ) ) {
      $self->{taskID} = $params{taskID};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Fsm::IP->new  taskID undefined" )
      );
   }

   if ( defined( $params{dcbID} ) ) {
      $self->{dcbID} = $params{dcbID};
   }
   else {
      die( Tosf::Exception::Trap->new( name => "Fsm::IP->new  dcbID undefined" )
      );
   }

   if ( defined( $params{semID} ) ) {
      $self->{semID} = $params{semID};
   }
   else {
      die( Tosf::Exception::Trap->new( name => "Fsm::IP->new  semID undefined" )
      );
   }

   bless( $self, $class );
   return $self;
}

#my $ETHERNET;
#my $ICMP;
#my $iface;
#my $gateway;
#my $ip;

my %stdioLineParams = (
   maxbuff       => 10000,
   inLeftFrame   => '',
   inRightFrame  => "\n",
   outLeftFrame  => '',
   outRightFrame => "\n"
);

my $pkt;
my $msg_tag;
my $iface;
my $gateway;
my $generic_packet = Inet::Packet::Generic->new();
my $ip_packet      = Inet::Packet::Ip->new();
my $icmp_packet    = Inet::Packet::Icmp->new();

sub tick {
   my $self             = shift @_;
   my $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   my $ns;

   if ( $mmt_currentState ~~ "fetch" ) {
      my $readSuccess;
      if ( Inet::Table::DCB->get_opened( $self->{dcbID} ) ) {
         $pkt = Tosf::Table::QUEUE->dequeue( $self->{taskID} );

         if ( ( defined($pkt) ) ) {
            $readSuccess = TRUE;
            $generic_packet->decode($pkt);

            #$generic_packet->dump();
            $msg_tag = $generic_packet->get_opcode();

            if ( defined($msg_tag) ) {
               if ( $msg_tag eq "ICMP" ) {
                  $ns = "ICMP";
               }
               elsif ( $msg_tag eq "ETHERNET" ) {
                  $ns = "ETHERNET";
               }
            }
         }
         else {
            $readSuccess = FALSE;
            $ns          = "fetch";
            Tosf::Table::SEMAPHORE->wait(
               semaphore => $self->{semID},
               task      => $self->{taskID}
            );
         }
      }
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "ETHERNET" ) {
      $ip_packet->decode( $generic_packet->get_msg() );
      $generic_packet->set_src_ip( $ip_packet->get_src_ip() );
      $generic_packet->set_dest_ip( $ip_packet->get_dest_ip() );
      ( $iface, $gateway ) =
        Inet::Table::ROUTE->get_route( $generic_packet->get_dest_ip() );
      $generic_packet->set_interface($iface);
      $generic_packet->set_gateway($gateway);

      print "here is my i face:: $iface\n";

      # This one is made for the localHost, once the loop back in process.
      if ( defined($iface) ) {

         if ( $ip_packet->get_proto() eq 'ICMP' ) {
            $icmp_packet->decode( $ip_packet->get_msg() );
            $generic_packet->set_opcode("PING");
            $generic_packet->set_msg( $icmp_packet->encode() );

            Inet::Table::DCB->enqueue_packet( "stdio",
               "=-=-=-=-=-=- IN IP GOING TO ICMP -=-=-=-=-=-=",
               %stdioLineParams );

            Tosf::Table::QUEUE->enqueue( 'hIcmp', $generic_packet->encode() );
            Tosf::Table::SEMAPHORE->signal( semaphore => 'icmpSem' );
         }
      }
      return ( "fetch" );
   }

   if ( $mmt_currentState ~~ "ICMP" ) {
      ( $iface, $gateway ) =
        Inet::Table::ROUTE->get_route( $generic_packet->get_dest_ip() );

      $generic_packet->set_interface($iface);
      $generic_packet->set_gateway($gateway);

      if ( defined($iface) && ( $iface ne 'lo' ) ) {
         $ip_packet->set_msg( $generic_packet->get_msg() );
         $ip_packet->set_src_ip( Inet::Table::NIC->get_ip($iface) );
         $ip_packet->set_dest_ip( $generic_packet->get_dest_ip() );
         $ip_packet->set_ttl( $generic_packet->get_ttl() );
         $ip_packet->set_proto('ICMP');

         $generic_packet->set_msg( $ip_packet->encode() );

         if ( Inet::Table::NIC->get_type($iface) eq 'ethernet' ) {
            $generic_packet->set_opcode("NIC");

            Inet::Table::DCB->enqueue_packet( "stdio",
               "=-=-=-=-=-=- IN IP GOING TO ETHERNET -=-=-=-=-=-=",
               %stdioLineParams );

            Tosf::Table::QUEUE->enqueue( 'hEth', $generic_packet->encode() );
            Tosf::Table::SEMAPHORE->signal( semaphore => 'hEthSem' );
         }
         else {
            $generic_packet->set_opcode("NIC");
            ### Coming up soon!!

         }

         # Running back to the localHost.
      }
      elsif ( defined($iface) ) {
         $generic_packet->set_src_ip( $generic_packet->get_dest_ip() );
         $generic_packet->set_opcode("PING");

         Inet::Table::DCB->enqueue_packet( "stdio",
            "=-=-=-=-=-=- IN IP GOING TO ICMP -=-=-=-=-=-=",
            %stdioLineParams );

         Tosf::Table::QUEUE->enqueue( 'hIcmp', $generic_packet->encode() );
         Tosf::Table::SEMAPHORE->signal( semaphore => 'icmpSem' );
      }
      return ( "fetch" );
   }

}

sub reset {
   my $self = shift @_;

   Tosf::Table::SEMAPHORE->wait(
      semaphore => $self->{semID},
      task      => $self->{taskID}
   );

   return ("fetch");
}

1;

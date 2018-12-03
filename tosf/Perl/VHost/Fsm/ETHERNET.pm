package VHost::Fsm::ETHERNET;

#================================================================--
# File Name    : Fsm/ETHERNET.pm
#
# Purpose      : ETHERNET to Nic and IP to pass a packet.
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
         Tosf::Exception::Trap->new(
            name => "Fsm::ETHERNET->new  taskID undefined"
         )
      );
   }

   if ( defined( $params{dcbID} ) ) {
      $self->{dcbID} = $params{dcbID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::ETHERNET->new  dcbID undefined"
         )
      );
   }

   if ( defined( $params{semID} ) ) {
      $self->{semID} = $params{semID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::ETHERNET->new  semID undefined"
         )
      );
   }

   bless( $self, $class );
   return $self;
}

my %stdioLineParams = (
   maxbuff       => 10000,
   inLeftFrame   => '',
   inRightFrame  => "\n",
   outLeftFrame  => '',
   outRightFrame => "\n"
);

my $pkt;
my $msg_tag;
my $generic_packet  = Inet::Packet::Generic->new();
my $ethernet_packet = Inet::Packet::Ethernet->new();
my $ip_packet       = Inet::Packet::Ip->new();

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
            $msg_tag = $generic_packet->get_opcode();
            if ( defined($msg_tag) ) {
               if ( $msg_tag eq "IP" ) {
                  $ns = "IP";
               }
               elsif ( $msg_tag eq "NIC" ) {
                  $ns = "NIC";
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

   if ( $mmt_currentState ~~ "NIC" ) {
      my $dest_mac;
      my $src_mac =
        Inet::Table::NIC->get_mac( $generic_packet->get_interface() );
      my $ip = $generic_packet->get_dest_ip();
      ( my @macs ) = split( /\./, $ip );
      my $mac  = $macs[2];
      my $last = $macs[3];
      $dest_mac = ( $mac * 100 ) + $last;

      $ethernet_packet->set_src_mac($src_mac);
      $ethernet_packet->set_dest_mac($dest_mac);
      $ethernet_packet->set_proto('IP');
      $ethernet_packet->set_msg( $generic_packet->get_msg() );

      Inet::Table::DCB->enqueue_packet( "stdio",
         "=-=-=-=-=-=- IN ETHERNET GOING TO NIC -=-=-=-=-=-=",
         %stdioLineParams );
      Inet::Table::DCB->enqueue_packet( "p", $ethernet_packet->encode() );
      return ( "fetch" );
   }

   if ( $mmt_currentState ~~ "IP" ) {
      $generic_packet->set_interface("eth0");
      $ethernet_packet->decode( $generic_packet->get_msg() );
      my $my_mac =
        Inet::Table::NIC->get_mac( $generic_packet->get_interface() );
      my $in_mac = $ethernet_packet->get_dest_mac();

      print "this is my mac: $my_mac\n and this is my in mac: $in_mac\n";
      if ( $in_mac eq $my_mac ) {
         if ( $ethernet_packet->get_proto() eq 'IP' ) {
            $ip_packet->decode( $ethernet_packet->get_msg() );
            $generic_packet->set_msg( $ip_packet->encode() );
            $generic_packet->set_opcode("ETHERNET");

            Inet::Table::DCB->enqueue_packet( "stdio",
               "=-=-=-=-=-=- IN ETHERNET GOING TO IP -=-=-=-=-=-=",
               %stdioLineParams );

            Tosf::Table::QUEUE->enqueue( 'hIp', $generic_packet->encode() );
            Tosf::Table::SEMAPHORE->signal( semaphore => 'ipSem' );
         }
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

package VHost::Fsm::ICMP;

#================================================================--
# File Name    : VHost/Fsm/PING.pm
#
# Purpose      : ICMP.pm
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
            name => "Fsm::ICMP->new  taskID undefined"
         )
      );
   }

   if ( defined( $params{dcbID} ) ) {
      $self->{dcbID} = $params{dcbID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::ICMP->new  dcbID undefined"
         )
      );
   }

   if ( defined( $params{semID} ) ) {
      $self->{semID} = $params{semID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::ICMP->new  semID undefined"
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
my $generic_packet = Inet::Packet::Generic->new();
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
               if ( $msg_tag eq "IP" ) {
                  $ns = "IP";
               }
               elsif ( ( $msg_tag eq "PING" ) || ( $msg_tag eq "PINGD" ) ) {
                  $ns = "PING_OR_PINGD";
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

   if ( $mmt_currentState ~~ "IP" ) {
      ( my $ty, my $ts ) = split( ':', $generic_packet->get_msg() );
      $icmp_packet->set_type($ty);
      $icmp_packet->set_msg($ts);

      $generic_packet->set_msg( $icmp_packet->encode() );
      $generic_packet->set_opcode("ICMP");

      Inet::Table::DCB->enqueue_packet( "stdio",
         "=-=-=-=-=-=- IN ICMP GOING TO IP -=-=-=-=-=-=",
         %stdioLineParams );

      Tosf::Table::QUEUE->enqueue( 'hIp', $generic_packet->encode() );
      Tosf::Table::SEMAPHORE->signal( semaphore => 'ipSem' );
      return ( "fetch" );
   }

   if ( $mmt_currentState ~~ "PING_OR_PINGD" ) {
      $icmp_packet->decode( $generic_packet->get_msg() );

      if ( $icmp_packet->get_type() eq "ECHO" ) {

         $generic_packet->set_msg(
            join( ':',
               @{ [ $icmp_packet->get_type(), $icmp_packet->get_msg() ] } )
         );
         $generic_packet->set_opcode("ICMP");

         Inet::Table::DCB->enqueue_packet( "stdio",
            "=-=-=-=-=-=- IN ICMP GOING TO PINGD -=-=-=-=-=-=",
            %stdioLineParams );

         Tosf::Table::QUEUE->enqueue( 'hPingd', $generic_packet->encode() );
         Tosf::Table::SEMAPHORE->signal( semaphore => 'PingdSem' );

      }
      elsif ( $icmp_packet->get_type() eq "ECHO_REPLY" ) {
         $generic_packet->set_msg(
            join( ':',
               @{ [ $icmp_packet->get_type(), $icmp_packet->get_msg() ] } )
         );
         $generic_packet->set_opcode("SIC");

         Inet::Table::DCB->enqueue_packet( "stdio",
            "=-=-=-=-=-=- IN ICMP GOING TO PING -=-=-=-=-=-=",
            %stdioLineParams );

         Tosf::Table::QUEUE->enqueue( 'hPing', $generic_packet->encode() );
         Tosf::Table::SEMAPHORE->signal( semaphore => 'pingSem' );
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

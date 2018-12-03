package VHost::Fsm::PINGD;

#================================================================--
# File Name    : Fsm/Pingd.pm
#
# Purpose      : pingd file
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
            name => "Fsm::Sic->new  taskID undefined"
         )
      );
   }

   if ( defined( $params{dcbID} ) ) {
      $self->{dcbID} = $params{dcbID};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Fsm::Sic->new  dcbID undefined" )
      );
   }

   if ( defined( $params{semID} ) ) {
      $self->{semID} = $params{semID};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Fsm::Sic->new  semID undefined" )
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
my $ICMP;
my $pkt;
my $msg_tag;
my $generic_packet = Inet::Packet::Generic->new();

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
               if ( $msg_tag eq "ICMP" ) {
                  $ns = "ICMP";
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

   if ( $mmt_currentState ~~ "ICMP" ) {
      ( my $ty, my $ts ) = split( ':', $generic_packet->get_msg() );
      $generic_packet->set_msg( join( ':', @{ [ "ECHO_REPLY", $ts ] } ) );
      $generic_packet->set_dest_ip( $generic_packet->get_src_ip() );

      $generic_packet->set_opcode("IP");

      Inet::Table::DCB->enqueue_packet( "stdio",
         "=-=-=-=-=-=- IN PINGD GOING TO ICMP -=-=-=-=-=-=",
         %stdioLineParams );

      Tosf::Table::QUEUE->enqueue( 'hIcmp', $generic_packet->encode() );
      Tosf::Table::SEMAPHORE->signal( semaphore => 'icmpSem' );
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

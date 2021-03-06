package VHost::Fsm::Nic;

#================================================================--
# File Name    : Fsm/Nic.pm
#
# Purpose      : network Interface Controller
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
            name => "Fsm::Nic->new  taskID undefined"
         )
      );
   }

   if ( defined( $params{dcbID} ) ) {
      $self->{dcbID} = $params{dcbID};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Fsm::Nic->new  dcbID undefined" )
      );
   }

   if ( defined( $params{semID} ) ) {
      $self->{semID} = $params{semID};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Fsm::Nic->new  semID undefined" )
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

   # my $pkt;
   my @keys;
   my $k;
   my $readSuccess;

   if ( $mmt_currentState ~~ "S0" ) {
      $readSuccess = FALSE;
      if ( Inet::Table::DCB->get_opened( $self->{dcbID} ) ) {
         $pkt = Inet::Table::DCB->dequeue_packet( $self->{dcbID} );

         if ( ( defined($pkt) ) && ( length($pkt) != 0 ) ) {
            $readSuccess = TRUE;

            if ( $pkt ne "heartbeat" ) {
               ( my $iface, my $gateway ) = Inet::Table::ROUTE->get_route(
                  $generic_packet->get_dest_ip() );
               if ( Inet::Table::NIC->get_type($iface) eq 'ethernet' ) {

                  #my $msg = $gen->get_msg();
                  #print "msg in nic is $msg\n";
                  #$ethernet_packet->decode($pkt);
                  #$ethernet_packet->set_msg($gen->get_msg());
                  #$generic_packet->set_interface("eth0");
                  $generic_packet->set_msg($pkt);
                  $generic_packet->set_opcode("IP");

                  Inet::Table::DCB->enqueue_packet( "stdio",
                     "=-=-=-=-=-=- IN NIC GOING TO ETHERNET -=-=-=-=-=-=",
                     %stdioLineParams );

                  Tosf::Table::QUEUE->enqueue( 'hEth',
                     $generic_packet->encode() );
                  Tosf::Table::SEMAPHORE->signal( semaphore => 'hEthSem' );
               }
            }

            Inet::Table::DCB->enqueue_packet( "stdio",
               "RAW FROM Socket " . $pkt,
               %stdioLineParams );
         }

      }
      if ( !$readSuccess ) {
         Tosf::Table::SEMAPHORE->wait(
            semaphore => $self->{semID},
            task      => $self->{taskID}
         );
      }
      return ( "S0" );
   }

}

sub reset {
   my $self = shift @_;

   Tosf::Table::SEMAPHORE->wait(
      semaphore => $self->{semID},
      task      => $self->{taskID}
   );

   return ("S0");
}

1;

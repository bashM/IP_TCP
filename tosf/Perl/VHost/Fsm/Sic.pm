package VHost::Fsm::Sic;

#================================================================--
# File Name    : Fsm/Sic.pm
#
# Purpose      : stream Interface Controller
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

sub tick {
   my $self             = shift @_;
   my $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   my $pkt;
   my $helpMsg =
"COMMAND\t\t\t\tBEHAVIOUR\nhelp\t\t\t\tdisplay help message \nquit\t\t\t\tshutdown\nsystem\t\t\t\tdisplay system information\nping ip[:ttl]\t\t\tping\n";

   my @keys;
   my $k;
   my $readSuccess;
   my $generic_packet = Inet::Packet::Generic->new();

   my %stdioLineParams = (
      maxbuff       => 10000,
      inLeftFrame   => '',
      inRightFrame  => "\n",
      outLeftFrame  => '',
      outRightFrame => "\n"
   );

   if ( $mmt_currentState ~~ "S0" ) {
      $readSuccess = FALSE;
      if ( Inet::Table::DCB->get_opened( $self->{dcbID} ) ) {
         $pkt = Inet::Table::DCB->dequeue_packet( $self->{dcbID} );

         if ( defined($pkt) ) {
            $readSuccess = TRUE;
            ( my $msg, my $p_Ip ) = split( ' ', $pkt );
            if ( length($pkt) == 0 ) {
               Inet::Table::DCB->enqueue_packet( $self->{dcbID}, " " );
            }
            elsif ( $pkt eq 'help' ) {
               Inet::Table::DCB->enqueue_packet( $self->{dcbID}, $helpMsg );
            }
            elsif ( $msg eq 'ping' ) {

               Inet::Table::DCB->enqueue_packet( $self->{dcbID},
                  "ping: $p_Ip" );
               $generic_packet->set_opcode("ICMP");
               $generic_packet->set_msg($p_Ip);

               #$generic_packet->dump();

               Inet::Table::DCB->enqueue_packet( "stdio",
                  "=-=-=-=-=-=- IN SIC GOING TO PING -=-=-=-=-=-=",
                  %stdioLineParams );

               Tosf::Table::QUEUE->enqueue( 'hPing',
                  $generic_packet->encode() );
               Tosf::Table::SEMAPHORE->signal( semaphore => 'pingSem' );
            }
            elsif ( $pkt eq 'system' ) {
               my $h = VHost::Collection::HOST->get_host();
               my $p = VHost::Collection::HOST->get_port();
               Inet::Table::DCB->enqueue_packet( $self->{dcbID},
                  "system: $h:$p" );
            }
            elsif ( $pkt eq 'quit' ) {
               main::leaveScript();
            }
            else {
               Inet::Table::DCB->enqueue_packet( $self->{dcbID},
                  "invalid command: type help for command information" );
            }
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

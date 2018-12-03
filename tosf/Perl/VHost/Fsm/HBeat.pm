package VHost::Fsm::HBeat;

#================================================================--
# File Name    : Fsm/HBeat.pm
#
# Purpose      : implements task HBeat (heartbeat)
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

sub new {
   my $class  = shift @_;
   my %params = @_;

   my $self = {
      taskID => my $taskID,
      dcbID  => my $dcbID
   };

   if ( defined( $params{taskID} ) ) {
      $self->{taskID} = $params{taskID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::HBeat->new  taskID undefined"
         )
      );
   }

   if ( defined( $params{dcbID} ) ) {
      $self->{dcbID} = $params{dcbID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::HBeat->new  dcbID undefined"
         )
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
   my @keys;
   my $k;

   if ( $mmt_currentState ~~ "S0" ) {
      if ( Inet::Table::DCB->get_opened( $self->{dcbID} ) ) {
         $pkt = "heartbeat";
         Inet::Table::DCB->enqueue_packet( $self->{dcbID}, $pkt );
      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( "S0" );
   }

}

sub reset {
   my $self = shift @_;

   return ("S0");
}

1;

package Switch::Fsm::HBeat;

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
      nicID  => my $nicID
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

   if ( defined( $params{nicID} ) ) {
      $self->{nicID} = $params{nicID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::HBeat->new  nicID undefined"
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
      if ( Switch::Table::NIC->get_open( $self->{nicID} ) ) {
         $pkt = "heartbeat";
         Switch::Table::NIC->enqueue_packet( $self->{nicID}, $pkt );
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

package Switch::Fsm::VST;

#================================================================--
# File Name    : Fsm/SVT.pm
#
# Purpose      : implements task VST (swtich timer)
#
# Author       : Peter Walsh, Vancouver Island University
#
# Added by     : Alwaleed (Welly) Alqufaydi
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

#my $timer = 20;

sub new {
   my $class  = shift @_;
   my %params = @_;

   my $self = {
      taskID => my $taskID,
      nicID  => my $nicID,
      timer  => my $timer,
   };

   if ( defined( $params{taskID} ) ) {
      $self->{taskID} = $params{taskID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::VST->new  taskID undefined"
         )
      );
   }

   if ( defined( $params{nicID} ) ) {
      $self->{nicID} = $params{nicID};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Fsm::VST->new  nicID undefined" )
      );
   }
   if ( defined( $params{timer} ) ) {
      $self->{timer} = $params{timer};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Fsm::VST->new  timer undefined" )
      );
   }

   bless( $self, $class );
   return $self;
}

sub tick {
   my $self             = shift @_;
   my $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   my @keys;
   my $k;

   if ( $mmt_currentState ~~ "S0" ) {
      if ( Switch::Table::NIC->get_open( $self->{nicID} ) ) {

         $k = Switch::Table::NIC->get_time( $self->{nicID} );
         if ( ( defined($k) ) ) {

            $k--;

            #Switch::Table::NIC->enqueue_packet($self->{nicID},$k);
            Switch::Table::NIC->set_time( $self->{nicID}, $k );

            if ( $k eq 0 ) {
               Switch::Table::NIC->set_time( $self->{nicID}, $k );
               Switch::Table::NIC->remove( $self->{nicID} );
            }
         }
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

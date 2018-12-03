package Tosf::Fsm::ATo;

#================================================================--
# File Name    : Fsm/ATo.pm
#
# Purpose      : implements asynchronous timeout task To
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
      sv     => my $sv
   };

   if ( defined( $params{taskID} ) ) {
      $self->{taskID} = $params{taskID};
   }
   else {
      die( Tosf::Exception::Trap->new( name => "Task::ATo taskID undefined" ) );
   }

   if ( defined( $params{sv} ) ) {
      $self->{sv} = $params{sv};
   }
   else {
      die( Tosf::Exception::Trap->new( name => "Task::ATo sv undefined" ) );
   }

   bless( $self, $class );
   return $self;
}

sub tick {
   my $self             = shift @_;
   my $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "S1" ) {
      if ( $self->{sv} eq "p4ToSv" ) {
         print("Setting p4 sv \n");
      }

      Tosf::Table::SVAR->assign( $self->{sv}, 1 );
      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( "S2" );
   }

   if ( $mmt_currentState ~~ "S2" ) {
      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( "S2" );
   }

}

sub reset {
   my $self = shift @_;

   Tosf::Table::TASK->clear_elapsedTime( $self->{taskID} );
   Tosf::Table::SVAR->assign( $self->{sv}, 0 );
   return ("S1");
}

1;

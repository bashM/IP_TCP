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
      taskName  => my $taskName,
      timeoutSv => my $timeoutSv
   };

   if ( defined( $params{taskName} ) ) {
      $self->{taskName} = $params{taskName};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Task::ATo taskName undefined" ) );
   }

   if ( defined( $params{timeoutSv} ) ) {
      $self->{timeoutSv} = $params{timeoutSv};
   }
   else {
      die( Tosf::Exception::Trap->new( name => "Task::ATo timeoutSv undefined" )
      );
   }

   bless( $self, $class );
   return $self;
}

my $self;
my $mmt_taskName;
my $mmt_currentState;

sub tick {
   $self             = shift @_;
   $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "S1" ) {
      Tosf::Table::SVAR->assign( $self->{timeoutSv}, 1 );
      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( "S2" );
   }

   if ( $mmt_currentState ~~ "S2" ) {
      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( "S2" );
   }

   die( Tosf::Exception::Trap->new( name => "Tosf:Mmt  no such state" ) );
}

sub whoami {

   if ( $mmt_taskName eq "none" ) {
      die(
         Tosf::Exception::Trap->new(
            name => "Tosf:Mmt  whoami can only be called from reset"
         )
      );
   }

   return $mmt_taskName;
}

sub reset {
   $self         = shift @_;
   $mmt_taskName = shift @_;
   no warnings "experimental::smartmatch";

   Tosf::Table::TASK->clear_elapsedTime( $self->{taskName} );
   Tosf::Table::SVAR->assign( $self->{timeoutSv}, 0 );
   $mmt_taskName = "none";
   return ("S1");
}

1;

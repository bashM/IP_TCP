package Tosf::Fsm::To;

#================================================================--
# File Name    : Fsm/To.pm
#
# Purpose      : implements timeout task To
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
      name    => my $name,
      count   => my $count,
      timeOut => my $timeOut,
      svName  => my $svName
   };

   if ( defined( $params{name} ) ) {
      $self->{name} = $params{name};
   }
   else {
      die( Tosf::Exception::Trap->new( name => "Task::To name undefined" ) );
   }

   if ( defined( $params{svName} ) ) {
      $self->{svName} = $params{svName};
   }
   else {
      die( Tosf::Exception::Trap->new( name => "Task::To svName undefined" ) );
   }

   if ( defined( $params{timeOut} ) ) {
      $self->{timeOut} = $params{timeOut};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Task::To timeout  undefined" ) );
   }

   bless( $self, $class );
   return $self;
}

sub nextState {
   my $c = shift @_;
   my $t = shift @_;

   if ( $c == $t ) {
      return ("S2");
   }

   return ("S1");
}

sub tick {
   my $self             = shift @_;
   my $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "S1" ) {
      $self->{count} = $self->{count} + 1;
      Tosf::Table::TASK->suspend( $self->{name} );
      return ( nextState( $self->{count}, $self->{timeOut} ) );
   }

   if ( $mmt_currentState ~~ "S2" ) {
      Tosf::Table::SVAR->assign( $self->{svName}, 1 );
      Tosf::Table::TASK->suspend( $self->{name} );
      return ( "S3" );
   }

   if ( $mmt_currentState ~~ "S3" ) {
      Tosf::Table::TASK->suspend( $self->{name} );
      return ( "S3" );
   }

}

sub reset {
   my $self = shift @_;

   $self->{count} = 0;
   Tosf::Table::SVAR->change( $self->{svName}, 0 );
   return ("S1");
}

1;

package Inet::Fsm::MACT;

#================================================================--
# File Name    : Fsm/HBEAT.pm
#
# Purpose      : implements task HBEAT (heartbeat)
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

   my $self = { taskName => my $taskName };

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

   if ( $mmt_currentState ~~ "S0" ) {
      Inet::Table::MAC->ticks();
      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( "S0" );
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

   $self->{taskName} = whoami();

   $mmt_taskName = "none";
   return ("S0");
}

1;

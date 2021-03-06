package VHub::Fsm::Nic;

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

sub tick {
   my $self             = shift @_;
   my $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   my $pkt;
   my @keys;
   my $k;
   my $readSuccess;

   if ( $mmt_currentState ~~ "S0" ) {
      $readSuccess = FALSE;
      if ( Inet::Table::DCB->get_opened( $self->{dcbID} ) ) {
         $pkt = Inet::Table::DCB->dequeue_packet( $self->{dcbID} );
         if (  ( defined($pkt) )
            && ( length($pkt) != 0 )
            && ( !( $pkt eq "heartbeat" ) ) )
         {
            $readSuccess = TRUE;
            @keys        = Inet::Table::DCB->get_keys();
            foreach $k (@keys) {

               # write to open ports except for the port the packet came in on
               if (  ( $k ne $self->{dcbID} )
                  && ( Inet::Table::DCB->get_opened($k) ) )
               {
                  Inet::Table::DCB->enqueue_packet( $k, $pkt );

                  #print("Open Nics $k \n");
               }
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

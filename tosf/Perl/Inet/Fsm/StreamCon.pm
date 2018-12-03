package Inet::Fsm::StreamCon;

#================================================================--
# File Name    : Fsm/StreamCon.pm
#
# Purpose      : implements task stream controller (stdin, stdout)
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant MAXLEN => 100;
use constant FALSE  => 0;
use constant TRUE   => 1;

sub new {
   my $class  = shift @_;
   my %params = @_;

   my $self = {
      taskID => my $taskID,
      dcbID  => my $dcbID,
      semID  => my $semID,
      select => my $select = IO::Select->new()
   };

   if ( defined( $params{taskID} ) ) {
      $self->{taskID} = $params{taskID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConC->new  taskID undefined"
         )
      );
   }

   if ( defined( $params{dcbID} ) ) {
      $self->{dcbID} = $params{dcbID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConC->new  dcbID undefined"
         )
      );
   }

   if ( defined( $params{semID} ) ) {
      $self->{semID} = $params{semID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConC->new  semID undefined"
         )
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
   outRightFrame => "\n> "
);

sub tick {
   my $self             = shift @_;
   my $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   my $buff;
   my $dcb;
   my @clients;

   if ( $mmt_currentState ~~ "READ" ) {
      undef($buff);
      @clients = ( $self->{select} )->can_read(0);
      foreach my $fh (@clients) {
         if ( $fh == \*STDIN ) {
            $buff = <>;
         }
      }

      if ( ( defined($buff) ) && ( length($buff) != 0 ) ) {
         Inet::Table::DCB->enqueue_packet_fragment( $self->{dcbID}, $buff );
         Tosf::Table::SEMAPHORE->signal( semaphore => $self->{semID} );
      }
      return ( "WRITE" );
   }

   if ( $mmt_currentState ~~ "WRITE" ) {
      $buff = Inet::Table::DCB->dequeue_packet_fragment( $self->{dcbID} );
      if ( defined($buff) ) {
         print($buff);
      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( "READ" );
   }

   if ( $mmt_currentState ~~ "OPEN" ) {
      Inet::Table::DCB->flush( $self->{dcbID} );
      Inet::Table::DCB->set_opened( $self->{dcbID}, FALSE );

      # assume stdin / stdout are open
      Inet::Table::DCB->set_opened( $self->{dcbID}, TRUE );
      $self->{select}->add( \*STDIN );

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( "READ" );
   }

}

sub reset {
   my $self = shift @_;

   Inet::Table::DCB->add( $self->{dcbID}, %stdioLineParams );

   return ("OPEN");
}

1;

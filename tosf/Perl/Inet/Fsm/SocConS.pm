package Inet::Fsm::SocConS;

#================================================================--
# File Name    : Fsm/SocConS.pm
#
# Purpose      : implements socket controller (server)
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
      taskID      => my $taskID,
      timeoutSv   => my $timeoutSv,
      timeoutTask => my $timeoutTask,
      port        => my $port,
      soc         => my $soc,
      newSoc      => my $newSoc,
      dcbID       => my $dcbID,
      semID       => my $semID,
      select      => my $select = IO::Select->new()
   };

   $self->{soc}    = undef;
   $self->{newSoc} = undef;

   if ( defined( $params{taskID} ) ) {
      $self->{taskID} = $params{taskID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConS->new  taskID undefined"
         )
      );
   }

   if ( defined( $params{timeoutSv} ) ) {
      $self->{timeoutSv} = $params{timeoutSv};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConS->new  timeoutSv undefined"
         )
      );
   }

   if ( defined( $params{timeoutTask} ) ) {
      $self->{timeoutTask} = $params{timeoutTask};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConS->new  timeoutTask undefined"
         )
      );
   }

   if ( defined( $params{port} ) ) {
      $self->{port} = $params{port};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConS->new  port undefined"
         )
      );
   }

   if ( defined( $params{dcbID} ) ) {
      $self->{dcbID} = $params{dcbID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConS->new  dcbID undefined"
         )
      );
   }

   if ( defined( $params{semID} ) ) {
      $self->{semID} = $params{semID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConS->new  semID undefined"
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

   my $buff;
   my $ns;
   my $to;
   my $dcb = $self->{dcbID};
   my $sel = IO::Select->new( $self->{soc} );
   my @clients;

   if ( $mmt_currentState ~~ "READ" ) {
      undef($buff);
      @clients = ( $self->{select} )->can_read(0);
      foreach my $fh (@clients) {
         if ( $fh == $self->{newSoc} ) {
            $self->{newSoc}->recv( $buff, MAXLEN );

         }
      }

      if ( ( defined($buff) ) && ( length($buff) != 0 ) ) {
         Tosf::Table::TASK->reset( $self->{timeoutTask} );
         Inet::Table::DCB->enqueue_packet_fragment( $self->{dcbID}, $buff );
         Tosf::Table::SEMAPHORE->signal( semaphore => $self->{semID} );
      }
      return ( "WRITE" );
   }

   if ( $mmt_currentState ~~ "WRITE" ) {
      $buff = Inet::Table::DCB->dequeue_packet_fragment( $self->{dcbID} );
      if ( defined($buff) && ( defined $self->{newSoc} ) ) {
         $self->{newSoc}->write($buff);
      }
      return ( "TOCHECK" );
   }

   if ( $mmt_currentState ~~ "TOCHECK" ) {
      $to = Tosf::Table::SVAR->get_value( $self->{timeoutSv} );
      if ( defined( $self->{newSoc} ) && ( !$to ) ) {
         $ns = "READ";
      }
      else {
         $ns = "ACCEPT";
         print("Resetting socket $dcb \n");

      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "ACCEPT" ) {
      if ( defined( $self->{newSoc} ) ) {
         if ( $self->{select}->exists( $self->{newSoc} ) ) {
            ( $self->{select} )->remove( $self->{newSoc} );
            print("Removed reference to socket $dcb from select \n");
         }
         print("Closing socket $dcb \n");

         close( $self->{newSoc} );
      }

      $self->{newSoc} = undef;

      Inet::Table::DCB->flush( $self->{dcbID} );
      Inet::Table::DCB->set_opened( $self->{dcbID}, FALSE );

      @clients = ( $self->{select} )->can_read(0);
      foreach my $fh (@clients) {
         if ( $fh == $self->{soc} ) {
            $self->{newSoc} = $self->{soc}->accept();
            $self->{select}->add( $self->{newSoc} );
         }
      }
      if ( defined( $self->{newSoc} ) ) {
         $ns = "READ";
         Tosf::Table::TASK->reset( $self->{timeoutTask} );
         Inet::Table::DCB->set_opened( $self->{dcbID}, TRUE );
         $dcb = $self->{dcbID};
         print("Accepted connection on socket $dcb \n");
      }
      else {
         $ns = "ACCEPT";
      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "OPEN" ) {
      undef( $self->{soc} );
      my $p = $self->{port};
      $dcb = $self->{dcbID};
      print("Try to open  socket $dcb at host localhost / port $p \n");
      $self->{soc} = new IO::Socket::INET(
         LocalHost => '',
         LocalPort => $self->{port},
         Proto     => 'tcp',
         Reuse     => 1,
         Listen    => 0,
         Timeout   => 0.0001,
         Blocking  => 0
      );

      if ( !defined( $self->{soc} ) ) {
         print("Failed to open socket $dcb \n");
         die(
            Tosf::Exception::Trap->new(
               name => "Fsm::SocConS OPEN socket undefined"
            )
         );
      }
      else {
         print("Opened VHub port $dcb at host localhost / port $p\n");
         $self->{select}->add( $self->{soc} );
      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( "ACCEPT" );
   }

}

sub reset {
   my $self = shift @_;

   return ("OPEN");
}

1;

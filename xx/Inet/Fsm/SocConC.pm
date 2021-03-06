package Inet::Fsm::SocConC;

#================================================================--
# File Name    : Fsm/SocConC.pm
#
# Purpose      : implements task socket controller (client)
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
      host        => my $host,
      soc         => my $soc,
      dcbID       => my $dcbID,
      semID       => my $semID,
      select      => my $select = IO::Select->new()
   };

   $self->{soc} = undef;

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

   if ( defined( $params{timeoutSv} ) ) {
      $self->{timeoutSv} = $params{timeoutSv};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConC->new  timeoutSv undefined"
         )
      );
   }

   if ( defined( $params{timeoutTask} ) ) {
      $self->{timeoutTask} = $params{timeoutTask};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConC->new  timeoutTask undefined"
         )
      );
   }

   if ( defined( $params{port} ) ) {
      $self->{port} = $params{port};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConC->new  port undefined"
         )
      );
   }

   if ( defined( $params{host} ) ) {
      $self->{host} = $params{host};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConC->new  host undefined"
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

sub tick {
   my $self             = shift @_;
   my $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   my $buff;
   my $ns;
   my $to;
   my $dcb = $self->{dcbID};
   my @clients;

   if ( $mmt_currentState ~~ "READ" ) {
      undef($buff);
      @clients = ( $self->{select} )->can_read(0);
      foreach my $fh (@clients) {
         if ( $fh == $self->{soc} ) {
            $self->{soc}->recv( $buff, MAXLEN );

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
      if ( defined($buff) && ( defined( $self->{soc} ) ) ) {
         $self->{soc}->write($buff);
      }
      return ( "TOCHECK" );
   }

   if ( $mmt_currentState ~~ "TOCHECK" ) {
      $to = Tosf::Table::SVAR->get_value( $self->{timeoutSv} );
      if ( defined( $self->{soc} ) && ( !$to ) ) {
         $ns = "READ";
      }
      else {
         $ns = "WAIT";
         print("Resetting socket $dcb \n");
         Tosf::Table::TASK->reset( $self->{timeoutTask} );
      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "WAIT" ) {
      $to = Tosf::Table::SVAR->get_value( $self->{timeoutSv} );

      if ($to) {
         $ns = "OPEN";
      }
      else {
         $ns = "WAIT";
      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "OPEN" ) {
      if ( defined( $self->{soc} ) ) {
         if ( $self->{select}->exists( $self->{soc} ) ) {
            ( $self->{select} )->remove( $self->{soc} );
            print("Removed reference to socket $dcb from select \n");
         }
         print("Closing socket $dcb \n");
         close( $self->{soc} );
      }

      $self->{soc} = undef;

      Inet::Table::DCB->flush( $self->{dcbID} );
      Inet::Table::DCB->set_opened( $self->{dcbID}, FALSE );

      my $p = $self->{port};
      my $h = $self->{host};
      $dcb = $self->{dcbID};

      print("Try to open  socket $dcb at host $h / port $p\n");
      $self->{soc} = new IO::Socket::INET(
         PeerAddr => $self->{host},
         PeerPort => $self->{port},
         Proto    => 'tcp',
         Timeout  => 00001,
         Blocking => 0
      );

      if ( !defined( $self->{soc} ) ) {
         print("Failed to open socket $dcb \n");
         $ns = "WAIT";
      }
      else {
         print("Opened socket $dcb at host $h / port $p\n");
         $self->{select}->add( $self->{soc} );
         Inet::Table::DCB->set_opened( $self->{dcbID}, TRUE );
         $ns = "READ";
      }

      Tosf::Table::TASK->reset( $self->{timeoutTask} );
      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( $ns );
   }

}

sub reset {
   my $self = shift @_;

   return ("OPEN");
}

1;

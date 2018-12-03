package Switch::Fsm::Nic;

#================================================================--
# File Name    : Fsm/Nic.pm
#
# Purpose      : implements task Nic
#                (socket network interface controller)
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
use constant CLOSED => 0;
use constant OPENED => 1;

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
      nicID       => my $nicID,
      select      => my $select
   };

   $self->{soc}    = undef;
   $self->{newSoc} = undef;

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

   if ( defined( $params{timeoutSv} ) ) {
      $self->{timeoutSv} = $params{timeoutSv};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::Nic->new  timeoutSv undefined"
         )
      );
   }

   if ( defined( $params{timeoutTask} ) ) {
      $self->{timeoutTask} = $params{timeoutTask};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::Nic->new  timeoutTask undefined"
         )
      );
   }

   if ( defined( $params{port} ) ) {
      $self->{port} = $params{port};
   }
   else {
      die( Tosf::Exception::Trap->new( name => "Fsm::Nic->new  port undefined" )
      );
   }

   if ( defined( $params{nicID} ) ) {
      $self->{nicID} = $params{nicID};
   }
   else {
      die(
         Tosf::Exception::Trap->new( name => "Fsm::Nic->new  nicID undefined" )
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
   my $sel = IO::Select->new( $self->{soc} );
   my @clients;

   if ( $mmt_currentState ~~ "RW" ) {
      @clients = ( $self->{select} )->can_read(0);
      foreach my $fh (@clients) {
         if ( $fh == $self->{newSoc} ) {
            $self->{newSoc}->recv( $buff, MAXLEN );

         }
      }

      if ( ( defined($buff) ) && ( length($buff) != 0 ) ) {
         Tosf::Table::TASK->reset( $self->{timeoutTask} );
         Switch::Table::NIC->enqueue_packet_fragment( $self->{nicID}, $buff );
      }

      $buff = Switch::Table::NIC->dequeue_packet_fragment( $self->{nicID} );
      if ( defined($buff) ) {
         $self->{newSoc}->write($buff);
      }

      $to = Tosf::Table::SVAR->get_value( $self->{timeoutSv} );
      if ( defined( $self->{newSoc} ) && ( !$to ) ) {
         $ns = "RW";
      }
      else {
         $ns = "ACCEPT";
         my $nid = $self->{nicID};
         print("Resetting connection on Switch port $nid \n");
      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "ACCEPT" ) {
      $self->{newSoc} = undef;
      Switch::Table::NIC->flush( $self->{nicID} );
      Switch::Table::NIC->set_open( $self->{nicID}, CLOSED );
      if ( defined( $self->{newSoc} ) ) {
         ( $self->{select} )->delete( $self->{newSoc} );
      }

      @clients = ( $self->{select} )->can_read(0);
      foreach my $fh (@clients) {
         if ( $fh == $self->{soc} ) {
            $self->{newSoc} = $self->{soc}->accept();
            $self->{select}->add( $self->{newSoc} );
         }
      }
      if ( defined( $self->{newSoc} ) ) {
         $ns = "RW";
         Tosf::Table::TASK->reset( $self->{timeoutTask} );
         Switch::Table::NIC->set_open( $self->{nicID}, OPENED );
         my $nid = $self->{nicID};
         print("Accepted connection on Switch port $nid \n");
      }
      else {
         $ns = "ACCEPT";
      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "OPEN" ) {
      undef( $self->{soc} );
      my $p   = $self->{port};
      my $nid = $self->{nicID};
      print("Try to open Switch port $nid at Internet port $p\n");
      $self->{soc} = new IO::Socket::INET(
         LocalHost => '',
         LocalPort => $self->{port},
         Proto     => 'tcp',
         Reuse     => 1,
         Listen    => 0,
         Timeout   => 0.001,
         Blocking  => 0
      );

      if ( !defined( $self->{soc} ) ) {
         print("Failed to open\n");
         die(
            Tosf::Exception::Trap->new(
               name => "Fsm::Nic OPEN socket undefined"
            )
         );
      }
      else {
         print("Opened Switch port $nid at Internet port $p\n");
         $self->{select} = IO::Select->new( $self->{soc} );
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

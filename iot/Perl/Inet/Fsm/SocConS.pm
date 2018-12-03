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
use constant MAXTO  => 500;
use constant FALSE  => 0;
use constant TRUE   => 1;

sub new {
   my $class  = shift @_;
   my %params = @_;

   my $self = {
      taskName    => my $taskName,
      iface       => my $iface,
      handlerName => my $handlerName,
      port        => my $port,
      soc         => my $soc,
      newSoc      => my $newSoc,
      select      => my $select = IO::Select->new(),
      timeout     => my $timeout
   };

   $self->{soc}     = undef;
   $self->{newSoc}  = undef;
   $self->{timeout} = MAXTO;

   if ( defined( $params{handlerName} ) ) {
      $self->{handlerName} = $params{handlerName};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConS->new  handlerName undefined"
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

   if ( defined( $params{iface} ) ) {
      $self->{iface} = $params{iface};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConS->new  iface undefined"
         )
      );
   }

   bless( $self, $class );
   return $self;
}

my $buff;
my $ns;
my $gpkt;
my @clients;

my $self;
my $mmt_taskName;
my $mmt_currentState;

sub tick {
   $self             = shift @_;
   $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "READ" ) {
      if ( $self->{timeout} != 0 ) {
         $self->{timeout} = $self->{timeout} - 1;
      }

      undef($buff);
      @clients = ( $self->{select} )->can_read(0);
      foreach my $fh (@clients) {
         if ( $fh == $self->{newSoc} ) {
            $self->{newSoc}->recv( $buff, MAXLEN );

         }
      }

      if ( ( defined($buff) ) && ( length($buff) != 0 ) ) {
         Inet::Table::IFACE->enqueue_packet_fragment( $self->{iface}, $buff );
         $self->{timeout} = MAXTO;
         $gpkt->set_opcode(2);
         $gpkt->set_msg( $self->{iface} );
         Tosf::Table::MESSAGE->enqueue( $self->{handlerName}, $gpkt->encode() );

         #Tosf::Table::MESSAGE->enqueue($self->{handlerName}, $self->{iface});
         Tosf::Table::MESSAGE->signal( $self->{handlerName} );

      }
      return ( "WRITE" );
   }

   if ( $mmt_currentState ~~ "WRITE" ) {
      $buff = Inet::Table::IFACE->dequeue_packet_fragment( $self->{iface} );
      if ( defined($buff) && ( defined $self->{newSoc} ) ) {
         $self->{newSoc}->write($buff);
      }
      return ( "TOCHECK" );
   }

   if ( $mmt_currentState ~~ "TOCHECK" ) {
      if ( defined( $self->{newSoc} ) && ( $self->{timeout} != 0 ) ) {
         $ns = "READ";
      }
      else {
         $ns = "ACCEPT";
         print("Resetting iface $self->{iface} \n");
      }

      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "ACCEPT" ) {
      Inet::Table::IFACE->set_opened( $self->{iface}, FALSE );
      if ( defined( $self->{newSoc} ) ) {
         if ( $self->{select}->exists( $self->{newSoc} ) ) {
            ( $self->{select} )->remove( $self->{newSoc} );
            print("Removed reference to iface $self->{iface} from select \n");
         }
         print("Closing iface $self->{iface} \n");

         close( $self->{newSoc} );
      }

      $self->{newSoc} = undef;

      Inet::Table::IFACE->flush( $self->{iface} );

      @clients = ( $self->{select} )->can_read(0);
      foreach my $fh (@clients) {
         if ( $fh == $self->{soc} ) {
            $self->{newSoc} = $self->{soc}->accept();
            $self->{select}->add( $self->{newSoc} );
         }
      }
      if ( defined( $self->{newSoc} ) ) {
         $ns = "READ";
         $self->{timeout} = MAXTO;
         Inet::Table::IFACE->set_opened( $self->{iface}, TRUE );
         print("Accepted connection on iface $self->{iface} \n");
      }
      else {
         $ns = "ACCEPT";
      }

      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "OPEN" ) {
      undef( $self->{soc} );
      my $p = $self->{port};
      print("Try to open  iface $self->{iface} at host localhost / port $p \n");
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
         print("Failed to open iface $self->{iface} \n");
         die(
            Tosf::Exception::Trap->new(
               name => "Fsm::SocConS OPEN socket undefined"
            )
         );
      }
      else {
         print("Opened iface $self->{iface} at host localhost / port $p\n");
         $self->{select}->add( $self->{soc} );
      }

      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( "ACCEPT" );
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
   $gpkt = Inet::Packet::Generic->new();

   $mmt_taskName = "none";
   return ("OPEN");
}

1;

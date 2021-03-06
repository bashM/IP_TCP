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
      host        => my $host,
      soc         => my $soc,
      select      => my $select = IO::Select->new(),
      timeout     => my $timeout
   };

   $self->{soc}     = undef;
   $self->{timeout} = MAXTO;

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

   if ( defined( $params{iface} ) ) {
      $self->{iface} = $params{iface};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConC->new  iface undefined"
         )
      );
   }

   if ( defined( $params{handlerName} ) ) {
      $self->{handlerName} = $params{handlerName};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::SocConC->new  handlerName undefined"
         )
      );
   }

   bless( $self, $class );
   return $self;
}

my $buff;
my $ns;
my @clients;
my $gpkt;

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
         if ( $fh == $self->{soc} ) {
            $self->{soc}->recv( $buff, MAXLEN );
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
      if ( defined($buff) && ( defined( $self->{soc} ) ) ) {
         $self->{soc}->write($buff);
      }
      return ( "TOCHECK" );
   }

   if ( $mmt_currentState ~~ "TOCHECK" ) {
      if ( defined( $self->{soc} ) && ( $self->{timeout} != 0 ) ) {
         $ns = "READ";
      }
      else {
         $ns = "WAIT";
         print("Resetting interface $self->{iface} \n");
         Inet::Table::IFACE->set_opened( $self->{iface}, FALSE );
         $self->{timeout} = MAXTO;
      }

      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "WAIT" ) {
      if ( $self->{timeout} != 0 ) {
         $self->{timeout} = $self->{timeout} - 1;
      }

      if ( $self->{timeout} == 0 ) {
         $ns = "OPEN";
      }
      else {
         $ns = "WAIT";
      }

      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( $ns );
   }

   if ( $mmt_currentState ~~ "OPEN" ) {
      if ( defined( $self->{soc} ) ) {
         if ( $self->{select}->exists( $self->{soc} ) ) {
            ( $self->{select} )->remove( $self->{soc} );
            print(
               "Removed reference to interface $self->{iface} from select \n");
         }
         print("Closing interface $self->{iface} \n");
         close( $self->{soc} );
      }

      $self->{soc} = undef;

      Inet::Table::IFACE->flush( $self->{iface} );
      Inet::Table::IFACE->set_opened( $self->{iface}, FALSE );

      my $p = $self->{port};
      my $h = $self->{host};

      print("Try to open  interface $self->{iface} at host $h / port $p\n");
      $self->{soc} = new IO::Socket::INET(
         PeerAddr => $self->{host},
         PeerPort => $self->{port},
         Proto    => 'tcp',
         Timeout  => 00001,
         Blocking => 0
      );

      if ( !defined( $self->{soc} ) ) {
         print("Failed to open interface $self->{iface} \n");
         $self->{timeout} = MAXTO;
         $ns = "WAIT";
      }
      else {
         print("Opened interface $self->{iface} at host $h / port $p\n");
         $self->{select}->add( $self->{soc} );
         Inet::Table::IFACE->set_opened( $self->{iface}, TRUE );
         $self->{timeout} = MAXTO;
         $ns = "READ";
      }

      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( $ns );
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

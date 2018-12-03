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
      taskName    => my $taskName,
      iface       => my $iface,
      handlerName => my $handlerName,
      select      => my $select = IO::Select->new()
   };

   if ( defined( $params{iface} ) ) {
      $self->{iface} = $params{iface};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::StreamCon->new  iface undefined"
         )
      );
   }

   if ( defined( $params{handlerName} ) ) {
      $self->{handlerName} = $params{handlerName};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::StreamCon->new  handlerName undefined"
         )
      );
   }

   bless( $self, $class );
   return $self;
}

my $buff;
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
      undef($buff);
      @clients = ( $self->{select} )->can_read(0);
      foreach my $fh (@clients) {
         if ( $fh == \*STDIN ) {
            $buff = <>;
         }
      }

      if ( ( defined($buff) ) && ( length($buff) != 0 ) ) {

         Inet::Table::IFACE->enqueue_packet_fragment( $self->{iface}, $buff );

         $gpkt->set_opcode(1);
         $gpkt->set_msg( $self->{iface} );
         Tosf::Table::MESSAGE->enqueue( $self->{handlerName}, $gpkt->encode() );

         #Tosf::Table::MESSAGE->enqueue($self->{handlerName}, $self->{iface});
         Tosf::Table::MESSAGE->signal( $self->{handlerName} );
      }
      return ( "WRITE" );
   }

   if ( $mmt_currentState ~~ "WRITE" ) {
      $buff = Inet::Table::IFACE->dequeue_packet_fragment( $self->{iface} );
      if ( defined($buff) ) {
         print($buff);
      }

      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( "READ" );
   }

   if ( $mmt_currentState ~~ "OPEN" ) {
      Inet::Table::IFACE->flush( $self->{iface} );

      # assume stdin / stdout are open
      Inet::Table::IFACE->set_opened( $self->{iface}, TRUE );
      $self->{select}->add( \*STDIN );

      Tosf::Table::TASK->suspend( $self->{taskName} );
      return ( "READ" );
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

   Inet::Table::IFACE->set_inLeftFrame( $self->{iface}, '' );
   Inet::Table::IFACE->set_inRightFrame( $self->{iface}, "\n" );
   Inet::Table::IFACE->set_outLeftFrame( $self->{iface}, '' );
   Inet::Table::IFACE->set_outRightFrame( $self->{iface}, " " );

   $gpkt = Inet::Packet::Generic->new();
   $self->{taskName} = whoami();

   $mmt_taskName = "none";
   return ("OPEN");
}

1;

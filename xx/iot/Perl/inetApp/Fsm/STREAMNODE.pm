package inetApp::Fsm::STRAEMNODE;

#================================================================--
# File Name    : Fsm/STREAMNODE.pm
#
# Purpose      : stream Interface Controller for Node
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

   my $self = { taskName => my $taskName };

   bless( $self, $class );
   return $self;
}

my $pkt;
my $helpMsg =
"COMMAND\t\t\tBEHAVIOUR\nhelp\t\t\tdisplay help message \nquit\t\t\tshutdown\nsystem\t\t\tdisplay system information\nsend\t\t\tsend a message\n";
my @keys;
my $k;
my $readSuccess;
my $ns;
my $generic_pkt;
my $raw;
my $iface;
my $command;
my $param1;
my $param2;
my $node = '';

my $self;
my $mmt_taskName;
my $mmt_currentState;

sub tick {
   $self             = shift @_;
   $mmt_currentState = shift @_;
   no warnings "experimental::smartmatch";

   if ( $mmt_currentState ~~ "S0" ) {
      $raw = Tosf::Table::MESSAGE->dequeue( $self->{taskName} );
      $generic_pkt->decode($raw);
      $iface = $generic_pkt->get_msg();
      return ( "S1" );
   }

   if ( $mmt_currentState ~~ "S1" ) {
      $readSuccess = FALSE;
      $node        = Inet::Collection::NODE->get_name();
      if ( Inet::Table::IFACE->get_opened($iface) ) {
         $pkt = Inet::Table::IFACE->dequeue_packet($iface);
         if ( defined($pkt) ) {
            $readSuccess = TRUE;

            my @words = split( ' ', $pkt );

            #my $command = shift(@words);
            $command = $words[0];
            $param1  = $words[1];
            $param2  = $words[2];

            if ( !defined($command) ) {
               $command = ' ';
            }

            if ( !defined($param1) ) {
               $param1 = "Hello World";
            }

            if ( $command eq ' ' ) {
               Inet::Table::IFACE->enqueue_packet( $iface, "$node >" );
            }
            elsif ( $command eq 'help' ) {
               Inet::Table::IFACE->enqueue_packet( $iface,
                  "$helpMsg" . "$node >" );
            }
            elsif ( $command eq 'send' ) {
               @keys = Inet::Table::IFACE->get_keys();
               foreach $k (@keys) {
                  if (  ( Inet::Table::IFACE->get_opened($k) )
                     && ( Inet::Table::IFACE->get_type($k) ne 'stream' ) )
                  {
                     Inet::Table::IFACE->enqueue_packet( $k, $param1 );
                  }
               }

               Inet::Table::IFACE->enqueue_packet( $iface,
                      "send: message ("
                    . "$param1"
                    . ") has been sent\n"
                    . "$node >" );
            }
            elsif ( $command eq 'system' ) {
               my $h = Inet::Collection::NODE->get_ihost();
               my $p = Inet::Collection::NODE->get_iport();
               my $w = Tosf::Executive::SCHEDULER->get_cycleWarningCount();
               print "here is my Mac Table: \n ";
               Inet::Table::MAC->dump();
               Inet::Table::IFACE->enqueue_packet( $iface,
                      "system: up-link $h:$p\n"
                    . "system: cycle warning count = $w\n"
                    . "$node >" );
            }
            elsif ( $command eq 'quit' ) {
               main::leaveScript();
            }
            else {
               Inet::Table::IFACE->enqueue_packet( $iface,
                      "invalid command: type help for command listing\n"
                    . "$node >" );
            }
         }
      }

      if ( !$readSuccess ) {
         Tosf::Table::MESSAGE->wait( $self->{taskName} );
         $ns = "S0";
      }
      else {
         $ns = "S1";
      }
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
   Tosf::Table::MESSAGE->wait( $self->{taskName} );
   $generic_pkt = Inet::Packet::Generic->new();

   $mmt_taskName = "none";
   return ("S0");
}

1;

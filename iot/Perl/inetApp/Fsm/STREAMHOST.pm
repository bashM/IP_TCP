package inetApp::Fsm::STREAMHOST;

#================================================================--
# File Name    : Fsm/STREAMHOST.pm
#
# Purpose      : stream Interface Controller for Host
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

   if ( defined( $params{taskName} ) ) {
      $self->{taskName} = $params{taskName};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::StreamHost->new  taskName undefined"
         )
      );
   }

   bless( $self, $class );
   return $self;
}

my $pkt;
my $helpMsg =
"COMMAND\t\t\tBEHAVIOUR\nhelp\t\t\tdisplay help message \nquit\t\t\tshutdown\nsystem\t\t\tdisplay system information\nping ip\t\t\techo request\nincrement ip value\tincrement value\n";
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
my $host = '';

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
      $host        = Inet::Collection::HOST->get_name();
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

            if ( $command eq ' ' ) {
               Inet::Table::IFACE->enqueue_packet( $iface, "$host >" );
            }
            elsif ( $command eq 'help' ) {
               Inet::Table::IFACE->enqueue_packet( $iface,
                  "$helpMsg" . "$host >" );
            }
            elsif ( $command eq 'ping' ) {
               if ( defined($param1) ) {
                  $generic_pkt->set_dest_ip($param1);
                  $generic_pkt->set_src_ip("0.0.0.0");
                  $generic_pkt->set_opcode("PG1");
                  Tosf::Table::MESSAGE->enqueue( "PING",
                     $generic_pkt->encode() );
                  Tosf::Table::MESSAGE->signal("PING");
                  Inet::Table::IFACE->enqueue_packet( $iface, "$host >" );
               }
               else {
                  Inet::Table::IFACE->enqueue_packet( $iface,
                     "missing ip parameter\n" . "$host >" );
               }
            }
            elsif ( $command eq 'system' ) {
               my $w = Tosf::Executive::SCHEDULER->get_cycleWarningCount();
               Inet::Table::IFACE->enqueue_packet( $iface,
                  "system: cycle warning count = $w\n" );
               my $r = Inet::Table::ROUTE->dumps();
               Inet::Table::IFACE->enqueue_packet( $iface,
                  "\nsystem (route table) \n" . $r );
               my $n = Inet::Table::IFACE->dumps();
               Inet::Table::IFACE->enqueue_packet( $iface,
                  "\nsystem (iface table) \n" . $n );
               my $a = Inet::Table::ARP->dumps();
               Inet::Table::IFACE->enqueue_packet( $iface,
                  "\nsystem (arp table) \n" . $a . "$host >" );
            }
            elsif ( $command eq 'quit' ) {
               main::leaveScript();
            }
            else {
               Inet::Table::IFACE->enqueue_packet( $iface,
                      "invalid command: type help for command listing\n"
                    . "$host >" );
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

   Tosf::Table::MESSAGE->wait( $self->{taskName} );
   $generic_pkt = Inet::Packet::Generic->new();

   $mmt_taskName = "none";
   return ("S0");
}

1;

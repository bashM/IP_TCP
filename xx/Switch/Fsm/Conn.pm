package Switch::Fsm::Conn;

#================================================================--
# File Name    : Fsm/Conn.pm
#
# Purpose      : Packet controller
#
# Author       : Peter Walsh, Vancouver Island University
#
# Modified by  : Alwaleed (Welly) Alqufaydi
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;
use Inet::Packet::Ethernet;
my $eth_interface = Inet::Packet::Ethernet->new();

sub new {
   my $class  = shift @_;
   my %params = @_;

   my $self = {
      taskID => my $taskID,
      nicID  => my $nicID,
   };

   if ( defined( $params{taskID} ) ) {
      $self->{taskID} = $params{taskID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::Conn->new  taskID undefined"
         )
      );
   }

   if ( defined( $params{nicID} ) ) {
      $self->{nicID} = $params{nicID};
   }
   else {
      die(
         Tosf::Exception::Trap->new(
            name => "Fsm::Conn->new  nicID undefined"
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

   my $pkt;
   my @keys;
   my $k;
   my $msg;
   my $src_mac;
   my $dest_mac;
   my $i;
   my $isFound = "false";
   my $time    = 10;
   my @macs;

   if ( $mmt_currentState ~~ "S0" ) {
      if ( Switch::Table::NIC->get_open( $self->{nicID} ) ) {

         $pkt = Switch::Table::NIC->dequeue_packet( $self->{nicID} );

         if (  ( defined($pkt) )
            && ( length($pkt) != 0 )
            && ( !( $pkt eq "heartbeat" ) ) )
         {

            $eth_interface->decode($pkt);
            $msg      = $eth_interface->get_msg();
            $src_mac  = $eth_interface->get_src_mac();
            $dest_mac = $eth_interface->get_dest_mac();

            if ( $src_mac != 90 ) {
               Switch::Table::NIC->set_mac( $self->{nicID}, $src_mac );
               Switch::Table::NIC->set_time( $self->{nicID}, $time );

            }
            if ( $src_mac != 91 ) {
               Switch::Table::NIC->set_mac( $self->{nicID}, $src_mac );
               Switch::Table::NIC->set_time( $self->{nicID}, $time );
            }
            else {
               $dest_mac = 90;
               $src_mac  = 90;
               Switch::Table::NIC->set_mac( $self->{nicID}, $src_mac );
               Switch::Table::NIC->set_time( $self->{nicID}, $time );
            }
            @keys = Switch::Table::NIC->get_keys();

            foreach $k (@keys) {
               $i = Switch::Table::NIC->get_mac($k);

               @macs = Switch::Table::NIC->get_mac($k);

               if (  ( defined($i) )
                  && ( defined($dest_mac) )
                  && ( defined($src_mac) ) )
               {
                  print "table is @macs\n";
                  if ( $dest_mac eq $i ) {

                     Switch::Table::NIC->enqueue_packet( $k, $msg );
                     $isFound = "true";
                  }

               }

            }

            if ( $isFound eq "false" ) {
               foreach $k (@keys) {
                  if ( $k ne $self->{nicID} ) {
                     Switch::Table::NIC->enqueue_packet( $k, $msg );
                  }
               }
            }
         }
      }

      Tosf::Table::TASK->suspend( $self->{taskID} );
      return ( "S0" );
   }

}

sub reset {
   my $self = shift @_;

   return ("S0");
}

1;

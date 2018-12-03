package Switch::Record::Nic;
#================================================================--
# File Name    : Record/Nic.pm
#
# Purpose      : implements Nic record
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

sub  new {
   my $class = shift @_;

   my $self = {
      open => my $open = 0,
      mac => my $mac,
	  time => my $time,
	  #nic_name => my $nic_name,
      line => Tosf::Collection::Line->new()
   };
                
   bless ($self, $class);
   return $self;
}

sub get_open {
   my $self = shift @_;

   return $self->{open};
}

sub set_open {
   my $self = shift @_;
   my $o = shift @_;

   $self->{open} = $o;
   return;
}

sub get_mac {
   my $self = shift @_;

   return $self->{mac};
}

sub set_mac {
   my $self = shift @_;
   my $m = shift @_;

   $self->{mac} = $m;
   return;
}

sub set_time {
   my $self = shift @_;
   my $T = shift @_;

   $self->{time} = $T;
   return;
}
sub get_time {
   my $self = shift @_;

   return $self->{time};
}
sub dequeue_packet {
   my $self = shift @_;

   return $self->{line}->dequeue_packet();
}

sub dequeue_packet_fragment {
   my $self = shift @_;
   my $s = shift @_;

   return ($self->{line})->dequeue_packet_fragment($s);
}

sub flush {
   my $self = shift @_;
 
   $self->{line}->flush();
   return;
}
sub enqueue_packet {
   my $self = shift @_;
   my $p = shift @_;
 
   $self->{line}->enqueue_packet($p);
   return;
}

sub enqueue_packet_fragment {
   my $self = shift @_;
   my $f = shift @_;
 
   $self->{line}->enqueue_packet_fragment($f);
   return;
}

sub dump {
   my $self = shift @_;

   print ("Open: $self->{open} \n");
   print ("Mac: $self->{mac} \n");
   print ("Line: \n");
   $self->{line}->dump();
}

1;

#!/usr/bin/perl
#================================================================--
# File Name    : hubClient.p soft linked to p2pClient.pl
#
# Purpose      : Implement the Virtual Hub/p2p Client for csci 460
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$|=1;
use strict;
use warnings;


use AnyEvent;
use AnyEvent::Socket;
use lib '../';
use Tosf::Collection::Line;
use Inet::Packet::Ethernet;
use constant MACHINE_IP => '127.0.0.1';

my $portNo=0;;
my $socket_port;
my @words;
my $inline;
my $command;
my $msg;
my $src_mac;
my $dest_mac;
my @stdin_fifo;
my @stdout_fifo;
my @task_fifo;
my $num;
my $line;
my $deb=1;
my $interface=Tosf::Collection::Line->new();
my $eth_pkt=Inet::Packet::Ethernet->new();
my $process_stdout_ref;
my $process_stdin_ref;
my $z_event;
my $a_event;
my $b_event;
my $s_event;
my $q_event;
my $e_event;

sub prompt {
   push(@stdout_fifo, "Client[$portNo]> ");
   push(@task_fifo, $process_stdout_ref);
}

sub leaveScript {
   print ("Good Bye\n");
   exit;
}

$SIG{INT} = sub {leaveScript();};

$process_stdout_ref = sub {
   while (@stdout_fifo != 0) {
      print(shift(@stdout_fifo));
   }
};

$process_stdin_ref = sub {
   $inline = shift(@stdin_fifo);
   $inline = $inline . " no_command_entered"; 
   @words= split(' ', $inline);
   $command=shift(@words);
   if ($command eq "h") {
      push(@stdout_fifo, "help: (h)elp (o)pen [port] (s)end [message] (e)nable output (d)isable output (q)uit \n");
      push(@task_fifo, $process_stdout_ref);
      prompt();
   } elsif ($command eq "o") {
      if ($#words == 0) {
         push(@stdout_fifo, "invalid port: $portNo enter h for help\n");
         push(@task_fifo, $process_stdout_ref);
         prompt();
      } else {
         $portNo=shift(@words);
         tcp_connect MACHINE_IP,  $portNo, sub {
            $socket_port = shift;
            if (!defined $socket_port) {
               push(@stdout_fifo, "ERROR: cant open socket\n");
               push(@task_fifo, $process_stdout_ref);
               prompt(); # needed in the call back because it may be called "later"
            }
         };
         prompt();
      }
   } elsif ($command eq "s") {
      if (defined($words[0])) {
         $msg=shift(@words);
      } else {
         $msg='';
      }
      if (defined $socket_port) {
         $interface->enqueue_packet($msg);
      } else {
         push(@stdout_fifo, "ERROR socket is not open \n");
         push(@task_fifo, $process_stdout_ref);
      }
      prompt();
   }elsif ($command eq "w") {
      if (defined($words[0])&&(defined($words[1]))&&(defined($words[2]))) {
         
         $msg = shift(@words);
         $src_mac = shift(@words);
         $dest_mac = shift(@words);
         
         $eth_pkt->set_msg($msg);
	 $eth_pkt->set_src_mac($src_mac);
	 $eth_pkt->set_dest_mac($dest_mac);
         #$pkt_str = ($eth_pkt->encode());
         #$interface->enqueue_packet($pkt_str);
      } else {
         $msg='';
         print "DO IT AGAIN !!!\n";
      }
      if (defined $socket_port) {
         $interface->enqueue_packet($eth_pkt->encode());
      } else {
         push(@stdout_fifo, "ERROR socket is not open \n");
         push(@task_fifo, $process_stdout_ref);
      }
      prompt(); 
   
   
   }elsif ($command eq "q") { 
      leaveScript();
   } elsif ($command eq "d") { 
      $deb=0;
      push(@stdout_fifo, "RAW output disabled \n");
      push(@task_fifo, $process_stdout_ref);
      prompt();
   } elsif ($command eq "e") { 
      $deb=1;
      push(@stdout_fifo, "RAW output enabled \n");
      push(@task_fifo, $process_stdout_ref);
      prompt();
   } else {
      push(@stdout_fifo, "invalid command: $command enter h for help\n");
      push(@task_fifo, $process_stdout_ref);
      prompt();
   }
}; 

print "Client [$portNo]> ";

#begin implicit while (1) event loop ++++++++
$z_event = AnyEvent->condvar;

$a_event = AnyEvent->io (
   fh => \*STDIN,
   poll => "r",
   cb => sub {
      $line = <>;
      push(@stdin_fifo, $line);
      push(@task_fifo, $process_stdin_ref);
   }
);

$q_event = AnyEvent->timer (
   after => 1,
   interval => 10,
   cb => sub {
      if (defined $socket_port) {
         $interface->enqueue_packet("heartbeat");
      }
   }
);

$s_event = AnyEvent->timer (
   after => 1,
   interval => 0.02,
   cb => sub {
      if (defined($socket_port)) {
         my $num=sysread($socket_port, $line, 200);
         if (defined($num) && ($num != 0)) {
            if ($deb) {
               $line = "RAW RECEIVED -->" . $line . "<--\n";
               push(@stdout_fifo, $line);
               push(@task_fifo, $process_stdout_ref);
               prompt();
	    }
         }
      }
   }
);

$b_event = AnyEvent->timer (
   after => 1,
   interval => 0.02,
   cb => sub {
      my $buff;
      $buff = $interface->dequeue_packet_fragment(10);
      if (defined($buff)) {
         if (defined($socket_port)) {
            syswrite($socket_port, $buff);
         }
      }
   }
);

$e_event= AnyEvent->idle(
   cb => sub {
      if (@task_fifo !=0) {
         my $sr = shift(@task_fifo);
         $sr->();
      }
   }
);
               
#end implicit while (1) event loop ++++++++
$z_event->recv;


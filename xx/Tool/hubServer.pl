#!/usr/bin/perl
#================================================================--
# File Name    : hubServer.pl
#
# Purpose      : Implement the Virtual Hub infrastructure for csci 460
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
use lib './';
use Tosf::Collection::Line;
use Exc::TryCatch;

my $portsOpen=0;
my $maxPackSize=500;
my $maxPorts=4;
my $startPort=9000; 
my @socket_port;
my @interface;
my @stdin_fifo;
my @stdout_fifo;
my @task_fifo;

my $process_stdout_ref;
my $process_stdin_ref;
my $z_event;
my $a_event;
my $s_event;
my $e_event;
my $l_event;
my $m_event;
my $n_event;

sub prompt {
   push(@stdout_fifo, "hubServer[$portsOpen]> ");
   push(@task_fifo, $process_stdout_ref);
}

sub leaveScript {
   print ("Good Bye\n");
   exit;
}

sub openServer {

   my $ref_fh = shift;
   my $prt =shift;

   my $servercb = Exc::TryCatch->new(
      fn => sub {
         ${$ref_fh} = shift;
         if (!defined ${$ref_fh}) {
            push(@stdout_fifo, "ERROR: cant open socket\n");
            push(@task_fifo, $process_stdout_ref);
            prompt(); # needed in the call back because it may be called "later"
         }
      }
   );

   tcp_server undef,  $prt, $servercb->get_wfn();
}


$SIG{INT} = sub {leaveScript();};

$process_stdout_ref = sub {
   while (@stdout_fifo != 0) {
      print(shift(@stdout_fifo));
   }
};

$process_stdin_ref = sub {
   my $inline = shift(@stdin_fifo);
   $inline = $inline . " no_command_entered";
   my @words= split(' ', $inline);
   my $command = shift(@words);
   if ($command eq "h") {
      push(@stdout_fifo, "help: (h)elp (o)open (q)uit \n");
      push(@task_fifo, $process_stdout_ref);
      prompt();
   } elsif ($command eq "o") {
      if (!$portsOpen) {
         $portsOpen=1;
         for (my $i=0; $i<$maxPorts; $i++) {
           openServer(\$socket_port[$i], $startPort+$i);
           # note the open checking is in the cb for tcp_server
         }
         push(@stdout_fifo, "Open Complete\n");
         push(@task_fifo, $process_stdout_ref);
      } else {
         push(@stdout_fifo, "Command ignored, ports are already open\n");
         push(@task_fifo, $process_stdout_ref);
      }
      prompt();
   } elsif ($command eq "q") { 
      leaveScript();
   } else {
      push(@stdout_fifo, "invalid command: $command enter h for help\n");
      push(@task_fifo, $process_stdout_ref);
      prompt();
   }
}; 

prompt();
#initialize Line data structure
for (my $i=0; $i<$maxPorts; $i++) {
   $interface[$i] = Tosf::Collection::Line->new();
}

#begin implicit while (1) event loop ++++++++
$z_event = AnyEvent->condvar;

my $acb = Exc::TryCatch->new(
   fn => sub {
      my $line = <>;
      push(@stdin_fifo, $line);
      push(@task_fifo, $process_stdin_ref);
      prompt();
   }
);


$a_event = AnyEvent->io (
   fh => \*STDIN,
   poll => "r",
   cb => $acb->get_wfn()
);

my $scb = Exc::TryCatch->new(
   fn => sub { 
      for (my $i=0; $i<$maxPorts; $i++) {
         if (defined $socket_port[$i]) {
            my $num=sysread($socket_port[$i], my $line, $maxPackSize);
            if (defined($num) && ($num != 0)) {
               #print ("Line Read ", $line, "\n"); # for debugging
               $interface[$i]->enqueue_packet_fragment($line);
               #$interface[$i]->dump(); #for testing
            }
         }
      }
   }
);

$s_event = AnyEvent->timer (
   after => 1,
   interval => 0.03,
   cb => $scb->get_wfn()
);

my $lcb = Exc::TryCatch->new(
   fn => sub {
      for (my $i=0; $i<$maxPorts; $i++) {
         my $buff;
         $buff = $interface[$i]->dequeue_packet_fragment(10);
         if (defined($buff) && defined($socket_port[$i])) {
            syswrite($socket_port[$i], $buff);
         }
      }
   }
);

$l_event = AnyEvent->timer (
   after => 2,
   interval => 0.03,
   cb => $lcb->get_wfn()
);

my $mcb = Exc::TryCatch->new(
   fn => sub {
      for (my $i=0; $i<$maxPorts; $i++) {
         my $msg;
         $msg=$interface[$i]->dequeue_packet();
         if (defined($msg)) {
            #print("Dequeued Message ", $msg , "\n"); # for testing
            my $startFrom=int($i / 4) * 4; # 4 ports per hub
            for (my $j=$startFrom; $j<$startFrom+4; $j++) {
               if (defined $socket_port[$j]) {
                  #print ("Enqueued Message ", $msg, "\n"); # for testing
                  $interface[$j]->enqueue_packet($msg);
               }
            }
         }
      }
   }
);

$m_event = AnyEvent->timer (
   after => 3,
   interval => 0.03,
   cb => $mcb->get_wfn()
);

my $ncb = Exc::TryCatch->new(
   fn => sub {
      #print("Sending Ping \n");
      for (my $i=0; $i<$maxPorts; $i++) {
         $interface[$i]->enqueue_packet("heartbeat");
      }
   }
);

#keep unused sockets open over time
$n_event = AnyEvent->timer (
   after => 1,
   interval => 20,
   cb => $ncb->get_wfn()
);

my $ecb = Exc::TryCatch->new(
   fn => sub {
      if (@task_fifo !=0) {
         my $sr = shift(@task_fifo);
         $sr->();
      }
   }
);


$e_event= AnyEvent->idle(
   cb => $ecb->get_wfn()
);
               
#end implicit while (1) event loop ++++++++
$z_event->recv;


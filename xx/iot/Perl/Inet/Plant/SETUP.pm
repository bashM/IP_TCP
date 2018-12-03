package Inet::Plant::SETUP;
#================================================================--
# File Name    : SETUP.pm
#
# Purpose      : Plant set-up 
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;
use constant TRUE => 1;
use constant FALSE => 0;

sub start {
  
   my $name;

   $name = "ETHERNET";
   Tosf::Table::TASK->new(
      name => $name,
      periodic => FALSE,
      run => TRUE,
      fsm => Inet::Fsm::ETHERNET->new(
         taskName => $name
      )
   );

   Tosf::Table::TASK->reset("ETHERNET");

   $name = "IP";
   Tosf::Table::TASK->new(
      name => $name,
      periodic => FALSE,
      run => FALSE,
      fsm => Inet::Fsm::IP->new(
         taskName => $name
      )
   );

   Tosf::Table::TASK->reset("IP");

   $name = "ICMP";
   Tosf::Table::TASK->new(
      name => $name,
      periodic => FALSE,
      run => FALSE,
      fsm => Inet::Fsm::ICMP->new(
         taskName => $name
      )
   );

   Tosf::Table::TASK->reset("ICMP");

}

1;

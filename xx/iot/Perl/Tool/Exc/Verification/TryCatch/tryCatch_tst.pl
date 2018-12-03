#!/usr/bin/perl
######################################################
# Peter Walsh
# TryCatch test driver
######################################################

use lib '../../../';
use Exc::TryCatch;
use Exc::Exception;

$s0 = Exc::TryCatch->new(
   fn => sub { 
      my $p = shift @_;

      print("Hello World $p \n"); 
      
      #die("Peter");
      die(Exc::Exception->new(name => "from test driver"));
   } 
);

$s0->run("From Peter");

$wfn = $s0->get_wfn();
$wfn->("From Paul");

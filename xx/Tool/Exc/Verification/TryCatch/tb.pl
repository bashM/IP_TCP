#================================================================--
# File Name    : Exc/Verification/TryCatch/tb.cew
#
# Purpose      : unit testing
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#================================================================--

$| = 1;
use strict;
use warnings;

use lib '../../../';
use Exc::Exception;
use Exc::TryCatch;
use Try::Tiny;
use AnyEvent;

my $cew_Test_Count  = 0;
my $cew_Error_Count = 0;
no warnings "experimental::smartmatch";

sub leaveScript {
   print("\n**********Summary**********\n");
   print( "Total number of test cases = ",          $cew_Test_Count,  "\n" );
   print( "Total number of test cases in error = ", $cew_Error_Count, "\n" );

   print("Bye\n");
   exit(0);
}

$SIG{INT} = sub { leaveScript(); };

my $z_event;
my $f_event;
my $g_event;

#begin implicit while (1) event loop ++++++++
$z_event = AnyEvent->condvar;

my $etime = 10;

$f_event = AnyEvent->timer(
   after    => 1,
   interval => 3,
   cb       => sub {
      $etime--;
      print( "Test time remaining: ", $etime, " seconds \n" );
      $cew_Test_Count = $cew_Test_Count + 1;
      do {
         try {
            die( Exc::Exception->new( name => "in cew" ) );
            $cew_Error_Count = $cew_Error_Count + 1;
            print( "Test Case ERROR (Ecase) in script at line number ",
               48, "\n" );
            print( "Expected exception ", "in cew", " not thrown \n" );
         }
         catch {
            my $cew_e = $_;
            if ( ref($cew_e) ~~ "Exc::Exception" ) {
               my $cew_exc_name = $cew_e->get_name();
               if ( $cew_exc_name ne "in cew" ) {
                  $cew_Error_Count = $cew_Error_Count + 1;
                  print( "Test Case ERROR (Ecase) in script at line number ",
                     48, "\n" );
                  print( "Unexpected exception ", $cew_exc_name, " thrown \n" );
               }
            }
            else {
               die("ref($cew_e)");
            }
         }
      };

      if ( $etime == 0 ) {
         leaveScript();
      }

   }
);

my $s0 = Exc::TryCatch->new(
   fn => sub {

      #die("Peter");
      if ( rand() < 0.5 ) {
         $cew_Test_Count = $cew_Test_Count + 1;
         do {
            try {
               die( Exc::Exception->new( name => "lol" ) );
               $cew_Error_Count = $cew_Error_Count + 1;
               print( "Test Case ERROR (Ecase) in script at line number ",
                  60, "\n" );
               print( "Expected exception ", "lol", " not thrown \n" );
            }
            catch {
               my $cew_e = $_;
               if ( ref($cew_e) ~~ "Exc::Exception" ) {
                  my $cew_exc_name = $cew_e->get_name();
                  if ( $cew_exc_name ne "lol" ) {
                     $cew_Error_Count = $cew_Error_Count + 1;
                     print( "Test Case ERROR (Ecase) in script at line number ",
                        60, "\n" );
                     print( "Unexpected exception ",
                        $cew_exc_name, " thrown \n" );
                  }
               }
               else {
                  die("ref($cew_e)");
               }
            }
         };

      }
   }
);

$g_event = AnyEvent->timer(
   after    => 1,
   interval => 1,
   cb       => $s0->get_wfn()
);

#end implicit while (1) event loop ++++++++
$z_event->recv;


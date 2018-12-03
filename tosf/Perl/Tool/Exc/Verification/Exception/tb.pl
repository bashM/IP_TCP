#================================================================--
# File Name    : tb.cew
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
use Try::Tiny;

my $cew_Test_Count  = 0;
my $cew_Error_Count = 0;
no warnings "experimental::smartmatch";

################
# testing exc

my $exc = Exc::Exception->new( name => "Peter" );
$cew_Test_Count = $cew_Test_Count + 1;
do {
   try {
      ;
      my $xact = $exc->get_name();
      my $xexp = "Peter";
      if ( !( ($xact) ~~ ($xexp) ) ) {
         $cew_Error_Count = $cew_Error_Count + 1;
         print( "Test Case ERROR (Ncase) in script at line number ", 28, "\n" );

         if ( !defined($xact) ) {
            $xact = "undefined";
         }
         if ( !defined($xexp) ) {
            $xexp = "undefined";
         }

         print( "Actual Value is ",   $xact, " \n" );
         print( "Expected Value is ", $xexp, "\n" );
      }
   }
   catch {
      my $cew_e = $_;
      if ( ref($cew_e) ~~ "Exc::Exception" ) {
         my $cew_exc_name = $cew_e->get_name();
         $cew_Error_Count = $cew_Error_Count + 1;
         print( "Test Case ERROR (Ncase) in script at line number ", 28, "\n" );
         print( "Unexpected Exception ", $cew_exc_name, " thrown \n" );
      }
   }
};

$cew_Test_Count = $cew_Test_Count + 1;
do {
   try {
      $exc->set_name("Paul");
      my $xact = $exc->get_name();
      my $xexp = "Paul";
      if ( !( ($xact) ~~ ($xexp) ) ) {
         $cew_Error_Count = $cew_Error_Count + 1;
         print( "Test Case ERROR (Ncase) in script at line number ", 29, "\n" );

         if ( !defined($xact) ) {
            $xact = "undefined";
         }
         if ( !defined($xexp) ) {
            $xexp = "undefined";
         }

         print( "Actual Value is ",   $xact, " \n" );
         print( "Expected Value is ", $xexp, "\n" );
      }
   }
   catch {
      my $cew_e = $_;
      if ( ref($cew_e) ~~ "Exc::Exception" ) {
         my $cew_exc_name = $cew_e->get_name();
         $cew_Error_Count = $cew_Error_Count + 1;
         print( "Test Case ERROR (Ncase) in script at line number ", 29, "\n" );
         print( "Unexpected Exception ", $cew_exc_name, " thrown \n" );
      }
   }
};

################
# testing cew.pl

# no exception thrown (should not fail)
$cew_Test_Count = $cew_Test_Count + 1;
do {
   try {
      ;
      my $xact = 0;
      my $xexp = 0;
      if ( !( ($xact) ~~ ($xexp) ) ) {
         $cew_Error_Count = $cew_Error_Count + 1;
         print( "Test Case ERROR (Ncase) in script at line number ", 35, "\n" );

         if ( !defined($xact) ) {
            $xact = "undefined";
         }
         if ( !defined($xexp) ) {
            $xexp = "undefined";
         }

         print( "Actual Value is ",   $xact, " \n" );
         print( "Expected Value is ", $xexp, "\n" );
      }
   }
   catch {
      my $cew_e = $_;
      if ( ref($cew_e) ~~ "Exc::Exception" ) {
         my $cew_exc_name = $cew_e->get_name();
         $cew_Error_Count = $cew_Error_Count + 1;
         print( "Test Case ERROR (Ncase) in script at line number ", 35, "\n" );
         print( "Unexpected Exception ", $cew_exc_name, " thrown \n" );
      }
   }
};

# unexpected exception thrown (should fail)
$cew_Test_Count = $cew_Test_Count + 1;
do {
   try {
      die( Exc::Exception->new( name => "full" ) );
      my $xact = 0;
      my $xexp = 0;
      if ( !( ($xact) ~~ ($xexp) ) ) {
         $cew_Error_Count = $cew_Error_Count + 1;
         print( "Test Case ERROR (Ncase) in script at line number ", 38, "\n" );

         if ( !defined($xact) ) {
            $xact = "undefined";
         }
         if ( !defined($xexp) ) {
            $xexp = "undefined";
         }

         print( "Actual Value is ",   $xact, " \n" );
         print( "Expected Value is ", $xexp, "\n" );
      }
   }
   catch {
      my $cew_e = $_;
      if ( ref($cew_e) ~~ "Exc::Exception" ) {
         my $cew_exc_name = $cew_e->get_name();
         $cew_Error_Count = $cew_Error_Count + 1;
         print( "Test Case ERROR (Ncase) in script at line number ", 38, "\n" );
         print( "Unexpected Exception ", $cew_exc_name, " thrown \n" );
      }
   }
};

# expected exception thrown (should not fail)
$cew_Test_Count = $cew_Test_Count + 1;
do {
   try {
      die( Exc::Exception->new( name => "full" ) );
      $cew_Error_Count = $cew_Error_Count + 1;
      print( "Test Case ERROR (Ecase) in script at line number ", 41, "\n" );
      print( "Expected exception ", "full", " not thrown \n" );
   }
   catch {
      my $cew_e = $_;
      if ( ref($cew_e) ~~ "Exc::Exception" ) {
         my $cew_exc_name = $cew_e->get_name();
         if ( $cew_exc_name ne "full" ) {
            $cew_Error_Count = $cew_Error_Count + 1;
            print( "Test Case ERROR (Ecase) in script at line number ",
               41, "\n" );
            print( "Unexpected exception ", $cew_exc_name, " thrown \n" );
         }
      }
      else {
         die("ref($cew_e)");
      }
   }
};

# unexpected exception thrown (should fail)
$cew_Test_Count = $cew_Test_Count + 1;
do {
   try {
      die( Exc::Exception->new( name => "ull" ) );
      $cew_Error_Count = $cew_Error_Count + 1;
      print( "Test Case ERROR (Ecase) in script at line number ", 44, "\n" );
      print( "Expected exception ", "full", " not thrown \n" );
   }
   catch {
      my $cew_e = $_;
      if ( ref($cew_e) ~~ "Exc::Exception" ) {
         my $cew_exc_name = $cew_e->get_name();
         if ( $cew_exc_name ne "full" ) {
            $cew_Error_Count = $cew_Error_Count + 1;
            print( "Test Case ERROR (Ecase) in script at line number ",
               44, "\n" );
            print( "Unexpected exception ", $cew_exc_name, " thrown \n" );
         }
      }
      else {
         die("ref($cew_e)");
      }
   }
};

$cew_Test_Count = $cew_Test_Count + 1;
do {
   try {
      die( Exc::Exception->new( name => "full" ) );
      $cew_Error_Count = $cew_Error_Count + 1;
      print( "Test Case ERROR (Ecase) in script at line number ", 45, "\n" );
      print( "Expected exception ", "ull", " not thrown \n" );
   }
   catch {
      my $cew_e = $_;
      if ( ref($cew_e) ~~ "Exc::Exception" ) {
         my $cew_exc_name = $cew_e->get_name();
         if ( $cew_exc_name ne "ull" ) {
            $cew_Error_Count = $cew_Error_Count + 1;
            print( "Test Case ERROR (Ecase) in script at line number ",
               45, "\n" );
            print( "Unexpected exception ", $cew_exc_name, " thrown \n" );
         }
      }
      else {
         die("ref($cew_e)");
      }
   }
};

# expected exception not thrown (should fail)
$cew_Test_Count = $cew_Test_Count + 1;
do {
   try {
      ;
      $cew_Error_Count = $cew_Error_Count + 1;
      print( "Test Case ERROR (Ecase) in script at line number ", 48, "\n" );
      print( "Expected exception ", "full", " not thrown \n" );
   }
   catch {
      my $cew_e = $_;
      if ( ref($cew_e) ~~ "Exc::Exception" ) {
         my $cew_exc_name = $cew_e->get_name();
         if ( $cew_exc_name ne "full" ) {
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

print("\n**********Summary**********\n");
print( "Total number of test cases = ",          $cew_Test_Count,  "\n" );
print( "Total number of test cases in error = ", $cew_Error_Count, "\n" );


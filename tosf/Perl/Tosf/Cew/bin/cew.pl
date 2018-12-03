changecom(`#')

define(cew_Variables,
          `my $cew_Test_Count = 0;
           my $cew_Error_Count = 0; 
           no warnings "experimental::smartmatch"; '
)

define(cew_Summary,
         `print("\n**********Summary**********\n");
          print("Total number of test cases = ", $cew_Test_Count, "\n");
          print("Total number of test cases in error = ", $cew_Error_Count, "\n");'
)

define(cew_Ecase,
          `$cew_Test_Count = $cew_Test_Count+1;
           do {
              try {
                  $2;
                  $cew_Error_Count = $cew_Error_Count+1;
                  print("Test Case ERROR (Ecase) in script at line number ", $1, "\n");
                  print ("Expected exception ", $3, " not thrown \n");
              }
              catch {
                 my $cew_e = $_;
                 if (ref($cew_e) ~~ "Tosf::Exception::Trap") {
                    my $cew_exc_name = $cew_e->get_name();
                    if ($cew_exc_name ne $3) {
                       $cew_Error_Count = $cew_Error_Count+1;
                       print("Test Case ERROR (Ecase) in script at line number ", $1, "\n");
                       print ("Unexpected exception ", $cew_exc_name , " thrown \n");
                    } 
                 } else {
                    die("ref($cew_e)");
                 }
              }
            };'
)

define(cew_Ncase,
          `$cew_Test_Count = $cew_Test_Count+1;
          do {
             try {
                $2 ;
                my $xact = $3;
                my $xexp = $4;
                if (!(($xact) ~~ ($xexp))) {
                   $cew_Error_Count = $cew_Error_Count+1;
                   print("Test Case ERROR (Ncase) in script at line number ", $1, "\n");

                   if (!defined($xact)) {
                      $xact = "undefined";
                   }
                   if (!defined($xexp)) {
                      $xexp = "undefined";
                   }
        
                   print("Actual Value is ", $xact, " \n");
                   print("Expected Value is ", $xexp, "\n");
                }
             }
             catch {
                my $cew_e = $_;
                if (ref($cew_e) ~~ "Tosf::Exception::Trap") {
                   my $cew_exc_name = $cew_e->get_name();
                   $cew_Error_Count = $cew_Error_Count+1;
                   print("Test Case ERROR (Ncase) in script at line number ", $1, "\n");
                   print ("Unexpected Exception ", $cew_exc_name, " thrown \n");
                }
             }
          };'
)


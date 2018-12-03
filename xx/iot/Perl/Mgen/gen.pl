#!/usr/bin/perl
# This program auto-generates Module Makefiles for the tosf projects
# P Walsh Jan 2016

sub buildMakeTargets {
   my $cut = shift @_;
   my $date = shift @_;
   my $whoami = shift @_;
   my $content;
   
   $content = "# Makefile to drive Perl modules \n"; 
   $content = $content . "# Date auto-generated: " . $date;
   $content = $content . "# By: " . $whoami . "\n";
   $content = $content . "# P Walsh Jan 2016 \n";
   $content = $content . "\n";
   $content = $content .  "# Targets \n";
   $content = $content . "#   bats --- make batch tester from tb.cew \n";
   $content = $content . "#   clean \n";
   $content = $content . "#   cover --- test coverage\n";
   $content = $content . "#   tidy --- indent code in .pl, .pm  and .cew files \n";
   $content = $content . "\n";
   $content = $content . "# directory where scripts are located and temp file\n";
   $content = $content . "SD=../../../../Tosf/Cew\n";
   $content = $content . "CUT=../../$cut\n";
   $content = $content . "MKF=../../Makefile\n";
   $content = $content . "\n";
   $content = $content . "# code beautifier \n";
   $content = $content . "INDENT=perltidy -i=3 \n";
   $content = $content . "\n";
   $content = $content . "bats: tb.pl translate\n";
   $content = $content . "\tperl tb.pl\n";
   $content = $content . "\n";
   $content = $content . "translate: \n";
   $content = $content . "\t" . '@if [ -f $(MKF) ]; then ((cd ../../; $(MAKE) translate;) > /dev/null 2>&1)  fi' . "\n";
   $content = $content . "\n";
   $content = $content . "cover: tb.pl \n";
   $content = $content . "\t" . 'perl -MDevel::Cover tb.pl' . "\n";
   $content = $content . "\t" . '@cover -select $(CUT) -report text > $(CUT).cover' . "\n";
   $content = $content . "\t" . '@rm -r cover_db' .  "\n";
   $content = $content . "\n";
   $content = $content . "tb.pl: tb.cew \n";
   $content = $content . "\t" . '@rm -f $(SD)/tmp/tb.num' . "\n";
   $content = $content . "\t" . '@rm -f ./tb.pl' . "\n";
   $content = $content . "\t" . '@awk -f $(SD)/bin/addLineNums.awk tb.cew > $(SD)/tmp/tb.num' . "\n";
   $content = $content . "\t" . '@m4 -I $(SD)/bin $(SD)/tmp/tb.num  | $(INDENT) > tb.pl' . "\n";
   $content = $content . "\n";
   $content = $content . "tb.cew:\n";
   $content = $content . "\t" . '@cp $(SD)/Template/tb.cew .' . "\n";
   $content = $content . "\n";
   $content = $content . "clean:\n";
   $content = $content . "\t" . '@rm -f  $(SD)/tmp/* tb.pl $(CUT).cover *.cover $(CUT).tdy *.tdy *.ERR' . "\n";
   $content = $content . "\n";
   $content = $content . "tidy:\n";
   $content = $content . "\t" . '@$(INDENT) $(CUT) *.pl *.cew' . "\n";
   $content = $content . "\n";
}

sub makeMakefile{
   my $dir = shift @_;

   my @dirSegments = split('/', $dir);
   my $mod = $dirSegments[$#dirSegments] . ".pm";
   my $str = buildMakeTargets($mod, `date`, `whoami`);

   system("rm -f $dir/Makefile");
   open(FH, "> $dir/Makefile") || die "Cant open Makefile in $dir \n";
   print(FH $str);
   close(FH);
}

#=======================================================
makeMakefile('../Tosf/Demo/Verification/Lifo');
makeMakefile('../Tosf/Collection/Verification/Line');
makeMakefile('../Tosf/Collection/Verification/Queue');
makeMakefile('../Tosf/Collection/Verification/PQueue');
makeMakefile('../Tosf/Collection/Verification/STATUS');
makeMakefile('../Tosf/Record/Verification/Semaphore');
makeMakefile('../Tosf/Record/Verification/SVar');
makeMakefile('../Tosf/Record/Verification/Task');
makeMakefile('../Tosf/Record/Verification/Message');
makeMakefile('../Tosf/Table/Verification/QUEUE');
makeMakefile('../Tosf/Table/Verification/PQUEUE');
makeMakefile('../Tosf/Table/Verification/SEMAPHORE');
makeMakefile('../Tosf/Table/Verification/SVAR');
makeMakefile('../Tosf/Table/Verification/TASK');
makeMakefile('../Tosf/Table/Verification/MESSAGE');
makeMakefile('../Tosf/Widgit/Verification/Sensor');
makeMakefile('../Tosf/Widgit/Verification/Light');
makeMakefile('../Tosf/Executive/Verification/TIMER');
makeMakefile('../Tosf/Executive/Verification/DISPATCHER');
makeMakefile('../Tosf/Executive/Verification/SCHEDULER');
makeMakefile('../Tosf/Exception/Verification/Trap');
makeMakefile('../Tosf/Exception/Verification/Monitor');
makeMakefile('../Tosf/Fsm/Verification/To');
makeMakefile('../Tosf/Fsm/Verification/ATo');
#=======================================================
makeMakefile('../Inet/Packet/Verification/Arp');
makeMakefile('../Inet/Packet/Verification/Ethernet');
makeMakefile('../Inet/Packet/Verification/Generic');
makeMakefile('../Inet/Packet/Verification/Ip');
makeMakefile('../Inet/Packet/Verification/Udp');
makeMakefile('../Inet/Packet/Verification/Icmp');
makeMakefile('../Inet/Table/Verification/ARP');
makeMakefile('../Inet/Table/Verification/NIC');
makeMakefile('../Inet/Table/Verification/DEV');
makeMakefile('../Inet/Table/Verification/ROUTE');
makeMakefile('../Inet/Fsm/Verification/SocConS');
makeMakefile('../Inet/Fsm/Verification/SocConC');
makeMakefile('../Inet/Fsm/Verification/HBEAT');
makeMakefile('../Inet/Fsm/Verification/StreamCon');
makeMakefile('../Inet/Fsm/Verification/NODE');
makeMakefile('../Inet/Fsm/Verification/ETHERNET');
makeMakefile('../Inet/Fsm/Verification/IP');
makeMakefile('../Inet/Fsm/Verification/ICMP');
makeMakefile('../Inet/Record/Verification/Nic');
makeMakefile('../Inet/Record/Verification/Dev');
makeMakefile('../Inet/Record/Verification/Arp');
#=======================================================
makeMakefile('../inetApp/Fsm/Verification/STREAMHOST');
makeMakefile('../inetApp/Fsm/Verification/STREAMNODE');
makeMakefile('../inetApp/Plant/Verification/SETUP');
makeMakefile('../inetApp/Plant/Verification/LAN');
makeMakefile('../inetApp/Plant/Verification/NODE');
makeMakefile('../inetApp/Plant/Verification/HOST');
#=======================================================
makeMakefile('../Trace/Fsm/Verification/FOO');
#=======================================================
makeMakefile('../WTrace/Fsm/Verification/FOO');
#=======================================================
makeMakefile('../CentralizedTL/Fsm/Verification/CONN');
makeMakefile('../CentralizedTL/Fsm/Verification/DISP');
makeMakefile('../CentralizedTL/Plant/Verification/SYSTEM');
#=======================================================
makeMakefile('../LightsDI_155/Fsm/Verification/LIGHT');
makeMakefile('../LightsDI_155/Fsm/Verification/SIC');
makeMakefile('../LightsDI_155/Plant/Verification/SYSTEM');
#=======================================================
makeMakefile('../LightsTL/Fsm/Verification/LIGHT');
makeMakefile('../LightsTL/Fsm/Verification/NIC');
makeMakefile('../LightsTL/Plant/Verification/SYSTEM');
#=======================================================
makeMakefile('../ControlTL/Fsm/Verification/LIGHT');
makeMakefile('../ControlTL/Fsm/Verification/NIC');
makeMakefile('../ControlTL/Fsm/Verification/CAR');
#=======================================================

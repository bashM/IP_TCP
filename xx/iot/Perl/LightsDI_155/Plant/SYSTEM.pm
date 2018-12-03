package LightsDI_155::Plant::SYSTEM;
#================================================================--
# File Name    : SYSTEM.pm
#
# Purpose      : traffic light physical plant
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

use strict;
use warnings;
use Tosf::Widgit::Light;
use Tosf::Widgit::Sensor;
use constant FALSE => 0;
use constant TRUE => 1;

my $hwRed;
my $hwYellow;
my $hwGreen;
my $fyRed;
my $fyYellow;
my $fyGreen;


sub leaveScript {
   main::leaveScript();
}

sub start {

   # create highway window

   my $hwWindow = new Gtk2::Window "toplevel";
   $hwWindow->set_title('Highway');
   $hwWindow->signal_connect( 'destroy' => sub {leaveScript();});
   $hwWindow->set_resizable(FALSE);

   # create  highway lights

   $hwRed = Tosf::Widgit::Light->new(header => "Red");
   $hwGreen = Tosf::Widgit::Light->new(header => "Green");
   $hwYellow = Tosf::Widgit::Light->new(header => "Amber");

   # create vbox and place  highway lights  in vbox

   my $hwVbox = Gtk2::VBox->new( FALSE, 3 );
   $hwVbox->pack_start($hwRed->get_canvas(),FALSE,FALSE,0);
   $hwVbox->pack_start($hwYellow->get_canvas(),FALSE,FALSE,0);
   $hwVbox->pack_start($hwGreen->get_canvas(),FALSE,FALSE,0);
   $hwWindow->add($hwVbox);

   # initialize highway lights

   $hwRed->set_light('gray');
   $hwYellow->set_light('gray');
   $hwGreen->set_light('green');

   # create farmyard window

   my $fyWindow = new Gtk2::Window "toplevel";
   $fyWindow->set_title('Farmyard');
   $fyWindow->signal_connect( 'destroy' => sub {leaveScript();});
   $fyWindow->set_resizable(FALSE);

   # create  farmyard lights

   $fyRed = Tosf::Widgit::Light->new(header => "Red");
   $fyGreen = Tosf::Widgit::Light->new(header => "Green");
   $fyYellow = Tosf::Widgit::Light->new(header => "Amber");

   # create vbox and place  farmyard lights  in vbox

   my $fyVbox = Gtk2::VBox->new( FALSE, 3 );
   $fyVbox->pack_start($fyRed->get_canvas(),FALSE,FALSE,0);
   $fyVbox->pack_start($fyYellow->get_canvas(),FALSE,FALSE,0);
   $fyVbox->pack_start($fyGreen->get_canvas(),FALSE,FALSE,0);
   $fyWindow->add($fyVbox);

   # initialize farmyard lights

   $fyRed->set_light('red');
   $fyYellow->set_light('gray');
   $fyGreen->set_light('gray');


   $hwWindow->show_all;
   $fyWindow->show_all;

}

sub set_lights {
   my $class = shift @_;
   my @params = @_;

   $hwRed->set_light($params[0]);
   $hwYellow->set_light($params[1]);
   $hwGreen->set_light($params[2]);
   $fyRed->set_light($params[3]);
   $fyYellow->set_light($params[4]);
   $fyGreen->set_light($params[5]);
}

1;

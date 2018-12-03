#!/usr/bin/perl
######################################################
# Peter Walsh
# File: IOBUFFER.pl
# Module test driver
# Marius' test case
######################################################

use lib '../../../../';
use Tosf::Collection::Line;
use Tosf::Collection::IOBUFFER;

my $x = "INIT";
Tosf::Collection::IOBUFFER->send('dump');


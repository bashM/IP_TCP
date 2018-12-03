#!/usr/bin/perl
######################################################
# Peter Walsh
# File: queue_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Tosf::Collection::Queue;

my $x = Tosf::Collection::Queue->new();
my $y = Tosf::Collection::Queue->new();
print ($x->get_siz(), "\n");
$a = $y->is_member("foo");
print("Is member foo $a \n"); 

print ($x->get_siz(), "\n");

$x->enqueue("Hello");
$x->enqueue("world");

$y->enqueue("foo");
$y->enqueue("bar");
$y->enqueue("Demo3");

$a = $y->is_member("foo");
print("Is member foo $a \n"); 
$a = $y->is_member("bar");
print("Is member bar $a \n"); 
$a = $y->is_member("Demo3");
print("Is member Demo3 $a \n"); 
$a = $y->is_member("Demo4");
print("Is member Demo4 $a \n"); 

print ($x->get_siz(), "\n");
print ($y->get_siz(), "\n");

print ($x->dequeue(), "\n");
print ($y->dequeue(), "\n");
$a = $y->is_member("foo");
print("Is member foo $a \n"); 

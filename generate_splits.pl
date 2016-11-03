#!/usr/bin/env perl
# Generates Train/Test/Dev splits
# Every 8 lines is train, then one test, then one dev
# Usage: ./generate_splits.pl basename < input
# Output: basename.train, basename_test.gold, basename_dev.gold
# By Jon Dehdari

use strict;
use Getopt::Long;

my $usage = <<"END_OF_USAGE";
generate_splits.pl

Usage:    perl $0  basename < input

Function: Generates Train/Test/Dev splits
          Every 8 lines is train, then one test, then one dev

Options:
  -h, --help     Print usage

END_OF_USAGE

GetOptions(
    'h|help|?'      => sub { print $usage; exit; },
) or die $usage;

my $basename = shift  or die "$0: Error - Specify file basename\n\n$usage";
open ( TRAIN, ">", "${basename}.train" );
open ( TEST,  ">", "${basename}_test.gold" );
open ( DEV,   ">", "${basename}_dev.gold" );


my $counter;
while (<>) {
    if ($counter == 8) {
	print TEST $_;
	$counter++;
    }
    elsif ($counter == 9) {
	print DEV $_;
	$counter = 0;
    }
    else {
	print TRAIN $_;
	$counter++;
    }
}

close TRAIN;
close TEST;
close DEV;

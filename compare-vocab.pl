#!/usr/bin/perl
# Author: Petri Jooste
# Purpose: To find corresponding words in vocabulary files and report the frequency
#	Applications include: 	1) Comparing list of English with list of Afrikaans words
#				to identify English words in an Afrikaans corpus
#				2) To get a list of words that exist is both languages

use warnings;
use strict;

use open IO => ':encoding(UTF-8)';
use open ':std';

# ?? Lowercase all words

if (((@ARGV + 0) != 3) and ((@ARGV + 0) != 4)) {
  print "Usage: ./compare_vocab.pl <in:list1> <in:list2> <out:vocab> (in:known-match.list)\n";
  exit 1;
}

my $vocab1  	= $ARGV[0];
my $vocab2 	= $ARGV[1];
my $vocab_out 	= $ARGV[2];

my $known = 0;
if (scalar(@ARGV) == 4) {
  $known = $ARGV[3];
}

my %list1;
my %list2;
my %list3;

open VOCAB_1_IN, "<$vocab1" or die "Can't open '$vocab1' for reading!\n";
open VOCAB_2_IN, "<$vocab2" or die "Can't open '$vocab2' for reading!\n";
#open VOCAB_OUT, ">$vocab_out" or die "Can't open '$vocab_out' for writing!\n";

while (<VOCAB_1_IN>) {
	chomp;
	my ($word, $count) = split /\s+/;
	$list1{$word} += $count;
}	
close(VOCAB_1_IN);

while (<VOCAB_2_IN>) {
	chomp;
	my ($word, $count2) = split /\s+/;
	# if word exist in list1 then add it with counts to list3
	my $count1 = $list1{$word};
	if ( $count1 ) {
		print "$word\t$count1\t$count2\n"; 
	}
}	
close(VOCAB_2_IN);
#close(VOCAB_OUT);



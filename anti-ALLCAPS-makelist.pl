#!/usr/bin/perl

# This script creates a vocabulary of corpus words to use for word-based lowercasing
# It needs to be run once to create vocabulary files needed for the script anti-ALCAPS.pl (called from step04...sh script)
# e.g.
# THIS IS A HEADING ABOUT SANLAM AND EKNP111  --> this is a heading about SANLAM and EKNP111 

use warnings;
use strict;

use open IO => ':encoding(UTF-8)';
use open ':std';
use utf8;

if (((@ARGV + 0) != 2)) {
  print "Usage: ./anti-ALLCAPS-makelist.pl <text> <out:vocab>\n";
  exit 1;
}

my $min_cnt = 0;
my $text  	= $ARGV[0];
my $vocab 	= $ARGV[1];

my @tokens;
my %words;

open TEXT, "$text" or die "Error opening file $text";
while(<TEXT>) {
  chomp;
  @tokens = split(/[\s\d\P{Word}ŉ]/,$_);
  foreach my $word (@tokens) {
    $words{$word} += 1  # Add the word to the hash
#	unless ( $word =~ /\p{^IsAlpha}/ )   # ignore tokens containing non-alphabetic characters
# or
	unless ($word =~ /\p{IsUpper}\p{IsUpper}+/); # ignore tokens with consecutive uppercase characters
  }
}
close(TEXT);

open VOCAB_OUT, ">$vocab" or die "Can't open '$vocab' for writing!\n";
my @sorted = sort {$words{$b} <=> $words{$a}} keys %words;
foreach my $word (@sorted) {
  if ($words{$word} >= $min_cnt) {
    printf VOCAB_OUT "%s\t%d\n", $word,$words{$word};
  }
}
close(VOCAB_OUT);
